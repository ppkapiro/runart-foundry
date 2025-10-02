# Inbox — Decisiones recientes
<ul id="inbox-list"></ul>
<script>
  async function loadInbox() {
    const res = await fetch('https://runart-briefing.pages.dev/api/inbox');
    if (!res.ok) return;
    const items = await res.json();
    const ul = document.getElementById('inbox-list');
    ul.innerHTML = '';
    items.forEach(it => {
      const li = document.createElement('li');
      li.textContent = `${it.ts} — ${it.decision_id} — ${it.seleccion} — ${it.usuario}`;
      ul.appendChild(li);
    });
  }
  loadInbox();
</script>
