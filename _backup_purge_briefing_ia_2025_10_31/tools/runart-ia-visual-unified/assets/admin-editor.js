/**
 * JavaScript para el backend editable IA-Visual
 * FASE 4.A
 */

(function($) {
    'use strict';
    
    // Variables globales
    var currentEditingPage = null;
    
    /**
     * Inicialización cuando el DOM está listo
     */
    $(document).ready(function() {
        initSearch();
        initFilters();
        initEditButtons();
        initDeleteButtons();
        initModal();
    });
    
    /**
     * Búsqueda de contenido
     */
    function initSearch() {
        $('#btn-search, #search-content').on('click keyup', function(e) {
            if (e.type === 'keyup' && e.keyCode !== 13) {
                return;
            }
            
            var searchTerm = $('#search-content').val().toLowerCase();
            
            $('table tbody tr').each(function() {
                var $row = $(this);
                var pageId = $row.data('page-id') || '';
                var text = $row.text().toLowerCase();
                
                if (text.indexOf(searchTerm) > -1 || searchTerm === '') {
                    $row.show();
                } else {
                    $row.hide();
                }
            });
        });
    }
    
    /**
     * Filtros por estado
     */
    function initFilters() {
        $('.runart-filters input[type="checkbox"]').on('change', function() {
            var showApproved = $('#filter-approved').is(':checked');
            var showPending = $('#filter-pending').is(':checked');
            var showRejected = $('#filter-rejected').is(':checked');
            
            $('table tbody tr[data-status]').each(function() {
                var $row = $(this);
                var status = $row.data('status');
                var shouldShow = false;
                
                if (status === 'approved' && showApproved) shouldShow = true;
                if (status === 'pending' && showPending) shouldShow = true;
                if (status === 'rejected' && showRejected) shouldShow = true;
                
                if (shouldShow) {
                    $row.show();
                } else {
                    $row.hide();
                }
            });
        });
    }
    
    /**
     * Botones de edición
     */
    function initEditButtons() {
        $(document).on('click', '.btn-edit-page', function() {
            var pageId = $(this).data('page-id');
            openEditModal(pageId);
        });
    }
    
    /**
     * Botones de eliminación
     */
    function initDeleteButtons() {
        $(document).on('click', '.btn-delete-page', function() {
            var pageId = $(this).data('page-id');
            
            if (!confirm('¿Estás seguro de eliminar esta página? Esta acción no se puede deshacer.')) {
                return;
            }
            
            deletePage(pageId);
        });
    }
    
    /**
     * Modal de edición
     */
    function initModal() {
        // Cerrar modal
        $('.runart-modal-close').on('click', closeEditModal);
        
        // Cerrar al hacer clic fuera del modal
        $(window).on('click', function(e) {
            if ($(e.target).is('#runart-edit-modal')) {
                closeEditModal();
            }
        });
        
        // Cerrar con tecla ESC
        $(document).on('keydown', function(e) {
            if (e.keyCode === 27) {
                closeEditModal();
            }
        });
    }
    
    /**
     * Abrir modal de edición
     */
    function openEditModal(pageId) {
        currentEditingPage = pageId;
        
        // Mostrar modal con loading
        $('#runart-modal-body').html('<p>⏳ Cargando contenido...</p>');
        $('#runart-edit-modal').fadeIn(200);
        
        // Cargar contenido via REST
        $.ajax({
            url: runartIAVisual.restUrl + 'enriched?page_id=' + pageId,
            method: 'GET',
            headers: {
                'X-WP-Nonce': runartIAVisual.nonce
            },
            success: function(response) {
                if (response.ok && response.content) {
                    renderEditForm(pageId, response.content);
                } else {
                    $('#runart-modal-body').html('<p class="error">❌ Error al cargar contenido.</p>');
                }
            },
            error: function(xhr) {
                var errorMsg = 'Error desconocido';
                try {
                    var response = JSON.parse(xhr.responseText);
                    errorMsg = response.message || errorMsg;
                } catch(e) {
                    errorMsg = xhr.status + ': ' + xhr.statusText;
                }
                $('#runart-modal-body').html('<p class="error">❌ ' + errorMsg + '</p>');
            }
        });
    }
    
    /**
     * Cerrar modal de edición
     */
    function closeEditModal() {
        $('#runart-edit-modal').fadeOut(200);
        currentEditingPage = null;
    }
    
    /**
     * Renderizar formulario de edición
     */
    function renderEditForm(pageId, content) {
        var enrichedEs = content.enriched_es || {};
        var enrichedEn = content.enriched_en || {};
        var visualRefs = content.visual_references || [];
        
        var html = '<div class="runart-editor-container">';
        
        // Panel español
        html += '<div class="runart-editor-pane">';
        html += '<h3>Español (ES)</h3>';
        html += '<label><strong>Título:</strong></label>';
        html += '<input type="text" class="regular-text" id="edit-title-es" value="' + escapeHtml(enrichedEs.title || '') + '">';
        html += '<br><br>';
        html += '<label><strong>Contenido:</strong></label>';
        html += '<textarea id="edit-content-es">' + escapeHtml(enrichedEs.content || '') + '</textarea>';
        html += '</div>';
        
        // Panel inglés
        html += '<div class="runart-editor-pane">';
        html += '<h3>Inglés (EN)</h3>';
        html += '<label><strong>Título:</strong></label>';
        html += '<input type="text" class="regular-text" id="edit-title-en" value="' + escapeHtml(enrichedEn.title || '') + '">';
        html += '<br><br>';
        html += '<label><strong>Contenido:</strong></label>';
        html += '<textarea id="edit-content-en">' + escapeHtml(enrichedEn.content || '') + '</textarea>';
        html += '</div>';
        
        html += '</div>';
        
        // Referencias visuales
        html += '<div class="runart-editor-pane" style="margin-top: 20px;">';
        html += '<h3>Referencias Visuales (' + visualRefs.length + ')</h3>';
        html += '<div class="visual-refs-list">';
        if (visualRefs.length > 0) {
            visualRefs.forEach(function(ref) {
                html += '<div class="visual-ref-item" style="display: flex; gap: 10px; margin-bottom: 10px; padding: 10px; border: 1px solid #ddd; border-radius: 4px;">';
                if (ref.url) {
                    html += '<img src="' + escapeHtml(ref.url) + '" alt="' + escapeHtml(ref.alt_es || '') + '" style="width: 80px; height: 80px; object-fit: cover;">';
                }
                html += '<div>';
                html += '<strong>ID:</strong> ' + (ref.image_id || 'N/A') + '<br>';
                html += '<strong>ALT (ES):</strong> ' + escapeHtml(ref.alt_es || 'N/A') + '<br>';
                html += '<strong>Confianza:</strong> ' + (ref.confidence || 'N/A');
                html += '</div>';
                html += '</div>';
            });
        } else {
            html += '<p>No hay referencias visuales.</p>';
        }
        html += '</div>';
        html += '</div>';
        
        // Botones de acción
        html += '<div style="margin-top: 20px; text-align: right;">';
        html += '<button type="button" class="button button-secondary" onclick="jQuery(\'.runart-modal-close\').click()">Cancelar</button> ';
        html += '<button type="button" class="button button-primary" id="btn-save-content">Guardar Cambios</button>';
        html += '</div>';
        
        $('#runart-modal-body').html(html);
        
        // Handler para guardar
        $('#btn-save-content').on('click', function() {
            savePageContent(pageId);
        });
    }
    
    /**
     * Guardar contenido de página
     */
    function savePageContent(pageId) {
        var data = {
            page_id: pageId,
            enriched_es: {
                title: $('#edit-title-es').val(),
                content: $('#edit-content-es').val()
            },
            enriched_en: {
                title: $('#edit-title-en').val(),
                content: $('#edit-content-en').val()
            }
        };
        
        $('#btn-save-content').prop('disabled', true).text('Guardando...');
        
        $.ajax({
            url: runartIAVisual.ajaxUrl,
            method: 'POST',
            data: {
                action: 'runart_save_enriched',
                nonce: runartIAVisual.nonce,
                page_data: JSON.stringify(data)
            },
            success: function(response) {
                if (response.success) {
                    alert('✅ Contenido guardado correctamente.');
                    closeEditModal();
                    location.reload(); // Recargar para ver cambios
                } else {
                    alert('❌ Error al guardar: ' + (response.data.message || 'Error desconocido'));
                    $('#btn-save-content').prop('disabled', false).text('Guardar Cambios');
                }
            },
            error: function() {
                alert('❌ Error de comunicación con el servidor.');
                $('#btn-save-content').prop('disabled', false).text('Guardar Cambios');
            }
        });
    }
    
    /**
     * Eliminar página
     */
    function deletePage(pageId) {
        $.ajax({
            url: runartIAVisual.ajaxUrl,
            method: 'POST',
            data: {
                action: 'runart_delete_enriched',
                nonce: runartIAVisual.nonce,
                page_id: pageId
            },
            success: function(response) {
                if (response.success) {
                    alert('✅ Contenido eliminado.');
                    $('tr[data-page-id="' + pageId + '"]').fadeOut(300, function() {
                        $(this).remove();
                    });
                } else {
                    alert('❌ Error al eliminar: ' + (response.data.message || 'Error desconocido'));
                }
            },
            error: function() {
                alert('❌ Error de comunicación con el servidor.');
            }
        });
    }
    
    /**
     * Escapar HTML
     */
    function escapeHtml(text) {
        var map = {
            '&': '&amp;',
            '<': '&lt;',
            '>': '&gt;',
            '"': '&quot;',
            "'": '&#039;'
        };
        return text ? String(text).replace(/[&<>"']/g, function(m) { return map[m]; }) : '';
    }
    
})(jQuery);
