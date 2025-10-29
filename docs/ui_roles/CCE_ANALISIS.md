# Análisis CCE — 2025-10-21 17:13:04
Autor: Automatización Consolidación — Relación: BITÁCORA

## decision_chip
- Props: id, title, status, owner, links (ejemplo)
- Data contract: { id: string; title: string; status: 'R'|'G'|'A'; owner?: string; evidence?: string }
- Visibilidad por rol: admin, cliente

## entrega_card
- Props: id, title, status, owner, links (ejemplo)
- Data contract: { id: string; title: string; status: 'R'|'G'|'A'; owner?: string; evidence?: string }
- Visibilidad por rol: admin, cliente, owner_interno, equipo

## evidencia_clip
- Props: id, title, status, owner, links (ejemplo)
- Data contract: { id: string; title: string; status: 'R'|'G'|'A'; owner?: string; evidence?: string }
- Visibilidad por rol: admin, cliente, owner_interno, equipo

## faq_item
- Props: id, title, status, owner, links (ejemplo)
- Data contract: { id: string; title: string; status: 'R'|'G'|'A'; owner?: string; evidence?: string }
- Visibilidad por rol: admin, cliente

## ficha_tecnica_mini
- Props: id, title, status, owner, links (ejemplo)
- Data contract: { id: string; title: string; status: 'R'|'G'|'A'; owner?: string; evidence?: string }
- Visibilidad por rol: admin, equipo

## hito_card
- Props: id, title, status, owner, links (ejemplo)
- Data contract: { id: string; title: string; status: 'R'|'G'|'A'; owner?: string; evidence?: string }
- Visibilidad por rol: admin, cliente, owner_interno, equipo

## kpi_chip
- Props: id, title, status, owner, links (ejemplo)
- Data contract: { id: string; title: string; status: 'R'|'G'|'A'; owner?: string; evidence?: string }
- Visibilidad por rol: admin, cliente, owner_interno

