# Mapa de interfaces (ARQ)

Diagrama funcional (cliente / equipo / APIs). Protegido por **Cloudflare Access**.

<div role="img" aria-label="Flujo: Editor envía a API decisiones (pending) → Inbox modera → KPIs/Exportaciones">
<svg viewBox="0 0 1100 600" width="100%" height="auto" xmlns="http://www.w3.org/2000/svg">
  <!-- Separadores -->
  <line x1="40" y1="180" x2="1060" y2="180" stroke="#444" stroke-width="1"/>
  <text x="50" y="170" font-size="14">Cliente (acceso con Cloudflare Access)</text>
  <text x="50" y="590" font-size="14">Equipo (interno)</text>
  <text x="820" y="40" font-size="12">Cloudflare Access protege rutas y APIs</text>

  <!-- Cajas cliente -->
  <rect x="70"  y="80"  width="270" height="70" fill="none" stroke="#000"/>
  <text x="205" y="110" font-size="12" text-anchor="middle">Dashboards / KPIs (cliente)</text>
  <text x="205" y="128" font-size="11" text-anchor="middle">/dashboards/cliente/</text>

  <rect x="415" y="80"  width="270" height="70" fill="none" stroke="#000"/>
  <text x="550" y="110" font-size="12" text-anchor="middle">Documentos: Arquitectura / Master Plan</text>
  <text x="550" y="128" font-size="11" text-anchor="middle">briefing_arquitectura.md / master_plan</text>

  <rect x="760" y="80"  width="270" height="70" fill="none" stroke="#000"/>
  <text x="895" y="110" font-size="12" text-anchor="middle">Reporte de Corte ARQ</text>
  <text x="895" y="128" font-size="11" text-anchor="middle">/_reports/corte_arq.md</text>

  <!-- Cajas equipo -->
  <rect x="70"  y="240" width="270" height="70" fill="none" stroke="#000"/>
  <text x="205" y="270" font-size="12" text-anchor="middle">Editor de Fichas (beta)</text>
  <text x="205" y="288" font-size="11" text-anchor="middle">/editor/</text>

  <rect x="415" y="240" width="270" height="70" fill="none" stroke="#000"/>
  <text x="550" y="268" font-size="12" text-anchor="middle">Inbox + Moderación</text>
  <text x="550" y="286" font-size="11" text-anchor="middle">pending / accept / reject · /inbox/</text>

  <rect x="760" y="240" width="270" height="70" fill="none" stroke="#000"/>
  <text x="895" y="268" font-size="12" text-anchor="middle">Exportaciones (MF)</text>
  <text x="895" y="286" font-size="11" text-anchor="middle">JSONL/CSV por rango · /exports/</text>

  <!-- APIs -->
  <rect x="230" y="380" width="270" height="70" fill="none" stroke="#000"/>
  <text x="365" y="408" font-size="12" text-anchor="middle">API: /api/decisiones (POST)</text>
  <text x="365" y="426" font-size="11" text-anchor="middle">Guarda en KV</text>

  <rect x="520" y="380" width="270" height="70" fill="none" stroke="#000"/>
  <text x="655" y="408" font-size="12" text-anchor="middle">API: /api/inbox (GET)</text>
  <text x="655" y="426" font-size="11" text-anchor="middle">Lista decisiones</text>

  <rect x="810" y="380" width="270" height="70" fill="none" stroke="#000"/>
  <text x="945" y="408" font-size="12" text-anchor="middle">API: /api/moderar (POST)</text>
  <text x="945" y="426" font-size="11" text-anchor="middle">Cambia estado</text>

  <!-- Flechas -->
  <defs><marker id="arr" markerWidth="8" markerHeight="8" refX="6" refY="4" orient="auto"><path d="M0,0 L8,4 L0,8 z"/></marker></defs>
  <!-- Editor -> decisiones -->
  <line x1="250" y1="310" x2="300" y2="380" stroke="#6a5" stroke-width="2" marker-end="url(#arr)"/>
  <text x="240" y="345" font-size="11">submit (token + honeypot)</text>
  <!-- decisiones -> Inbox -->
  <line x1="400" y1="380" x2="520" y2="310" stroke="#6a5" stroke-width="2" marker-end="url(#arr)"/>
  <text x="455" y="345" font-size="11">nuevo item: PENDING</text>
  <!-- Inbox -> moderar -->
  <line x1="680" y1="310" x2="930" y2="380" stroke="#a84" stroke-width="2" marker-end="url(#arr)"/>
  <text x="805" y="340" font-size="11">accept / reject</text>
  <!-- moderar -> Inbox -->
  <line x1="930" y1="380" x2="680" y2="310" stroke="#a84" stroke-width="0.01" marker-end="url(#arr)"/>
  <!-- Inbox -> KPIs -->
  <line x1="550" y1="240" x2="205" y2="150" stroke="#48a" stroke-width="2" marker-end="url(#arr)"/>
  <text x="330" y="200" font-size="11">accepted → KPIs</text>
  <!-- Inbox -> Exportaciones -->
  <line x1="680" y1="275" x2="760" y2="275" stroke="#48a" stroke-width="2" marker-end="url(#arr)"/>
  <text x="720" y="265" font-size="11">accepted → exportación</text>
</svg>
</div>

**Cómo leerlo:** el **Editor** envía con token + honeypot → queda **PENDING** en **Inbox** → se **modera** → si **ACCEPTED**, alimenta **KPIs** y **Exportaciones**.
