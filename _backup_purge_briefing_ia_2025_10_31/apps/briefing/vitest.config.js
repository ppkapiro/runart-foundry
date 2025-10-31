import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: false,
    environment: 'node',
    include: ['tests/unit/**/*.test.js'],
    exclude: ['tests/unit/**/*.mjs', 'node_modules/**'],
    testTimeout: 30000,
  },
});
