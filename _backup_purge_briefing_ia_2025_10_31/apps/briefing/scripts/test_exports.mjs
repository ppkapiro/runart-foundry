#!/usr/bin/env node
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import path from 'node:path';
import vm from 'node:vm';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function loadHelpers() {
  const exportsPath = path.resolve(__dirname, '../docs/assets/exports/exports.js');
  const source = await readFile(exportsPath, 'utf8');

  const context = {
    console,
    globalThis: {},
  };
  context.globalThis = context;

  vm.createContext(context);
  vm.runInContext(source, context, { filename: 'exports.js' });

  const helpers = context.RunartExports;
  assert.ok(helpers, 'RunartExports no está disponible');
  return helpers;
}

function sampleItems() {
  const base = (overrides) => ({
    decision_id: overrides.id,
    ts: overrides.ts,
    moderation: { status: overrides.status },
    meta: {
      createdAt: overrides.ts,
      userEmail: overrides.owner,
    },
    payload: {
      artista: overrides.artist,
      titulo: overrides.title,
      anio: overrides.year,
      tipo: overrides.tipo,
    },
  });

  return [
    base({ id: 'A1', ts: '2025-03-01T12:00:00Z', status: 'accepted', owner: 'alice@example.com', artist: 'Artista A', title: 'Obra A', year: '2019', tipo: 'escultura' }),
    base({ id: 'B2', ts: '2025-03-05T12:00:00Z', status: 'accepted', owner: 'bob@example.com', artist: 'Artista B', title: 'Obra B', year: '2020', tipo: 'escultura' }),
    base({ id: 'C3', ts: '2025-03-08T12:00:00Z', status: 'pending', owner: 'alice@example.com', artist: 'Artista C', title: 'Obra C', year: '2024', tipo: 'instalación' }),
  ];
}

(async () => {
  const helpers = await loadHelpers();
  const { filterByRole, recordFromItem } = helpers;

  const range = {
    from: new Date('2025-03-01T00:00:00Z'),
    to: new Date('2025-03-31T23:59:59Z'),
  };
  const items = sampleItems();

  const adminView = filterByRole(items, range, { role: 'admin', email: 'admin@example.com' });
  assert.strictEqual(adminView.length, 2, 'El equipo debería ver todos los aceptados');

  const clientView = filterByRole(items, range, { role: 'cliente', email: 'alice@example.com' });
  assert.strictEqual(clientView.length, 1, 'El cliente solo debe ver sus fichas aprobadas');
  assert.strictEqual(clientView[0].meta.userEmail, 'alice@example.com');

  const anonymousView = filterByRole(items, range, { role: 'visitante', email: '' });
  assert.strictEqual(anonymousView.length, 2, 'Visitantes usan fallback de aceptados sin filtrar por dueño');

  const exported = clientView.map(recordFromItem);
  const expectedRecord = {
    id: 'A1',
    tipo: 'escultura',
    createdAt: '2025-03-01T12:00:00Z',
    artista: 'Artista A',
    titulo: 'Obra A',
    anio: '2019',
    token_origen: ''
  };
  assert.strictEqual(
    JSON.stringify(exported[0]),
    JSON.stringify(expectedRecord),
    'El registro exportado debe mantener el shape esperado'
  );

  console.log('✅ Test de exportaciones: filtros por rol verificados');
})();
