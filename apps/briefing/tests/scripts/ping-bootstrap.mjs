#!/usr/bin/env node
import process from "node:process";
import { Miniflare } from "miniflare";
import { createMiniflareOptions } from "../config/miniflare-options.mjs";

async function main() {
  const env = process.env.RUNART_ENV ?? "preview";
  const mf = new Miniflare(
    createMiniflareOptions({
      env,
      watch: false,
      liveReload: false,
    })
  );

  try {
    const response = await mf.dispatchFetch("http://localhost/__bootstrap__");
    const body = await response.text();

    if (response.status !== 200 || body.trim() !== "bootstrap-ok") {
      throw new Error(
        `Bootstrap endpoint inesperado → status=${response.status} body=${body}`
      );
    }

    console.log(`[bootstrap] OK · env=${env}`);
  } finally {
    await mf.dispose();
  }
}

main().catch((error) => {
  console.error("[bootstrap] FAIL", error);
  process.exitCode = 1;
});
