import assert from 'node:assert/strict';
import { resolveRole } from '../../functions/_utils/roles.js';
import staticRoles from '../../access/roles.json' with { type: 'json' };

const kvRoles = {
  owners: ['owner@runart.com'],
  client_admins: ['admin@runart.com'],
  team: ['team@runart.com'],
  clients: ['client@runart.com'],
  team_domains: ['agency.runart.com'],
};

const makeEnv = (overrides = {}) => ({
  ACCESS_ADMINS: 'owner@runart.com',
  ACCESS_CLIENT_ADMINS: 'admin@runart.com',
  ACCESS_EQUIPO_DOMAINS: 'agency.runart.com',
  RUNART_ROLES: {
    async get(key) {
      if (key === 'runart_roles') {
        return kvRoles;
      }
      return null;
    },
  },
  ...overrides,
});

(async () => {
  // Caso 1: KV ausente → fallback a roles estáticos sin promover a owner
  const envStaticFallback = {
    ACCESS_ADMINS: staticRoles.owners?.[0] ?? '',
    ACCESS_CLIENT_ADMINS: '',
    ACCESS_EQUIPO_DOMAINS: '',
    RUNART_ROLES: {
      async get() {
        return null;
      },
    },
  };
  assert.equal(await resolveRole('ppcapiro@gmail.com', envStaticFallback), 'owner');
  assert.equal(await resolveRole('runartfoundry@gmail.com', envStaticFallback), 'client_admin');
  assert.equal(await resolveRole('musicmanagercuba@gmail.com', envStaticFallback), 'client');
  assert.equal(await resolveRole('infonetwokmedia@gmail.com', envStaticFallback), 'team');
  assert.equal(await resolveRole('unknown@none.com', envStaticFallback), 'visitor');

  // Caso 2: Datos provenientes de KV personalizado
  const envFromKv = makeEnv();
  assert.equal(await resolveRole('owner@runart.com', envFromKv), 'owner');
  assert.equal(await resolveRole('admin@runart.com', envFromKv), 'client_admin');
  assert.equal(await resolveRole('client@runart.com', envFromKv), 'client');
  assert.equal(await resolveRole('team@runart.com', envFromKv), 'team');
  assert.equal(await resolveRole('visitor@example.com', envFromKv), 'visitor');

  // Caso 3: Normalización de espacios y mayúsculas
  assert.equal(await resolveRole('  TEAM@RUNART.COM  ', envFromKv), 'team');

  // Caso 4: Variables ACCESS_* vacías no fuerzan owner
  const envNoAccess = makeEnv({ ACCESS_ADMINS: '', ACCESS_CLIENT_ADMINS: '', ACCESS_EQUIPO_DOMAINS: '' });
  assert.equal(await resolveRole('client@runart.com', envNoAccess), 'client');
  assert.equal(await resolveRole('unknown@example.com', envNoAccess), 'visitor');

  console.log('roles.unified.resolve.test.mjs: PASS');
})();
