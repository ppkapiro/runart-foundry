// Mapper de compatibilidad entre taxonomías legacy y unificada
// Tabla de equivalencias:
// | Legacy      | Unificada   |
// |-------------|-------------|
// | admin       | owner       |
// | equipo      | team        |
// | cliente     | client      |
// | visitante   | visitor     |
// | client_admin| admin       | // admin_delegate

const legacyToUnified = {
  admin: 'owner',
  equipo: 'team',
  cliente: 'client',
  visitante: 'visitor',
  // admin_delegate: 'client_admin', // si se usa
};

const unifiedToLegacy = {
  owner: 'admin',
  team: 'equipo',
  client: 'cliente',
  visitor: 'visitante',
  client_admin: 'admin', // admin_delegate
};

export function toLegacy(newRole) {
  return unifiedToLegacy[newRole] || newRole;
}

export function toUnified(oldRole) {
  return legacyToUnified[oldRole] || oldRole;
}
