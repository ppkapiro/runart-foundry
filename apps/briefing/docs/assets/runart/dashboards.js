(function () {
  const DATA = {
    owner: {
      activity: [
        { ts: '2025-10-08T14:30:00Z', type: 'decision_created', summary: 'Aprobar wireframes UI', actor: 'ppcapiro@gmail.com' },
        { ts: '2025-10-08T13:10:00Z', type: 'log_event', summary: 'LOG_EVENTS normalizados', actor: 'automation@runartfoundry.com' },
        { ts: '2025-10-07T20:45:00Z', type: 'deploy', summary: 'Deploy Cloudflare Pages #18297709612', actor: 'ci@github' }
      ],
      tasks: [
        { id: 'task-001', title: 'Coordinar sesión Access owner/client', priority: 'high', due: '2025-10-09' },
        { id: 'task-002', title: 'Validar workflows QA activados', priority: 'medium', due: '2025-10-10' }
      ],
      workflows: [
        { name: 'docs-lint', status: 'success', updated_at: '2025-10-08T12:10:00Z' },
        { name: 'env-report', status: 'in_progress', updated_at: '2025-10-08T13:05:00Z' },
        { name: 'status-update', status: 'queued', updated_at: '2025-10-08T13:05:00Z' }
      ],
      alerts: { role_unknown: 0, error_5xx: 1, latency_p95_ms: 320 },
      decisions: [
        { id: 'dec-20251008-001', title: 'Cerrar backlog Fase 4', status: 'closed', ts: '2025-10-08T10:20:00Z' },
        { id: 'dec-20251009-002', title: 'Iniciar activación workflows QA', status: 'open', ts: '2025-10-09T08:00:00Z' }
      ]
    },
    client_admin: {
      summary: { critical: 1, upcoming: 2 },
      tasks: [
        { id: 'req-32', title: 'Revisar fichas pendientes', due: '2025-10-09', priority: 'high' },
        { id: 'req-33', title: 'Enviar capturas de dashboard', due: '2025-10-11', priority: 'medium' }
      ],
      logins: [
        { email: 'runartfoundry@gmail.com', ts: '2025-10-07T16:45:00Z', status: 'success' },
        { email: 'musicmanagercuba@gmail.com', ts: '2025-10-07T09:13:00Z', status: 'failed' }
      ],
      guides: [
        { label: 'Guía de validaciones', href: '/docs/internal/briefing_system/guides/Guia_QA_y_Validaciones/' },
        { label: 'Bitácora 082', href: '/docs/internal/briefing_system/ci/082_reestructuracion_local/' }
      ],
      progress: [
        { phase: 'F5', percent: 35, nextMilestone: 'Activar workflows QA' },
        { phase: 'F6', percent: 0, nextMilestone: 'Planificación' }
      ]
    },
    team: {
      filters: ['apps/briefing', 'services/*', 'tools/*'],
      kanban: {
        todo: [
          { title: 'Desplegar mocks dashboards', owner: 'devops@runartfoundry.com', due: '2025-10-09' }
        ],
        doing: [
          { title: 'Activar workflow env-report', owner: 'ci@runartfoundry.com', due: '2025-10-09' }
        ],
        review: [
          { title: 'QA documentación F5', owner: 'qa@runartfoundry.com', due: '2025-10-10' }
        ],
        blocked: []
      },
      incidents: [
        { id: 'INC-20251007-01', severity: 'major', summary: 'Latencia elevada /api/whoami', updated: '2025-10-07T18:20:00Z' }
      ],
      deploys: [
        { id: '18297709612', status: 'success', ts: '2025-10-07T23:53:00Z' },
        { id: '18298505368', status: 'success', ts: '2025-10-07T20:10:00Z' }
      ],
      alerts: { error_5xx: 1, latency_p95_ms: 320, uptime: '99.8%' }
    },
    client: {
      hero: 'Bienvenido a tu panel RunArt Briefing',
      updates: [
        { title: 'Ficha “Escultura central” actualizada', date: '2025-10-07', tag: 'Actualización' },
        { title: 'Nuevo plan de rodaje', date: '2025-10-06', tag: 'Nuevo' }
      ],
      milestones: [
        { date: '2025-10-12', title: 'Revisión de dashboards', responsible: 'Equipo RunArt' },
        { date: '2025-10-18', title: 'Entrega capturas finales', responsible: 'Cliente' }
      ],
      forms: [
        { title: 'Formulario feedback dashboards', href: 'https://example.com/form', deadline: '2025-10-15' }
      ],
      contacts: [
        { name: 'Equipo RunArt', email: 'briefing@runartfoundry.com', availability: 'L–V 09:00–18:00 ET' }
      ]
    },
    visitor: {
      hero: {
        message: 'Explora el ecosistema RunArt Foundry',
        cta: 'Solicitar acceso'
      },
      publicDocs: [
        { title: 'Dossier corporativo', type: 'Comunicado', href: '/docs/client_projects/runart_foundry/reports/presskit_v1_ES/' },
        { title: 'Caso de éxito RunArt', type: 'Caso de éxito', href: '/docs/client_projects/runart_foundry/reports/2025-10-02_master_plan/' }
      ],
      access: {
        href: 'https://runartfoundry.typeform.com/to/access',
        fallback: 'briefing@runartfoundry.com'
      },
      news: [
        { title: 'Lanzamiento UI contextual', date: '2025-10-08' },
        { title: 'Nuevo plan de observabilidad', date: '2025-10-05' }
      ]
    }
  };

  const formatDate = (iso) => {
    if (!iso) return '';
    try {
      const dt = new Date(iso);
      return dt.toLocaleString('es-ES', {
        dateStyle: 'short',
        timeStyle: iso.includes('T') ? 'short' : undefined,
      });
    } catch (err) {
      return iso;
    }
  };

  const createElement = (tag, className, text) => {
    const el = document.createElement(tag);
    if (className) el.className = className;
    if (text) el.textContent = text;
    return el;
  };

  const clearNode = (node) => {
    while (node.firstChild) node.removeChild(node.firstChild);
  };

  const renderOwner = (container, data) => {
    container.appendChild(createSectionHeader('Resumen ejecutivo'));

    const grid = createElement('div', 'ra-dash__grid ra-dash__grid--owner');
    grid.appendChild(renderActivity(data.activity));
    grid.appendChild(renderTasks(data.tasks, 'Bandeja prioritaria'));
    grid.appendChild(renderWorkflows(data.workflows));
    container.appendChild(grid);

    container.appendChild(renderAlerts(data.alerts));
    container.appendChild(renderDecisions(data.decisions));
  };

  const renderActivity = (items = []) => {
    const section = createElement('section', 'ra-dash__card');
    section.appendChild(createSectionTitle('Actividad reciente'));
    const list = createElement('ul', 'ra-dash__list');
    items.forEach((item) => {
      const li = createElement('li', 'ra-dash__list-item');
      const title = createElement('span', 'ra-dash__list-title', item.summary);
      const meta = createElement('span', 'ra-dash__list-meta', `${formatDate(item.ts)} · ${item.actor}`);
      li.append(title, meta);
      list.appendChild(li);
    });
    if (!items.length) {
      list.appendChild(createElement('li', 'ra-dash__empty', 'Sin actividad registrada.'));
    }
    section.appendChild(list);
    return section;
  };

  const renderTasks = (tasks = [], titleText = 'Tareas') => {
    const section = createElement('section', 'ra-dash__card');
    section.appendChild(createSectionTitle(titleText));
    const list = createElement('ul', 'ra-dash__list');
    tasks.forEach((task) => {
      const li = createElement('li', `ra-dash__list-item ra-dash__list-item--priority-${task.priority}`);
      const title = createElement('span', 'ra-dash__list-title', task.title);
      const meta = createElement('span', 'ra-dash__list-meta', `Vence ${formatDate(task.due)}`);
      li.append(title, meta);
      list.appendChild(li);
    });
    if (!tasks.length) {
      list.appendChild(createElement('li', 'ra-dash__empty', 'No hay tareas asignadas.'));
    }
    section.appendChild(list);
    return section;
  };

  const renderWorkflows = (workflows = []) => {
    const section = createElement('section', 'ra-dash__card');
    section.appendChild(createSectionTitle('Automatizaciones QA'));
    const list = createElement('ul', 'ra-dash__list');
    workflows.forEach((wf) => {
      const li = createElement('li', `ra-dash__list-item ra-dash__workflow ra-dash__workflow--${wf.status}`);
      const title = createElement('span', 'ra-dash__list-title', wf.name);
      const meta = createElement('span', 'ra-dash__list-meta', `Actualizado ${formatDate(wf.updated_at)}`);
      li.append(title, meta);
      list.appendChild(li);
    });
    if (!workflows.length) {
      list.appendChild(createElement('li', 'ra-dash__empty', 'Sin corridas registradas.'));
    }
    section.appendChild(list);
    return section;
  };

  const renderAlerts = (alerts) => {
    const section = createElement('section', 'ra-dash__card ra-dash__card--metrics');
    section.appendChild(createSectionTitle('Alertas y métricas'));
    const metrics = createElement('div', 'ra-dash__metrics');
    Object.entries(alerts || {}).forEach(([key, value]) => {
      const metric = createElement('div', `ra-dash__metric ra-dash__metric--${key}`);
      const label = createElement('span', 'ra-dash__metric-label', key.replace(/_/g, ' '));
      const val = createElement('span', 'ra-dash__metric-value', String(value));
      metric.append(label, val);
      metrics.appendChild(metric);
    });
    if (!metrics.childElementCount) {
      metrics.appendChild(createElement('div', 'ra-dash__empty', 'Sin métricas disponibles.'));
    }
    section.appendChild(metrics);
    return section;
  };

  const renderDecisions = (decisions = []) => {
    const section = createElement('section', 'ra-dash__card');
    section.appendChild(createSectionTitle('Decisiones clave'));
    const list = createElement('ul', 'ra-dash__timeline');
    decisions.forEach((decision) => {
      const li = createElement('li', `ra-dash__timeline-item ra-dash__timeline-item--${decision.status}`);
      li.append(createElement('span', 'ra-dash__timeline-title', decision.title));
      li.append(createElement('span', 'ra-dash__timeline-meta', formatDate(decision.ts)));
      list.appendChild(li);
    });
    if (!decisions.length) {
      list.appendChild(createElement('li', 'ra-dash__empty', 'Sin decisiones registradas.'));
    }
    section.appendChild(list);
    return section;
  };

  const renderClientAdmin = (container, data) => {
    container.appendChild(createSectionHeader('Seguimiento diario'));

    const summary = createElement('div', 'ra-dash__banner');
    summary.innerHTML = `<strong>${data.summary.critical}</strong> pendiente crítico · <strong>${data.summary.upcoming}</strong> próximos hitos`;
    container.appendChild(summary);

    const grid = createElement('div', 'ra-dash__grid ra-dash__grid--client-admin');
    grid.appendChild(renderTasks(data.tasks, 'Solicitudes abiertas'));
    grid.appendChild(renderLogins(data.logins));
    container.appendChild(grid);

    container.appendChild(renderGuides(data.guides));
    container.appendChild(renderProgress(data.progress));
  };

  const renderLogins = (logins = []) => {
    const section = createElement('section', 'ra-dash__card');
    section.appendChild(createSectionTitle('Accesos recientes'));
    const list = createElement('ul', 'ra-dash__list');
    logins.forEach((login) => {
      const li = createElement('li', `ra-dash__list-item ra-dash__list-item--login-${login.status}`);
      li.append(createElement('span', 'ra-dash__list-title', login.email));
      li.append(createElement('span', 'ra-dash__list-meta', `${formatDate(login.ts)} · ${login.status === 'success' ? 'Éxito' : 'Fallido'}`));
      list.appendChild(li);
    });
    if (!logins.length) {
      list.appendChild(createElement('li', 'ra-dash__empty', 'Sin inicios de sesión recientes.'));
    }
    section.appendChild(list);
    return section;
  };

  const renderGuides = (guides = []) => {
    const section = createElement('section', 'ra-dash__card ra-dash__card--links');
    section.appendChild(createSectionTitle('Guías destacadas'));
    const list = createElement('ul', 'ra-dash__links');
    guides.forEach((guide) => {
      const item = createElement('li', 'ra-dash__links-item');
      const link = createElement('a', 'ra-dash__link', guide.label);
      link.href = guide.href;
      item.appendChild(link);
      list.appendChild(item);
    });
    if (!guides.length) {
      list.appendChild(createElement('li', 'ra-dash__empty', 'Sin guías configuradas.'));
    }
    section.appendChild(list);
    return section;
  };

  const renderProgress = (items = []) => {
    const section = createElement('section', 'ra-dash__card');
    section.appendChild(createSectionTitle('Progreso de entregables'));
    const list = createElement('ul', 'ra-dash__list');
    items.forEach((item) => {
      const li = createElement('li', 'ra-dash__list-item');
      li.append(createElement('span', 'ra-dash__list-title', `Fase ${item.phase}`));
      li.append(createElement('span', 'ra-dash__list-meta', `${item.percent}% · Próximo hito: ${item.nextMilestone}`));
      list.appendChild(li);
    });
    if (!items.length) {
      list.appendChild(createElement('li', 'ra-dash__empty', 'Sin entregables activos.'));
    }
    section.appendChild(list);
    return section;
  };

  const renderTeam = (container, data) => {
    container.appendChild(createSectionHeader('Operaciones del equipo'));

    const filters = createElement('div', 'ra-dash__filters');
    filters.textContent = `Filtros: ${data.filters.join(' · ')}`;
    container.appendChild(filters);

    container.appendChild(renderKanban(data.kanban));

    const grid = createElement('div', 'ra-dash__grid ra-dash__grid--team');
    grid.appendChild(renderIncidents(data.incidents));
    grid.appendChild(renderDeploys(data.deploys));
    container.appendChild(grid);

    container.appendChild(renderAlerts({ ...data.alerts }));
  };

  const renderKanban = (columns = {}) => {
    const section = createElement('section', 'ra-dash__card ra-dash__card--kanban');
    section.appendChild(createSectionTitle('Tareas en progreso'));
    const board = createElement('div', 'ra-dash__kanban');
    Object.entries(columns).forEach(([column, cards]) => {
      const col = createElement('div', 'ra-dash__kanban-column');
      col.appendChild(createElement('h4', 'ra-dash__kanban-title', column));
      const list = createElement('ul', 'ra-dash__kanban-list');
      cards.forEach((card) => {
        const li = createElement('li', 'ra-dash__kanban-card');
        li.append(createElement('span', 'ra-dash__kanban-card-title', card.title));
        li.append(createElement('span', 'ra-dash__kanban-card-meta', `${card.owner} · ${formatDate(card.due)}`));
        list.appendChild(li);
      });
      if (!cards.length) {
        list.appendChild(createElement('li', 'ra-dash__empty', 'Sin tareas.'));
      }
      col.appendChild(list);
      board.appendChild(col);
    });
    section.appendChild(board);
    return section;
  };

  const renderIncidents = (incidents = []) => {
    const section = createElement('section', 'ra-dash__card');
    section.appendChild(createSectionTitle('Incidencias abiertas'));
    const list = createElement('ul', 'ra-dash__list');
    incidents.forEach((incident) => {
      const li = createElement('li', `ra-dash__list-item ra-dash__list-item--severity-${incident.severity}`);
      li.append(createElement('span', 'ra-dash__list-title', incident.summary));
      li.append(createElement('span', 'ra-dash__list-meta', `Actualizado ${formatDate(incident.updated)}`));
      list.appendChild(li);
    });
    if (!incidents.length) {
      list.appendChild(createElement('li', 'ra-dash__empty', 'Sin incidencias activas.'));
    }
    section.appendChild(list);
    return section;
  };

  const renderDeploys = (deploys = []) => {
    const section = createElement('section', 'ra-dash__card');
    section.appendChild(createSectionTitle('Deploys recientes'));
    const list = createElement('ul', 'ra-dash__list');
    deploys.forEach((deploy) => {
      const li = createElement('li', `ra-dash__list-item ra-dash__list-item--deploy-${deploy.status}`);
      li.append(createElement('span', 'ra-dash__list-title', `Run ${deploy.id}`));
      li.append(createElement('span', 'ra-dash__list-meta', formatDate(deploy.ts)));
      list.appendChild(li);
    });
    if (!deploys.length) {
      list.appendChild(createElement('li', 'ra-dash__empty', 'Sin despliegues registrados.'));
    }
    section.appendChild(list);
    return section;
  };

  const renderClient = (container, data) => {
    const hero = createElement('section', 'ra-dash__card ra-dash__card--hero');
    hero.appendChild(createSectionTitle(data.hero || 'Panel del cliente'));
    container.appendChild(hero);

    const grid = createElement('div', 'ra-dash__grid ra-dash__grid--client');
    grid.appendChild(renderUpdates(data.updates));
    grid.appendChild(renderMilestones(data.milestones));
    container.appendChild(grid);

    container.appendChild(renderForms(data.forms));
    container.appendChild(renderContacts(data.contacts));
  };

  const renderUpdates = (updates = []) => {
    const section = createElement('section', 'ra-dash__card');
    section.appendChild(createSectionTitle('Contenido actualizado'));
    const list = createElement('ul', 'ra-dash__list');
    updates.forEach((item) => {
      const li = createElement('li', 'ra-dash__list-item');
      li.append(createElement('span', 'ra-dash__tag', item.tag || 'Update'));
      li.append(createElement('span', 'ra-dash__list-title', item.title));
      li.append(createElement('span', 'ra-dash__list-meta', formatDate(item.date)));
      list.appendChild(li);
    });
    if (!updates.length) {
      list.appendChild(createElement('li', 'ra-dash__empty', 'Sin actualizaciones recientes.'));
    }
    section.appendChild(list);
    return section;
  };

  const renderMilestones = (milestones = []) => {
    const section = createElement('section', 'ra-dash__card');
    section.appendChild(createSectionTitle('Próximos hitos'));
    const list = createElement('ul', 'ra-dash__list');
    milestones.forEach((item) => {
      const li = createElement('li', 'ra-dash__list-item');
      li.append(createElement('span', 'ra-dash__list-title', item.title));
      li.append(createElement('span', 'ra-dash__list-meta', `${formatDate(item.date)} · ${item.responsible}`));
      list.appendChild(li);
    });
    if (!milestones.length) {
      list.appendChild(createElement('li', 'ra-dash__empty', 'Sin hitos próximos.'));
    }
    section.appendChild(list);
    return section;
  };

  const renderForms = (forms = []) => {
    const section = createElement('section', 'ra-dash__card ra-dash__card--links');
    section.appendChild(createSectionTitle('Formularios activos'));
    const list = createElement('ul', 'ra-dash__links');
    forms.forEach((form) => {
      const item = createElement('li', 'ra-dash__links-item');
      const link = createElement('a', 'ra-dash__link', form.title);
      link.href = form.href;
      item.appendChild(link);
      item.appendChild(createElement('span', 'ra-dash__list-meta', `Fecha límite: ${formatDate(form.deadline)}`));
      list.appendChild(item);
    });
    if (!forms.length) {
      list.appendChild(createElement('li', 'ra-dash__empty', 'No hay formularios pendientes.'));
    }
    section.appendChild(list);
    return section;
  };

  const renderContacts = (contacts = []) => {
    const section = createElement('section', 'ra-dash__card');
    section.appendChild(createSectionTitle('Soporte y contactos'));
    const list = createElement('ul', 'ra-dash__list');
    contacts.forEach((contact) => {
      const li = createElement('li', 'ra-dash__list-item');
      li.append(createElement('span', 'ra-dash__list-title', contact.name));
      li.append(createElement('span', 'ra-dash__list-meta', `${contact.email} · ${contact.availability}`));
      list.appendChild(li);
    });
    if (!contacts.length) {
      list.appendChild(createElement('li', 'ra-dash__empty', 'Sin contactos configurados.'));
    }
    section.appendChild(list);
    return section;
  };

  const renderVisitor = (container, data) => {
    const hero = createElement('section', 'ra-dash__card ra-dash__card--hero');
    hero.appendChild(createSectionTitle(data.hero?.message || 'Bienvenido'));
    const cta = createElement('button', 'ra-dash__cta', data.hero?.cta || 'Solicitar acceso');
    cta.addEventListener('click', () => {
      if (data.access?.href) {
        window.open(data.access.href, '_blank', 'noopener');
      } else if (data.access?.fallback) {
        window.location.href = `mailto:${data.access.fallback}`;
      }
    });
    hero.appendChild(cta);
    container.appendChild(hero);

    container.appendChild(renderPublicDocs(data.publicDocs));
    container.appendChild(renderNews(data.news));
  };

  const renderPublicDocs = (docs = []) => {
    const section = createElement('section', 'ra-dash__card');
    section.appendChild(createSectionTitle('Documentos públicos'));
    const list = createElement('ul', 'ra-dash__list');
    docs.forEach((doc) => {
      const li = createElement('li', 'ra-dash__list-item');
      li.append(createElement('span', 'ra-dash__tag', doc.type));
      const link = createElement('a', 'ra-dash__link', doc.title);
      link.href = doc.href;
      link.rel = 'noopener';
      li.append(link);
      list.appendChild(li);
    });
    if (!docs.length) {
      list.appendChild(createElement('li', 'ra-dash__empty', 'Próximamente nuevos recursos.'));
    }
    section.appendChild(list);
    return section;
  };

  const renderNews = (news = []) => {
    const section = createElement('section', 'ra-dash__card');
    section.appendChild(createSectionTitle('Noticias destacadas'));
    const list = createElement('ul', 'ra-dash__list');
    news.forEach((item) => {
      const li = createElement('li', 'ra-dash__list-item');
      li.append(createElement('span', 'ra-dash__list-title', item.title));
      li.append(createElement('span', 'ra-dash__list-meta', formatDate(item.date)));
      list.appendChild(li);
    });
    if (!news.length) {
      list.appendChild(createElement('li', 'ra-dash__empty', 'Sin noticias recientes.'));
    }
    section.appendChild(list);
    return section;
  };

  const createSectionHeader = (title) => {
    const header = createElement('header', 'ra-dash__header');
    header.appendChild(createElement('h2', 'ra-dash__headline', title));
    return header;
  };

  const createSectionTitle = (title) => createElement('h3', 'ra-dash__title', title);

  const renderRole = (role, container) => {
    const data = DATA[role];
    if (!data) {
      container.appendChild(createElement('p', 'ra-dash__empty', 'Rol sin datos de ejemplo.'));
      return;
    }

    const inner = createElement('div', `ra-dash ra-dash--${role}`);
    switch (role) {
      case 'owner':
        renderOwner(inner, data);
        break;
      case 'client_admin':
        renderClientAdmin(inner, data);
        break;
      case 'team':
        renderTeam(inner, data);
        break;
      case 'client':
        renderClient(inner, data);
        break;
      case 'visitor':
      default:
        renderVisitor(inner, data);
        break;
    }
    container.appendChild(inner);
  };

  const init = () => {
    const nodes = document.querySelectorAll('[data-runart-dashboard]');
    if (!nodes.length) return;
    nodes.forEach((node) => {
      const role = node.getAttribute('data-runart-dashboard');
      clearNode(node);
      renderRole(role, node);
    });

    if (typeof window !== 'undefined') {
      window.__RA_DEBUG_DASH = {
        render: (role) => {
          nodes.forEach((node) => {
            clearNode(node);
            renderRole(role || node.getAttribute('data-runart-dashboard'), node);
          });
        },
      };
    }
  };

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init, { once: true });
  } else {
    init();
  }
})();
