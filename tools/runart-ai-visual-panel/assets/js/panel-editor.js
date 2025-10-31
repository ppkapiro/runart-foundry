/* RunArt AI Visual Panel - Editor Mode (ES5)
   Two-step load: IA first (fast), WP pages async with timeout.
*/
(function(){
    'use strict';

    function log() {
        var args = Array.prototype.slice.call(arguments);
        args.unshift('[runart-ai-visual]');
        if (window.console && console.log) {
            console.log.apply(console, args);
        }
    }

    function $(id) { return document.getElementById(id); }

    function fetchWithTimeout(url, options, timeoutMs) {
        return new Promise(function(resolve, reject) {
            var ctrl;
            if (typeof AbortController !== 'undefined') {
                ctrl = new AbortController();
                var timer = setTimeout(function() {
                    ctrl.abort();
                    reject(new Error('timeout'));
                }, timeoutMs);
                var opts = Object.assign({}, options || {}, { signal: ctrl.signal });
                fetch(url, opts).then(function(r) {
                    clearTimeout(timer);
                    resolve(r);
                }).catch(function(err) {
                    clearTimeout(timer);
                    reject(err);
                });
            } else {
                var done = false;
                var timer2 = setTimeout(function() {
                    done = true;
                    reject(new Error('timeout'));
                }, timeoutMs);
                fetch(url, options).then(function(r) {
                    if (done) return;
                    clearTimeout(timer2);
                    resolve(r);
                }).catch(function(err) {
                    if (done) return;
                    clearTimeout(timer2);
                    reject(err);
                });
            }
        });
    }

    function initPanel() {
        var container = $('runart-ai-visual-panel');
        if (!container) { return; }

        var statusEl = $('runart-aivp-status');
        var listEl = $('runart-aivp-list');
        var detailEl = $('runart-aivp-detail');
        if (detailEl) { detailEl.innerHTML = ''; }

        var iaItems = [];
        var wpItems = [];
        var mergedMap = {};
        var ordered = [];

        var nonce = (typeof RUNART_AIVP !== 'undefined' && RUNART_AIVP.nonce) ? RUNART_AIVP.nonce : '';
        var restBase = (typeof RUNART_AIVP !== 'undefined' && RUNART_AIVP.restUrl) ? RUNART_AIVP.restUrl : (window.location.origin + '/wp-json/');
        if (restBase.slice(-1) !== '/') { restBase += '/'; }

        var commonHeaders = { 'X-WP-Nonce': nonce };

        statusEl.innerHTML = 'Cargando contenidos IA…';
        listEl.innerHTML = '<div style="padding:8px;color:#999;">Cargando…</div>';

        // PASO A: Carga rápida IA
        fetch(restBase + 'runart/content/enriched-list', {
            credentials: 'include',
            headers: commonHeaders
        })
        .then(function(r){ return r.json(); })
        .then(function(data){
            log('IA fetch OK', data);
            if (data && data.items && data.items.length) {
                iaItems = data.items.map(normalizeItem);
                statusEl.innerHTML = '<span style="color:#3b82f6;font-weight:600;">✓ IA (' + iaItems.length + ')</span> <span style="color:#999;font-size:13px;margin-left:8px;">Cargando páginas WP…</span>';
                render();
            } else {
                statusEl.innerHTML = '<span style="color:#999;">No hay contenidos IA todavía.</span> <span style="color:#999;font-size:13px;margin-left:8px;">Cargando páginas WP…</span>';
                render();
            }
        })
        .catch(function(err){
            log('IA fetch error:', err);
            statusEl.innerHTML = '<span style="color:#c00;">Error leyendo IA.</span> <span style="color:#999;font-size:13px;margin-left:8px;">Cargando páginas WP…</span>';
            listEl.innerHTML = '<div style="padding:8px;color:#c00;">No fue posible leer los contenidos IA.</div>';
        });

        // PASO B: Carga asíncrona WP con timeout 5s
        fetchWithTimeout(restBase + 'runart/content/wp-pages?per_page=25&page=1', {
            credentials: 'include',
            headers: commonHeaders
        }, 5000)
        .then(function(resp){ return resp.json(); })
        .then(function(data){
            log('WP fetch OK', data);
            if (data && data.ok && data.pages && data.pages.length) {
                wpItems = data.pages.map(normalizeItem);
                statusEl.innerHTML = '<span style="color:#3b82f6;font-weight:600;">✓ IA (' + iaItems.length + ')</span> <span style="color:#10b981;font-weight:600;margin-left:12px;">✓ WP (' + wpItems.length + ')</span>';
                render();
            } else {
                statusEl.innerHTML = '<span style="color:#3b82f6;font-weight:600;">✓ IA (' + iaItems.length + ')</span> <span style="color:#f59e0b;margin-left:12px;">⚠ WP sin datos.</span>';
            }
        })
        .catch(function(err){
            log('WP fetch failed/timeout:', err);
            var msg = err.message === 'timeout' ? 'WP lento o sin respuesta.' : 'WP no disponible.';
            statusEl.innerHTML = '<span style="color:#3b82f6;font-weight:600;">✓ IA (' + iaItems.length + ')</span> <span style="color:#f59e0b;margin-left:12px;">⚠ ' + msg + '</span>';
        });

        function normalizeItem(raw) {
            var id = raw.id || raw.page_id || (raw.wp_id ? ('page_' + raw.wp_id) : '');
            if (!id) return null;
            return {
                id: id,
                wp_id: raw.wp_id || null,
                title: raw.title || id,
                slug: raw.slug || '',
                lang: raw.lang || 'es',
                status: raw.status || 'pending',
                source: raw.source || 'unknown'
            };
        }

        function render() {
            mergedMap = {};
            ordered = [];

            iaItems.forEach(function(item){
                if (!item) return;
                mergedMap[item.id] = item;
                ordered.push(item.id);
            });

            wpItems.forEach(function(item){
                if (!item) return;
                if (mergedMap[item.id]) {
                    if (!mergedMap[item.id].wp_id && item.wp_id) {
                        mergedMap[item.id].wp_id = item.wp_id;
                    }
                    if (mergedMap[item.id].status === 'pending' && item.status !== 'pending') {
                        mergedMap[item.id].status = item.status;
                    }
                    mergedMap[item.id].source = 'hybrid';
                } else {
                    mergedMap[item.id] = item;
                    ordered.push(item.id);
                }
            });

            if (ordered.length === 0) {
                listEl.innerHTML = '<div style="padding:12px;color:#999;text-align:center;">No hay contenidos para mostrar.</div>';
                return;
            }

            var html = '';
            for (var k = 0; k < ordered.length; k++) {
                var item = mergedMap[ordered[k]];
                if (!item) continue;

                var statusColor = item.status === 'pending' ? '#999' : (item.status === 'generated' ? '#3b82f6' : '#10b981');
                var statusLabel = item.status === 'pending' ? 'Pendiente' : (item.status === 'generated' ? 'Generado' : item.status);
                var lang = item.lang ? item.lang.toUpperCase() : '';

                var btn = '';
                if (item.status === 'pending' && item.wp_id) {
                    btn = '<button onclick="window.runartRequestGeneration(\'' + escapeAttr(item.id) + '\',\'' + escapeAttr(item.slug) + '\',\'' + escapeAttr(item.lang) + '\')" style="margin-left:8px;padding:2px 8px;font-size:11px;background:#3b82f6;color:#fff;border:none;border-radius:3px;cursor:pointer;">Generar IA</button>';
                }

                html += '<div class="runart-aivp-item" style="padding:8px;border-bottom:1px solid #f0f0f0;">' +
                    '<strong>' + escapeHtml(item.title) + '</strong>' +
                    (lang ? ' <span style="color:#666;font-size:12px;margin-left:6px;">' + lang + '</span>' : '') +
                    (item.wp_id ? ' <span style="color:#999;font-size:12px;margin-left:4px;">ID ' + escapeHtml(item.wp_id) + '</span>' : '') +
                    '<span style="float:right;color:' + statusColor + ';font-size:12px;">' + escapeHtml(statusLabel) + btn + '</span>' +
                    '</div>';
            }
            listEl.innerHTML = html;
        }

        window.runartRequestGeneration = function(id, slug, lang) {
            log('Request generation:', id, slug, lang);
            var wpId = id.match(/page_(\d+)/);
            if (!wpId || !wpId[1]) {
                alert('ID inválido: ' + id);
                return;
            }

            var payload = {
                wp_id: parseInt(wpId[1], 10),
                slug: slug || '',
                lang: lang || 'es',
                assistant: 'ia-visual'
            };

            fetch(restBase + 'runart/content/enriched-request', {
                method: 'POST',
                credentials: 'include',
                headers: Object.assign({}, commonHeaders, { 'Content-Type': 'application/json' }),
                body: JSON.stringify(payload)
            })
            .then(function(r){ return r.json(); })
            .then(function(data){
                log('Request response:', data);
                if (data.ok) {
                    alert('✓ Solicitud enviada. Se procesará en el próximo ciclo de IA.');
                } else if (data.status === 'readonly') {
                    alert('⚠ Solicitud registrada (staging readonly). Se procesará en CI.');
                } else {
                    alert('Error: ' + (data.message || 'Fallo al registrar solicitud'));
                }
            })
            .catch(function(err){
                log('Request error:', err);
                alert('Error enviando solicitud: ' + err.message);
            });
        };

        function escapeHtml(str) {
            return String(str).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
        }

        function escapeAttr(str) {
            return String(str).replace(/'/g, '&#39;').replace(/"/g, '&quot;');
        }
    }

    if (document.readyState === 'complete' || document.readyState === 'interactive') {
        setTimeout(initPanel, 1);
    } else {
        document.addEventListener('DOMContentLoaded', initPanel);
    }

})();
