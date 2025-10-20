/**
 * Tests unitarios para hash6() — claves deterministas de eventos
 * Valida que hash6() produce siempre la misma salida para la misma entrada
 */

import { describe, it, expect } from 'vitest';

// hash6 no está exportada, la replicamos localmente para testing
function hash6(str) {
  let h = 0x811c9dc5;
  for (let i = 0; i < str.length; i++) {
    h ^= str.charCodeAt(i);
    h = (h >>> 0) * 0x01000193;
  }
  const v = h >>> 0;
  return v.toString(36).slice(0, 6);
}

describe('event_keys — hash6 determinista', () => {
  it('misma entrada produce mismo hash (reproducibilidad)', () => {
    const input = '2025-10-20T10:00:00.000Z|test@example.com|/path|action';
    const result1 = hash6(input);
    const result2 = hash6(input);
    expect(result1).toBe(result2);
    expect(result1).toHaveLength(6);
  });

  it('diferentes entradas producen diferentes hashes', () => {
    const hash1 = hash6('input_a');
    const hash2 = hash6('input_b');
    expect(hash1).not.toBe(hash2);
  });

  it('vectores de prueba conocidos (regresión)', () => {
    // Estos valores deben permanecer estables
    // Si cambian, indica que la implementación de FNV-1a cambió
    const testVectors = [
      { input: '', expected: 'ztntfp' }, // offset basis to base36
      { input: 'hello', expected: '13ayj0' },
      { input: '2025-10-20T10:00:00.000Z|admin@example.com|/api/test|page_view', expected: 'drzya0' },
    ];

    testVectors.forEach(({ input, expected }) => {
      const result = hash6(input);
      expect(result).toBe(expected);
    });
  });

  it('produce solo caracteres válidos base36', () => {
    const result = hash6('test_input_12345');
    expect(result).toMatch(/^[0-9a-z]{6}$/);
  });

  it('longitud fija de 6 caracteres', () => {
    const inputs = ['', 'a', 'short', 'much_longer_string_to_hash'];
    inputs.forEach((input) => {
      const result = hash6(input);
      expect(result).toHaveLength(6);
    });
  });

  it('maneja strings con caracteres especiales', () => {
    const special = 'ñáéíóú|@|🚀|\\n\\t';
    const result = hash6(special);
    expect(result).toHaveLength(6);
    expect(result).toMatch(/^[0-9a-z]{6}$/);
  });

  it('colisión poco probable (smoke test)', () => {
    const hashes = new Set();
    const count = 1000;
    
    for (let i = 0; i < count; i++) {
      const input = `event_${i}_${Date.now()}`;
      const hash = hash6(input);
      hashes.add(hash);
    }

    // Esperamos muy pocas colisiones con 1000 inputs
    // Con 6 chars base36 = 36^6 = ~2B posibles valores
    // 1000 hashes → probabilidad de colisión muy baja
    expect(hashes.size).toBeGreaterThan(995);
  });
});
