// Tests unitarios para roles unificados (KV RUNART_ROLES)
import assert from 'node:assert/strict';
import { resolveRoleUnified, roleToAliasUnified } from '../../functions/_shared/roles.shared.js';
import { toLegacy, toUnified } from '../../functions/_lib/roles-compat.js';

const env = {
  RUNART_ROLES: {
    get: async (key) => {
      if (key === 'runart_roles') {
        return {
          owners: ['owner@runart.com'],
          client_admins: ['admin@runart.com'],
          team: ['team@runart.com'],
          clients: ['client@runart.com'],
          team_domains: ['runart.com'],
        };
      }
      return null;
    }
  },
  ACCESS_ADMINS: 'owner@runart.com',
  ACCESS_EQUIPO_DOMAINS: 'runart.com',
  ACCESS_CLIENT_ADMINS: 'admin@runart.com',
};

const emails = {
  owner: 'owner@runart.com',
  client_admin: 'admin@runart.com',
  team: 'team@runart.com',
  client: 'client@runart.com',
  visitor: 'visitor@other.com',
  unknown: 'unknown@other.com',
};

// Test principal de resolución
(async () => {
  assert.equal(await resolveRoleUnified(emails.owner, env), 'owner');
  assert.equal(await resolveRoleUnified(emails.client_admin, env), 'client_admin');
  assert.equal(await resolveRoleUnified(emails.team, env), 'team');
  assert.equal(await resolveRoleUnified(emails.client, env), 'client');
  assert.equal(await resolveRoleUnified(emails.visitor, env), 'visitor');
  assert.equal(await resolveRoleUnified(emails.unknown, env), 'visitor'); // fallback

  // Alias
  assert.equal(roleToAliasUnified('owner'), 'propietario');
  assert.equal(roleToAliasUnified('client_admin'), 'cliente_admin');
  assert.equal(roleToAliasUnified('team'), 'equipo');
  assert.equal(roleToAliasUnified('client'), 'cliente');
  assert.equal(roleToAliasUnified('visitor'), 'visitante');

  // Mapper legacy
  assert.equal(toLegacy('owner'), 'admin');
  assert.equal(toLegacy('team'), 'equipo');
  assert.equal(toLegacy('client'), 'cliente');
  assert.equal(toLegacy('visitor'), 'visitante');
  assert.equal(toLegacy('client_admin'), 'admin');

  assert.equal(toUnified('admin'), 'owner');
  assert.equal(toUnified('equipo'), 'team');
  assert.equal(toUnified('cliente'), 'client');
  assert.equal(toUnified('visitante'), 'visitor');

  console.log('roles.unified.test.mjs: PASS');
})();
