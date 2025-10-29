(function () {
  const WHOAMI_URL = '/api/whoami';
  const ROLE_ROUTES = {
    owner: '/internal/briefing_system/',
    client_admin: '/internal/briefing_system/',
    team: '/internal/briefing_system/',
    client: '/client_projects/runart_foundry/',
    visitor: '/',
  };
  const ROLE_LABELS = {
    owner: 'Owner',
    client_admin: 'Client admin',
    team: 'Team',
    client: 'Client',
    visitor: 'Visitor',
  };
  const FALLBACK_STATE = {
    ok: false,
    email: '',
    role: 'visitor',
    env: 'local',
  };

  const createElement = (tag, className, attributes) => {
    const element = document.createElement(tag);
    if (className) {
      element.className = className;
    }
    if (attributes) {
      Object.entries(attributes).forEach(([key, value]) => {
        if (value !== undefined && value !== null) {
          element.setAttribute(key, value);
        }
      });
    }
    return element;
  };

  const normalizeRole = (roleValue) => {
    if (!roleValue) return 'visitor';
    const normalized = String(roleValue).trim().toLowerCase();
    if (normalized === 'visitante') return 'visitor';
    if (normalized === 'propietario') return 'owner';
    if (normalized === 'equipo' || normalized === 'team') return 'team';
    if (normalized === 'cliente_admin' || normalized === 'client_admin' || normalized === 'client-admin') return 'client_admin';
    if (normalized === 'cliente' || normalized === 'client') return 'client';
    if (ROLE_LABELS[normalized]) return normalized;
    return 'visitor';
  };

  const buildUserbar = () => {
    const root = createElement('div', 'ra-userbar', { id: 'ra-userbar' });
    const button = createElement('button', 'ra-userbar__button', {
      type: 'button',
      'aria-haspopup': 'true',
      'aria-expanded': 'false',
      'aria-controls': 'ra-userbar-menu',
    });

    const avatar = createElement('span', 'ra-userbar__avatar', { 'aria-hidden': 'true' });
    avatar.textContent = '…';

    const info = createElement('span', 'ra-userbar__info');
    const email = createElement('span', 'ra-userbar__email');
    email.textContent = 'Cargando…';

    const role = createElement('span', 'ra-userbar__role', {
      'data-role': 'visitor',
      'aria-label': 'Rol Visitor',
    });
    role.textContent = 'visitor';

    info.appendChild(email);
    info.appendChild(role);

    button.appendChild(avatar);
    button.appendChild(info);

    const menuContainer = createElement('div', 'ra-userbar__menu-container');
    const menu = createElement('ul', 'ra-userbar__menu', {
      id: 'ra-userbar-menu',
      role: 'menu',
      hidden: '',
    });

    const menuItemWrapper1 = createElement('li', 'ra-userbar__menu-item');
    const myTab = createElement('a', 'ra-userbar__menu-link', {
      role: 'menuitem',
      tabindex: '-1',
      href: '/',
    });
    myTab.textContent = 'Mi pestaña';
    menuItemWrapper1.appendChild(myTab);

    const menuItemWrapperAdmin = createElement('li', 'ra-userbar__menu-item ra-userbar__menu-item--admin');
    const adminLink = createElement('a', 'ra-userbar__menu-link', {
      role: 'menuitem',
      tabindex: '-1',
      href: '/internal/briefing_system/ops/roles_admin/',
    });
    adminLink.textContent = 'Administrar roles';
    menuItemWrapperAdmin.appendChild(adminLink);

    const menuItemWrapper2 = createElement('li', 'ra-userbar__menu-item');
    const logoutButton = createElement('button', 'ra-userbar__menu-link ra-userbar__menu-link--logout', {
      type: 'button',
      role: 'menuitem',
      tabindex: '-1',
    });
    logoutButton.textContent = 'Salir';
    menuItemWrapper2.appendChild(logoutButton);

  menu.appendChild(menuItemWrapper1);
  menu.appendChild(menuItemWrapperAdmin);
    menu.appendChild(menuItemWrapper2);

    menuContainer.appendChild(menu);

    root.appendChild(button);
    root.appendChild(menuContainer);

    return {
      root,
      button,
      avatar,
      email,
      role,
      menu,
      menuLinks: [myTab, adminLink, logoutButton],
      myTab,
      adminLink,
      logoutButton,
    };
  };

  const applyState = (ui, state) => {
    const emailValue = (state.email || '').trim();
    const normalizedRole = normalizeRole(state.role || 'visitor');
    const roleLabel = ROLE_LABELS[normalizedRole] || ROLE_LABELS.visitor;

  const avatarInitial = emailValue ? emailValue.charAt(0).toUpperCase() : 'I';
    ui.avatar.textContent = avatarInitial;
    ui.avatar.dataset.role = normalizedRole;

    ui.email.textContent = emailValue || 'Invitado';
    ui.role.textContent = roleLabel.toLowerCase();
    ui.role.dataset.role = normalizedRole;
    ui.role.setAttribute('aria-label', `Rol ${roleLabel}`);

    const targetHref = ROLE_ROUTES[normalizedRole] || ROLE_ROUTES.visitor;
    ui.myTab.href = targetHref;

    if (normalizedRole === 'owner' || normalizedRole === 'client_admin') {
      ui.adminLink.parentElement.removeAttribute('hidden');
      ui.adminLink.setAttribute('tabindex', '0');
    } else {
      ui.adminLink.parentElement.setAttribute('hidden', 'hidden');
      ui.adminLink.setAttribute('tabindex', '-1');
    }

    document.documentElement.dataset.runenv = state.env || 'local';
  };

  const closeMenu = (ui, options = {}) => {
    const { restoreFocus = false } = options;
    if (ui.menu.hasAttribute('hidden')) {
      return;
    }

    ui.button.setAttribute('aria-expanded', 'false');
    ui.menu.setAttribute('hidden', '');
    ui.menuLinks.forEach((link) => {
      link.setAttribute('tabindex', '-1');
    });

    if (restoreFocus) {
      ui.button.focus({ preventScroll: true });
    }
  };

  const openMenu = (ui) => {
    if (!ui.menu.hasAttribute('hidden')) {
      return;
    }

    ui.button.setAttribute('aria-expanded', 'true');
    ui.menu.removeAttribute('hidden');
    let focused = false;
    ui.menuLinks.forEach((link) => {
      const parentHidden = link.parentElement?.hasAttribute('hidden');
      if (parentHidden) {
        link.setAttribute('tabindex', '-1');
        return;
      }
      link.setAttribute('tabindex', '0');
      if (!focused) {
        focused = true;
        link.focus({ preventScroll: true });
      }
    });
    if (!focused) {
      ui.menuLinks[0].focus({ preventScroll: true });
    }
  };

  const toggleMenu = (ui) => {
    if (ui.menu.hasAttribute('hidden')) {
      openMenu(ui);
    } else {
      closeMenu(ui, { restoreFocus: true });
    }
  };

  const initEvents = (ui) => {
    let pointerDownListener = null;

    const handleOutsideClick = (event) => {
      if (!ui.root.contains(event.target)) {
        closeMenu(ui, { restoreFocus: false });
        detachOutside();
      }
    };

    const attachOutside = () => {
      if (pointerDownListener) return;
      pointerDownListener = handleOutsideClick;
      document.addEventListener('pointerdown', pointerDownListener, { passive: true });
    };

    const detachOutside = () => {
      if (!pointerDownListener) return;
      document.removeEventListener('pointerdown', pointerDownListener);
      pointerDownListener = null;
    };

    ui.button.addEventListener('click', (event) => {
      event.preventDefault();
      const willOpen = ui.menu.hasAttribute('hidden');
      toggleMenu(ui);
      if (willOpen) {
        attachOutside();
      } else {
        detachOutside();
      }
    });

    ui.button.addEventListener('keydown', (event) => {
      const key = event.key;
      if (key === 'Enter' || key === ' ') {
        event.preventDefault();
        const willOpen = ui.menu.hasAttribute('hidden');
        toggleMenu(ui);
        if (willOpen) {
          attachOutside();
        } else {
          detachOutside();
        }
      } else if (key === 'ArrowDown') {
        event.preventDefault();
        openMenu(ui);
        attachOutside();
      } else if (key === 'Escape') {
        event.preventDefault();
        closeMenu(ui, { restoreFocus: true });
        detachOutside();
      }
    });

    ui.menu.addEventListener('keydown', (event) => {
      const key = event.key;
      if (key === 'Escape') {
        event.preventDefault();
        closeMenu(ui, { restoreFocus: true });
        detachOutside();
        return;
      }
      if (key === 'Tab') {
        closeMenu(ui, { restoreFocus: false });
        detachOutside();
      }
    });

    ui.menu.addEventListener('focusout', (event) => {
      if (!ui.root.contains(event.relatedTarget)) {
        closeMenu(ui, { restoreFocus: false });
        detachOutside();
      }
    });

    ui.logoutButton.addEventListener('click', (event) => {
      event.preventDefault();
      const origin = window.location.origin;
      window.location.href = `${origin}/cdn-cgi/access/logout?return_to=/`;
    });
  };

  const mount = (ui) => {
    const header = document.querySelector('.md-header__inner');
    if (!header) {
      return false;
    }

    if (document.getElementById('ra-userbar')) {
      return true;
    }

    const searchButton = header.querySelector('.md-header__button--search');
    if (searchButton && searchButton.parentElement === header) {
      header.insertBefore(ui.root, searchButton);
    } else {
      header.appendChild(ui.root);
    }
    return true;
  };

  const fetchWhoami = async () => {
    try {
      const response = await fetch(WHOAMI_URL, {
        credentials: 'include',
        headers: { 'Accept': 'application/json' },
      });

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }

      const data = await response.json();
      return {
        ok: true,
        email: typeof data.email === 'string' ? data.email : '',
        role: normalizeRole(data.role || data.rol),
        env: typeof data.env === 'string' ? data.env : 'local',
      };
    } catch (error) {
      console.warn('[Userbar] Fallback visitor mode', error);
      return { ...FALLBACK_STATE };
    }
  };

  const init = async () => {
    const ui = buildUserbar();
    const mounted = mount(ui);
    if (!mounted) {
      return;
    }

    initEvents(ui);

    if (typeof window !== 'undefined') {
      window.__RA_DEBUG_USERBAR = {
        applyState: (data = {}) => {
          const nextState = {
            ...FALLBACK_STATE,
            ...data,
            role: normalizeRole(data.role || FALLBACK_STATE.role),
          };
          applyState(ui, nextState);
        },
        close: () => closeMenu(ui, { restoreFocus: false }),
      };
    }

    const state = await fetchWhoami();
    applyState(ui, state);
  };

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init, { once: true });
  } else {
    init();
  }
})();
