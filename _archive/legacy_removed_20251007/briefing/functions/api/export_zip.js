const JSON_HEADERS = { 'Content-Type': 'application/json' };

const errorResponse = (status, message) =>
  new Response(JSON.stringify({ ok: false, error: message }), {
    status,
    headers: JSON_HEADERS
  });

const isOriginAllowed = (request, allowedOrigin) => {
  if (!allowedOrigin) return true;
  const originHeader = request.headers.get('Origin') || request.headers.get('Referer');
  if (!originHeader) return true;
  return originHeader.startsWith(allowedOrigin);
};

const getTokenFromRequest = (request, bodyToken) => {
  const headerToken = request.headers.get('X-Runart-Token');
  return (headerToken || bodyToken || '').trim();
};

const isTokenValid = (submitted, expected, allowDevFallback) => {
  if (!submitted) return false;
  if (expected && submitted === expected) return true;
  if (allowDevFallback && submitted === 'dev-token') return true;
  return false;
};

const parseDecision = (raw, name) => {
  try {
    const parsed = JSON.parse(raw);
    return { ...parsed, _kvKey: name };
  } catch (error) {
    return null;
  }
};

const withinRange = (createdAt, from, to) => {
  if (!createdAt) return false;
  const ts = Date.parse(createdAt);
  if (Number.isNaN(ts)) return false;
  return ts >= from && ts <= to;
};

const ensureDate = (value, name) => {
  const parsed = Date.parse(`${value}T00:00:00Z`);
  if (Number.isNaN(parsed)) {
    throw new Error(`Fecha inválida: ${name}`);
  }
  return parsed;
};

const buildJsonl = (items) => items.map((item) => JSON.stringify(item)).join('\n');

const csvEscape = (value) => {
  const cell = value == null ? '' : String(value);
  if (cell.includes('"')) {
    return `"${cell.replace(/"/g, '""')}"`;
  }
  if (cell.search(/[\n,;]/) !== -1) {
    return `"${cell}"`;
  }
  return cell;
};

const buildCsv = (items) => {
  const header = ['id', 'tipo', 'createdAt', 'titulo', 'artista', 'anio', 'token_origen'];
  const rows = items.map((item) =>
    [
      item.decision_id,
      item.tipo,
      item.meta?.createdAt,
      item.payload?.titulo,
      item.payload?.artista || item.payload?.artistaNombre,
      item.payload?.anio,
      item.token_origen
    ].map(csvEscape).join(',')
  );
  return [header.join(','), ...rows].join('\n');
};

const encodeUtf8 = (str) => new TextEncoder().encode(str);

const CRC_TABLE = (() => {
  const table = new Uint32Array(256);
  for (let i = 0; i < 256; i += 1) {
    let c = i;
    for (let j = 0; j < 8; j += 1) {
      c = (c & 1) ? (0xedb88320 ^ (c >>> 1)) : (c >>> 1);
    }
    table[i] = c >>> 0;
  }
  return table;
})();

const crc32 = (bytes) => {
  let crc = 0xffffffff;
  for (let i = 0; i < bytes.length; i += 1) {
    const byte = bytes[i];
    const index = (crc ^ byte) & 0xff;
    crc = CRC_TABLE[index] ^ (crc >>> 8);
  }
  return (crc ^ 0xffffffff) >>> 0;
};

const buildZip = (entries) => {
  let offset = 0;
  const fileRecords = [];
  const chunks = [];

  for (const { name, bytes } of entries) {
    const nameBytes = encodeUtf8(name);
    const crc = crc32(bytes);
    const localHeader = new Uint8Array(30 + nameBytes.length);
    const view = new DataView(localHeader.buffer);
    view.setUint32(0, 0x04034b50, true);
    view.setUint16(4, 20, true);
    view.setUint16(6, 0, true);
    view.setUint16(8, 0, true);
    view.setUint16(10, 0, true);
    view.setUint16(12, 0, true);
    view.setUint32(14, crc, true);
    view.setUint32(18, bytes.length, true);
    view.setUint32(22, bytes.length, true);
    view.setUint16(26, nameBytes.length, true);
    chunks.push(localHeader, nameBytes, bytes);

    fileRecords.push({
      nameBytes,
      bytesLength: bytes.length,
      crc32: crc,
      offset
    });
    offset += localHeader.length + nameBytes.length + bytes.length;
  }

  const centralChunks = [];
  let centralSize = 0;
  for (const record of fileRecords) {
    const center = new Uint8Array(46 + record.nameBytes.length);
    const view = new DataView(center.buffer);
    view.setUint32(0, 0x02014b50, true);
    view.setUint16(4, 20, true);
    view.setUint16(6, 20, true);
    view.setUint16(8, 0, true);
    view.setUint16(10, 0, true);
    view.setUint16(12, 0, true);
    view.setUint16(14, 0, true);
    view.setUint16(16, 0, true);
    view.setUint32(18, record.crc32, true);
    view.setUint32(22, record.bytesLength, true);
    view.setUint32(26, record.bytesLength, true);
    view.setUint16(30, record.nameBytes.length, true);
    view.setUint32(42, record.offset, true);
    centralChunks.push(center, record.nameBytes);
    centralSize += center.length + record.nameBytes.length;
  }

  const end = new Uint8Array(22);
  const endView = new DataView(end.buffer);
  endView.setUint32(0, 0x06054b50, true);
  endView.setUint16(4, 0, true);
  endView.setUint16(6, 0, true);
  endView.setUint16(8, fileRecords.length, true);
  endView.setUint16(10, fileRecords.length, true);
  endView.setUint32(12, centralSize, true);
  endView.setUint32(16, offset, true);

  const totalSize = offset + centralSize + end.length;
  const output = new Uint8Array(totalSize);
  let cursor = 0;
  for (const chunk of chunks) {
    output.set(chunk, cursor);
    cursor += chunk.length;
  }
  for (const chunk of centralChunks) {
    output.set(chunk, cursor);
    cursor += chunk.length;
  }
  output.set(end, cursor);
  return output;
};

const fetchInbox = async (env) => {
  const list = await env.DECISIONES.list({ prefix: 'decision:' });
  const items = [];
  for (const { name } of list.keys) {
    const stored = await env.DECISIONES.get(name);
    if (!stored) continue;
    const parsed = parseDecision(stored, name);
    if (parsed) items.push(parsed);
  }
  return items;
};

export const onRequestPost = async ({ request, env }) => {
  if (!isOriginAllowed(request, env.ORIGIN_ALLOWED)) {
    return errorResponse(403, 'Origen no permitido.');
  }

  let body;
  try {
    body = await request.json();
  } catch (error) {
    return errorResponse(400, 'JSON inválido o cuerpo ausente.');
  }

  const submittedToken = getTokenFromRequest(request, body?.auth_token);
  const expectedToken = env.EDITOR_TOKEN ? String(env.EDITOR_TOKEN) : '';
  const allowDev = !expectedToken;
  if (!isTokenValid(submittedToken, expectedToken, allowDev)) {
    return errorResponse(401, 'Token inválido o ausente.');
  }

  const fromStr = (body?.from || '').trim();
  const toStr = (body?.to || '').trim();
  if (!fromStr || !toStr) {
    return errorResponse(400, 'from y to son obligatorios.');
  }

  let fromTime;
  let toTime;
  try {
    fromTime = ensureDate(fromStr, 'from');
    toTime = ensureDate(toStr, 'to') + (24 * 60 * 60 * 1000 - 1);
  } catch (error) {
    return errorResponse(400, error.message);
  }

  let items;
  try {
    items = await fetchInbox(env);
  } catch (error) {
    return errorResponse(500, 'No se pudo obtener el inbox.');
  }

  const accepted = items.filter(
    (item) => item?.moderation?.status === 'accepted' && withinRange(item?.meta?.createdAt, fromTime, toTime)
  );

  const jsonlContent = buildJsonl(accepted);
  const csvContent = buildCsv(accepted);

  const entries = [
    {
      name: `export_accepted_${fromStr}_to_${toStr}.jsonl`,
      bytes: encodeUtf8(jsonlContent)
    },
    {
      name: `export_accepted_${fromStr}_to_${toStr}.csv`,
      bytes: encodeUtf8(csvContent)
    }
  ];

  const zipBytes = buildZip(entries);

  return new Response(zipBytes, {
    status: 200,
    headers: {
      'Content-Type': 'application/zip',
      'Content-Disposition': `attachment; filename="export_accepted_${fromStr}_to_${toStr}.zip"`
    }
  });
};
