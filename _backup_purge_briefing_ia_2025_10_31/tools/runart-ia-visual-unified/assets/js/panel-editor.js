/**
 * Archivo: panel-editor.js
 * Descripción: JS del panel IA-Visual. Lógica de interacción con endpoints REST.
 * Fuente: Migrado desde plugin maestro líneas 2078-2626
 */

(function() {
    'use strict';
    
    // Esperar a que el DOM esté listo
    document.addEventListener('DOMContentLoaded', function() {
        // Verificar que el panel existe
        const panel = document.getElementById('runart-editorial-panel');
        if (!panel) {
            console.log('RunArt IA-Visual: Panel not found in DOM');
            return;
        }
        
        // Obtener configuración desde window.RUNART_MONITOR
        const config = window.RUNART_MONITOR || {};
        const base = config.restUrl || (window.location.origin + '/wp-json/runart/');
        const authHeaders = { 'X-WP-Nonce': config.nonce || '' };
        
        const listContainer = document.getElementById('rep-content-list');
        const detailContainer = document.getElementById('rep-content-detail');
        
        if (!listContainer || !detailContainer) {
            console.error('RunArt IA-Visual: Required containers not found');
            return;
        }
        
        let currentItems = [];
        let statusHtml = '';
        let currentStats = { total: 0, generated: 0, pending: 0 };
        
        // Funciones auxiliares
        function setStatus(message, tone) {
            const colors = {
                info: { bg: '#eef2ff', fg: '#3730a3' },
                warn: { bg: '#fff7ed', fg: '#9a3412' },
                ok:   { bg: '#ecfdf5', fg: '#065f46' }
            };
            const c = colors[tone || 'info'];
            statusHtml = '<div style="margin-bottom:8px;padding:8px 10px;background:' + c.bg + ';color:' + c.fg + ';border-radius:4px;font-size:12px;">' + message + '</div>';
        }
        
        // Fetch con timeout
        function fetchWithTimeout(url, options, timeoutMs) {
            const ctrl = new AbortController();
            const id = setTimeout(function() { ctrl.abort(); }, timeoutMs);
            const opts = Object.assign({}, options || {}, { signal: ctrl.signal });
            return fetch(url, opts).finally(function() { clearTimeout(id); });
        }
        
        // Fusionar páginas WP con items IA
        function mergeWpPages(wpItems) {
            const map = new Map();
            currentItems.forEach(function(it) {
                map.set(it.id || it.ia_id, it);
            });

            wpItems.forEach(function(p) {
                const idStr = p.id || ('page_' + (p.wp_id || ''));
                if (!idStr) return;
                if (map.has(idStr)) {
                    const ref = map.get(idStr);
                    if (!ref.wp_id && p.wp_id) ref.wp_id = p.wp_id;
                    if (!ref.lang && p.lang) ref.lang = p.lang;
                } else {
                    map.set(idStr, {
                        id: idStr,
                        wp_id: p.wp_id,
                        title: p.title || idStr,
                        lang: p.lang || 'es',
                        status: 'pending'
                    });
                }
            });

            currentItems = Array.from(map.values());
            const generated = currentItems.filter(function(i) {
                return i.status && i.status !== 'pending';
            }).length;
            currentStats = {
                total: currentItems.length,
                generated: generated,
                pending: Math.max(0, currentItems.length - generated)
            };
            renderList(currentItems, currentStats);
        }
        
        // Renderizar lista
        function renderList(items, stats) {
            let html = statusHtml;
            html += '<div style="font-size:12px;color:#666;margin-bottom:8px;">Total: ' + stats.total + ' | Generados: ' + stats.generated + ' | Pendientes: ' + stats.pending + '</div>';
            
            items.forEach(function(item) {
                const statusColor = item.status === 'approved' ? '#10b981' : (item.status === 'pending' ? '#f59e0b' : '#6b7280');
                html += '<div style="padding:8px;margin-bottom:6px;border:1px solid #e5e7eb;border-radius:4px;cursor:pointer;background:#fff;" data-id="' + item.id + '">';
                html += '<div style="font-weight:600;font-size:13px;">' + item.title + '</div>';
                html += '<div style="font-size:11px;color:#999;margin-top:2px;">';
                html += '<span style="color:' + statusColor + ';">● ' + item.status + '</span>';
                html += ' | ' + item.lang;
                html += '</div>';
                html += '</div>';
            });
            
            if (items.length === 0) {
                html += '<div style="text-align:center;padding:20px;color:#999;">No hay contenidos disponibles</div>';
            }
            
            listContainer.innerHTML = html;
            
            // Event listeners
            const itemDivs = listContainer.querySelectorAll('[data-id]');
            itemDivs.forEach(function(div) {
                div.addEventListener('click', function() {
                    const id = this.getAttribute('data-id');
                    const item = items.find(function(i) { return i.id === id; });
                    if (item) showDetail(item);
                });
            });
        }
        
        // Mostrar detalle
        function showDetail(item) {
            let html = '<h3 style="margin-top:0;">' + item.title + '</h3>';
            html += '<p><strong>ID:</strong> ' + item.id + '</p>';
            html += '<p><strong>Estado:</strong> ' + item.status + '</p>';
            html += '<p><strong>Idioma:</strong> ' + item.lang + '</p>';
            if (item.wp_id) {
                html += '<p><strong>WP ID:</strong> ' + item.wp_id + '</p>';
            }
            
            html += '<div style="margin-top:16px;">';
            html += '<button class="button button-primary" data-action="approve" data-id="' + item.id + '">Aprobar</button> ';
            html += '<button class="button" data-action="reject" data-id="' + item.id + '">Rechazar</button>';
            html += '</div>';
            
            detailContainer.innerHTML = html;
            
            // Event listeners para botones
            const buttons = detailContainer.querySelectorAll('[data-action]');
            buttons.forEach(function(btn) {
                btn.addEventListener('click', function() {
                    const action = this.getAttribute('data-action');
                    const id = this.getAttribute('data-id');
                    handleAction(action, id);
                });
            });
        }
        
        // Manejar acciones
        function handleAction(action, id) {
            const status = action === 'approve' ? 'approved' : 'rejected';
            
            fetch(base + 'content/enriched-approve', {
                method: 'POST',
                credentials: 'include',
                headers: Object.assign({}, authHeaders, {
                    'Content-Type': 'application/json'
                }),
                body: JSON.stringify({ id: id, status: status })
            })
            .then(function(r) { return r.json(); })
            .then(function(data) {
                if (data.ok || data.status === 'queued') {
                    setStatus('Acción registrada: ' + status, 'ok');
                    loadList(); // Recargar
                } else {
                    setStatus('Error al registrar acción', 'warn');
                }
            })
            .catch(function(err) {
                console.error('Error:', err);
                setStatus('Error de conexión', 'warn');
            });
        }
        
        // Cargar lista
        function loadList() {
            setStatus('Cargando contenidos IA…', 'info');
            listContainer.innerHTML = '<div style="text-align:center;padding:16px;color:#666;">Cargando contenidos IA…</div>';

            // Fetch IA
            fetch(base + 'content/enriched-list', {
                credentials: 'include',
                headers: authHeaders
            })
            .then(function(r) { return r.json(); })
            .then(function(iaData) {
                if (iaData && iaData.ok && Array.isArray(iaData.items)) {
                    currentItems = iaData.items;
                    const generated = currentItems.filter(function(i) {
                        return i.status && i.status !== 'pending';
                    }).length;
                    currentStats = {
                        total: currentItems.length,
                        generated: generated,
                        pending: Math.max(0, currentItems.length - generated)
                    };
                    setStatus('Contenidos IA cargados (' + currentItems.length + ')', 'ok');
                    renderList(currentItems, currentStats);
                    
                    // Cargar WP en paralelo
                    fetchWithTimeout(base + 'content/wp-pages?per_page=25&page=1', {
                        credentials: 'include',
                        headers: authHeaders
                    }, 5000)
                    .then(function(r) { return r.json(); })
                    .then(function(wpData) {
                        if (wpData && wpData.ok && Array.isArray(wpData.items)) {
                            mergeWpPages(wpData.items);
                            setStatus('Páginas WP fusionadas.', 'ok');
                        }
                    })
                    .catch(function(err) {
                        console.warn('WP pages fetch failed:', err);
                        setStatus('WP lento o sin respuesta. Mostrando solo IA.', 'warn');
                        renderList(currentItems, currentStats);
                    });
                } else {
                    setStatus('No se pudieron cargar contenidos IA', 'warn');
                    listContainer.innerHTML = '<div style="text-align:center;padding:20px;color:#999;">No hay contenidos disponibles</div>';
                }
            })
            .catch(function(err) {
                console.error('IA list fetch error:', err);
                setStatus('Error al cargar contenidos', 'warn');
                listContainer.innerHTML = '<div style="text-align:center;padding:20px;color:#f59e0b;">Error de conexión</div>';
            });
        }
        
        // Inicializar
        console.log('RunArt IA-Visual Panel initialized');
        loadList();
    });
})();

(function() {
    'use strict';
    
    // TODO: Decidir si implementar aquí o mantener inline
    // Si externo, descomentar y migrar lógica:
    
    /*
    document.addEventListener('DOMContentLoaded', function() {
        const panel = document.getElementById('runart-ai-visual-panel');
        if (!panel) return;
        
        const apiUrl = runartIAVisual.apiUrl; // Pasado por wp_localize_script
        const nonce = runartIAVisual.nonce;
        
        // Función para cargar lista de contenido
        function loadContent() {
            fetch(apiUrl + '/enriched/list', {
                headers: {
                    'X-WP-Nonce': nonce
                }
            })
            .then(res => res.json())
            .then(data => {
                if (data.ok) {
                    renderContent(data.items);
                }
            });
        }
        
        // Función para renderizar contenido
        function renderContent(items) {
            const container = document.getElementById('runart-panel-content');
            // TODO: Implementar renderizado de tabla
            container.innerHTML = '<p>Contenido cargado: ' + items.length + ' items</p>';
        }
        
        // Inicializar
        loadContent();
    });
    */
    
    console.log('RunArt IA-Visual Panel JS loaded (placeholder)');
})();
