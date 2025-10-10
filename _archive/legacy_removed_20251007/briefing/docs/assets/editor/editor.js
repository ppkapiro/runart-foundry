(function () {
  const SUBMIT_DEBOUNCE_MS = 1500;
  let lastSubmitAt = 0;
  let submitting = false;
  let previewButton = null;
  let sendButton = null;

  const getAuthToken = function () {
    const token = (window.RUN_EDITOR_TOKEN || '').trim();
    return token || 'dev-token';
  };

  const getOriginHint = function () {
    try {
      return window.location.origin || new URL(window.location.href).origin;
    } catch (error) {
      return '';
    }
  };

  const makeError = function (message, fieldId) {
    return { message, fieldId: fieldId || null };
  };

  function init() {
    const container = document.getElementById('editor-app');
    if (!container) return;

  container.classList.add('editor-app');

  container.innerHTML = `
      <div class="editor-header">
        <h2>Editor guiado de fichas</h2>
        <p>Completa cada sección y genera una vista previa YAML antes de enviarla al inbox.</p>
      </div>
      <form id="editor-form" novalidate>
        <input type="hidden" name="token_origen" value="editor_v1" />
        <div class="hp-field" aria-hidden="true">
          <label for="website" class="sr-only">Sitio web</label>
          <input type="text" id="website" name="website" tabindex="-1" autocomplete="off" />
        </div>

        <div aria-live="polite" role="status" aria-busy="false" class="editor-status" id="editor-status"></div>
        <div class="editor-errors" id="editor-errors" hidden tabindex="-1" aria-live="assertive">
          <h3>Revisa los siguientes puntos:</h3>
          <ul id="editor-errors-list"></ul>
        </div>

        <fieldset class="editor-section">
          <legend>Identificación</legend>
          <div class="editor-grid">
            <div class="editor-field">
              <label for="slug">Slug <span aria-hidden="true">*</span></label>
              <input type="text" id="slug" name="slug" required aria-describedby="slug-help" placeholder="ej: carole-feuerman-2019" />
              <small id="slug-help">Usa minúsculas, números y guiones (será el ID del proyecto).</small>
            </div>
            <div class="editor-field">
              <label for="title">Título <span aria-hidden="true">*</span></label>
              <input type="text" id="title" name="title" required placeholder="Nombre oficial de la obra" />
            </div>
            <div class="editor-field">
              <label for="artist">Artista <span aria-hidden="true">*</span></label>
              <input type="text" id="artist" name="artist" required placeholder="Autor / artista" />
            </div>
            <div class="editor-field">
              <label for="year">Año <span aria-hidden="true">*</span></label>
              <input type="number" id="year" name="year" inputmode="numeric" min="1900" max="2100" placeholder="YYYY" />
            </div>
            <div class="editor-field">
              <label for="location">Lugar de instalación</label>
              <input type="text" id="location" name="location" placeholder="Ciudad, país o institución" />
            </div>
          </div>
        </fieldset>

        <fieldset class="editor-section">
          <legend>Materiales y técnica</legend>
          <div class="editor-grid">
            <div class="editor-field">
              <label for="alloy">Aleación / Material principal</label>
              <input type="text" id="alloy" name="alloy" placeholder="Bronce, aluminio, etc." />
            </div>
            <div class="editor-field">
              <label for="technique">Técnica</label>
              <input type="text" id="technique" name="technique" placeholder="Ej: Fundición a la cera perdida" />
            </div>
            <div class="editor-field">
              <label for="patina">Pátina</label>
              <input type="text" id="patina" name="patina" placeholder="Descripción de la pátina" />
            </div>
          </div>
        </fieldset>

        <fieldset class="editor-section">
          <legend>Dimensiones</legend>
          <div class="editor-grid">
            <div class="editor-field">
              <label for="height">Alto</label>
              <input type="number" id="height" name="height" step="0.01" min="0" placeholder="Ej: 120" />
            </div>
            <div class="editor-field">
              <label for="width">Ancho</label>
              <input type="number" id="width" name="width" step="0.01" min="0" placeholder="Ej: 45" />
            </div>
            <div class="editor-field">
              <label for="depth">Largo</label>
              <input type="number" id="depth" name="depth" step="0.01" min="0" placeholder="Ej: 60" />
            </div>
            <div class="editor-field">
              <label for="dimension_unit">Unidad</label>
              <select id="dimension_unit" name="dimension_unit" aria-describedby="dimension-unit-help">
                <option value="cm">centímetros (cm)</option>
                <option value="in">pulgadas (in)</option>
                <option value="m">metros (m)</option>
              </select>
              <small id="dimension-unit-help">Se convertirá automáticamente a centímetros en la vista previa.</small>
            </div>
          </div>
        </fieldset>

        <fieldset class="editor-section">
          <legend>Proceso, edición y estado</legend>
          <div class="editor-grid">
            <div class="editor-field">
              <label for="edition_type">Tipo de edición</label>
              <input type="text" id="edition_type" name="edition_type" placeholder="Ej: Edición limitada" />
            </div>
            <div class="editor-field">
              <label for="edition_size">Número de ediciones</label>
              <input type="text" id="edition_size" name="edition_size" placeholder="Ej: 3 + 2 AP" />
            </div>
            <div class="editor-field">
              <label for="state">Estado / notas de producción</label>
              <textarea id="state" name="state" rows="3" placeholder="Breve resumen del estado actual"></textarea>
            </div>
          </div>
        </fieldset>

        <fieldset class="editor-section">
          <legend>Medios</legend>
          <div class="editor-grid">
            <div class="editor-field">
              <label for="images">Imágenes (una por línea)</label>
              <textarea id="images" name="images" rows="4" aria-describedby="images-help" placeholder="https://.../imagen.jpg | Texto ALT"></textarea>
              <small id="images-help">Formato: <code>https://url/imagen.jpg | texto alternativo</code></small>
            </div>
            <div class="editor-field">
              <label for="videos">Video (opcional)</label>
              <textarea id="videos" name="videos" rows="3" aria-describedby="videos-help" placeholder="https://.../video.mp4 | Nota"></textarea>
              <small id="videos-help">Formato: <code>https://url/video.mp4 | nota breve</code></small>
            </div>
          </div>
        </fieldset>

        <fieldset class="editor-section">
          <legend>Enlaces y prensa</legend>
          <div class="editor-grid">
            <div class="editor-field">
              <label for="links">Enlaces (uno por línea)</label>
              <textarea id="links" name="links" rows="3" aria-describedby="links-help" placeholder="Etiqueta | https://enlace.com"></textarea>
              <small id="links-help">Formato: <code>Etiqueta | https://sitio.com</code></small>
            </div>
            <div class="editor-field">
              <label for="comment">Comentario interno</label>
              <textarea id="comment" name="comment" rows="3" placeholder="Notas adicionales para el equipo"></textarea>
            </div>
          </div>
        </fieldset>

        <fieldset class="editor-section">
          <legend>Testimonio (opcional)</legend>
          <div class="editor-grid">
            <div class="editor-field">
              <label for="testimony_author">Autor</label>
              <input type="text" id="testimony_author" name="testimony_author" placeholder="Nombre del autor" />
            </div>
            <div class="editor-field">
              <label for="testimony_quote">Testimonio</label>
              <textarea id="testimony_quote" name="testimony_quote" rows="3" placeholder="Cita o testimonio breve"></textarea>
            </div>
          </div>
        </fieldset>

        <div class="editor-actions">
          <button type="button" class="primary" id="btn-preview">Vista previa YAML</button>
          <button type="button" class="secondary" id="btn-send">Enviar a Inbox (JSON)</button>
          <button type="reset" class="danger" id="btn-reset">Limpiar formulario</button>
        </div>
      </form>

      <section class="editor-preview" id="editor-preview" hidden>
        <header>
          <h3>Vista previa YAML</h3>
          <button type="button" class="copy" id="btn-copy">Copiar</button>
        </header>
        <pre id="yaml-output"></pre>
      </section>

      <footer class="editor-footer">
        <span>El YAML generado debe validarse con <code>validate_projects.py</code> antes de la promoción final.</span>
        <a href="../inbox/index.md">Ir a bandeja de inbox</a>
      </footer>
    `;

    bindEvents(container);
  }

  function bindEvents(container) {
    const form = container.querySelector('#editor-form');
    const previewBtn = container.querySelector('#btn-preview');
    const sendBtn = container.querySelector('#btn-send');
    const resetBtn = container.querySelector('#btn-reset');
    const copyBtn = container.querySelector('#btn-copy');

    previewButton = previewBtn;
    sendButton = sendBtn;

    previewBtn.addEventListener('click', function () {
      handlePreview(form);
    });

    sendBtn.addEventListener('click', function () {
      handleSend(form);
    });

    resetBtn.addEventListener('click', function () {
      resetFormState(form);
    });

    copyBtn.addEventListener('click', handleCopy);
  }

  function resetFormState(form) {
    clearStatus();
    hideErrors();
    hidePreview();
    clearFieldErrors(form);
    lastSubmitAt = 0;
    setSubmitting(false);
  }

  function setSubmitting(value) {
    submitting = Boolean(value);
    if (!sendButton || !previewButton) return;

    if (submitting) {
      if (!sendButton.dataset.originalText) {
        sendButton.dataset.originalText = sendButton.textContent.trim();
      }
      sendButton.textContent = 'Enviando…';
      sendButton.classList.add('is-loading');
      sendButton.setAttribute('aria-busy', 'true');
      sendButton.setAttribute('disabled', 'true');
      previewButton.setAttribute('disabled', 'true');
      previewButton.setAttribute('aria-disabled', 'true');
    } else {
      const original = sendButton.dataset.originalText;
      if (original) {
        sendButton.textContent = original;
      }
      sendButton.classList.remove('is-loading');
      sendButton.removeAttribute('aria-busy');
      sendButton.removeAttribute('disabled');
      previewButton.removeAttribute('disabled');
      previewButton.removeAttribute('aria-disabled');
    }
  }

  function clearFieldErrors(form) {
    if (!form) return;
    const invalids = form.querySelectorAll('[aria-invalid="true"]');
    invalids.forEach(function (field) {
      field.removeAttribute('aria-invalid');
      field.removeAttribute('data-error-active');
    });
  }

  function handleCopy() {
    const preview = document.getElementById('yaml-output');
    if (!preview || !preview.textContent) return;
    navigator.clipboard.writeText(preview.textContent).then(function () {
      showStatus('Vista previa YAML copiada al portapapeles.', 'success');
    }).catch(function () {
      showStatus('No se pudo copiar al portapapeles. Copia manualmente.', 'error');
    });
  }

  function handlePreview(form) {
    clearStatus();
    hideErrors();
    clearFieldErrors(form);

    const { data, errors } = collectData(form);
    if (errors.length) {
      showErrors(form, errors);
      return;
    }

    const payload = buildPayload(data);
    const cleaned = pruneEmpty(payload);
    const yaml = toYAML(cleaned);

    const previewSection = document.getElementById('editor-preview');
    const output = document.getElementById('yaml-output');
    output.textContent = yaml || '# YAML vacío';
    previewSection.hidden = false;
    showStatus('Vista previa generada. Valida el YAML antes de promover.', 'success');
  }

  function handleSend(form) {
    clearStatus();
    hideErrors();
    clearFieldErrors(form);

    if (submitting) {
      showStatus('Ya estamos procesando tu envío.', 'info');
      return;
    }

    const now = Date.now();
    if (now - lastSubmitAt < SUBMIT_DEBOUNCE_MS) {
      showStatus('Espera un momento antes de reenviar la ficha.', 'info');
      return;
    }

    const { data, errors } = collectData(form);
    if (errors.length) {
      showErrors(form, errors);
      return;
    }

    const payload = buildPayload(data);
    const cleaned = pruneEmpty(payload);

    lastSubmitAt = now;
    setSubmitting(true);
    showStatus('Enviando ficha…', 'loading');

    const authToken = getAuthToken();
    const originHint = getOriginHint();
    const body = {
      decision_id: `proyecto:${data.slug}`,
      tipo: 'ficha_proyecto',
      payload: cleaned,
      comentario: data.comment || 'Enviado desde editor v1',
      token_origen: 'editor_v1',
      origin_hint: originHint,
      website: data.website || '',
      auth_token: authToken
    };

    fetch('/api/decisiones', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Runart-Token': authToken
      },
      credentials: 'include',
      body: JSON.stringify(body)
    })
      .then(async function (response) {
        if (!response.ok) {
          const text = await response.text();
          throw new Error(text || 'Error desconocido');
        }
        lastSubmitAt = Date.now();
        showStatus('Ficha enviada al inbox. Revisa la bandeja para moderar.', 'success');
        form.reset();
        hidePreview();
      })
      .catch(function (error) {
        lastSubmitAt = Date.now() - SUBMIT_DEBOUNCE_MS;
        showStatus(`No se pudo enviar la ficha: ${error.message}`, 'error');
      })
      .finally(function () {
        clearFieldErrors(form);
        hideErrors();
        setSubmitting(false);
      });
  }

  function collectData(form) {
    const formData = new FormData(form);
    const values = Object.fromEntries(formData.entries());
    const errors = [];

    const slug = (values.slug || '').trim();
    if (!slug) {
      errors.push(makeError('El campo "Slug" es obligatorio.', 'slug'));
    } else if (!/^[a-z0-9-]+$/.test(slug)) {
      errors.push(makeError('El slug solo puede contener minúsculas, números y guiones.', 'slug'));
    }

    const title = (values.title || '').trim();
    if (!title) {
      errors.push(makeError('El campo "Título" es obligatorio.', 'title'));
    }

    const artist = (values.artist || '').trim();
    if (!artist) {
      errors.push(makeError('El campo "Artista" es obligatorio.', 'artist'));
    }

    const yearRaw = (values.year || '').trim();
    if (!yearRaw) {
      errors.push(makeError('El campo "Año" es obligatorio.', 'year'));
    } else if (!/^\d{4}$/.test(yearRaw)) {
      errors.push(makeError('El año debe tener 4 dígitos (YYYY).', 'year'));
    }

    const dimensionUnit = values.dimension_unit || 'cm';
    const dims = ['height', 'width', 'depth'];
    dims.forEach(function (name) {
      const raw = values[name];
      if (!raw) return;
      const numeric = Number(raw);
      if (Number.isNaN(numeric)) {
        errors.push(makeError(`La dimensión "${name}" debe ser un número válido.`, name));
      } else if (numeric <= 0) {
        errors.push(makeError(`La dimensión "${name}" debe ser un número positivo.`, name));
      }
    });

    const images = parseList(values.images, {
      validator(entry) {
        return isValidUrl(entry.value);
      },
      parse(line) {
        const parts = line.split('|');
        const url = (parts[0] || '').trim();
        const alt = (parts[1] || '').trim();
        return { path: url, alt };
      },
      valueKey: 'path',
      label: 'Imágenes',
      fieldId: 'images'
    });
    errors.push(...images.errors);

    const videos = parseList(values.videos, {
      validator(entry) {
        return isValidUrl(entry.url);
      },
      parse(line) {
        const parts = line.split('|');
        const url = (parts[0] || '').trim();
        const note = (parts[1] || '').trim();
        return { url, note };
      },
      valueKey: 'url',
      label: 'Videos',
      fieldId: 'videos'
    });
    errors.push(...videos.errors);

    const links = parseList(values.links, {
      validator(entry) {
        return entry.label && isValidUrl(entry.url);
      },
      parse(line) {
        const parts = line.split('|');
        const label = (parts[0] || '').trim();
        const url = (parts[1] || '').trim();
        return { label, url };
      },
      valueKey: 'url',
      label: 'Enlaces',
      fieldId: 'links'
    });
    errors.push(...links.errors);

    const toNumberOrNull = function (value) {
      if (value === null || value === undefined || value === '') return null;
      const numeric = Number(value);
      return Number.isNaN(numeric) ? null : numeric;
    };

    return {
      data: {
        slug,
        title,
        artist,
        year: yearRaw,
        location: (values.location || '').trim(),
        alloy: (values.alloy || '').trim(),
        technique: (values.technique || '').trim(),
        patina: (values.patina || '').trim(),
        height: toNumberOrNull(values.height),
        width: toNumberOrNull(values.width),
        depth: toNumberOrNull(values.depth),
        dimension_unit: dimensionUnit,
        edition_type: (values.edition_type || '').trim(),
        edition_size: (values.edition_size || '').trim(),
        state: (values.state || '').trim(),
        images: images.items,
        videos: videos.items,
        links: links.items,
        testimony_author: (values.testimony_author || '').trim(),
        testimony_quote: (values.testimony_quote || '').trim(),
        comment: (values.comment || '').trim(),
        website: (values.website || '').trim()
      },
      errors
    };
  }

  function parseList(value, options) {
    const items = [];
    const errors = [];
    if (!value) {
      return { items, errors };
    }

    const lines = value.split('\n').map(function (line) { return line.trim(); }).filter(Boolean);
    lines.forEach(function (line, index) {
      const parsed = options.parse(line);
      if (!parsed || !parsed[options.valueKey] || !options.validator(parsed)) {
        errors.push(makeError(`${options.label}: la línea ${index + 1} no tiene el formato esperado.`, options.fieldId));
      } else {
        items.push(parsed);
      }
    });

    return { items, errors };
  }

  function isValidUrl(url) {
    return /^https:\/\//i.test(url);
  }

  function buildPayload(data) {
    const convertDimension = function (value) {
      if (value === null || Number.isNaN(value)) return null;
      const unit = data.dimension_unit;
      if (unit === 'in') {
        return parseFloat((value * 2.54).toFixed(2));
      }
      if (unit === 'm') {
        return parseFloat((value * 100).toFixed(2));
      }
      return parseFloat(value.toFixed(2));
    };

    const dimensions = {
      height_cm: convertDimension(data.height),
      width_cm: convertDimension(data.width),
      depth_cm: convertDimension(data.depth)
    };

    const materials = [];
    if (data.alloy || data.technique) {
      materials.push({
        alloy: data.alloy || undefined,
        finish: data.technique || undefined
      });
    }

    const media = {};
    if (data.images.length) {
      media.images = data.images;
    }
    if (data.videos.length) {
      media.video = data.videos;
    }

    const testimony = (data.testimony_author || data.testimony_quote) ? {
      author: data.testimony_author || undefined,
      quote: data.testimony_quote || undefined
    } : null;

    const process = {
      modeling: data.state || undefined,
      patina: data.patina || undefined,
      mounting: data.location || undefined
    };

    return {
      id: data.slug,
      title: data.title,
      artist: data.artist,
      year: data.year,
      location: data.location || undefined,
      materials: materials,
      dimensions,
      edition: {
        type: data.edition_type || undefined,
        size: data.edition_size || undefined
      },
      process,
      media,
      links: data.links,
      testimony: testimony || undefined,
      notes: data.state ? `Estado: ${data.state}` : undefined
    };
  }

  function pruneEmpty(value) {
    if (Array.isArray(value)) {
      const filtered = value
        .map(pruneEmpty)
        .filter(function (item) {
          if (item === null || item === undefined) return false;
          if (typeof item === 'string' && item.trim() === '') return false;
          if (Array.isArray(item) && item.length === 0) return false;
          if (typeof item === 'object' && Object.keys(item).length === 0) return false;
          return true;
        });
      return filtered;
    }

    if (value && typeof value === 'object') {
      const result = {};
      Object.keys(value).forEach(function (key) {
        const cleaned = pruneEmpty(value[key]);
        if (cleaned === null || cleaned === undefined) return;
        if (typeof cleaned === 'string' && cleaned.trim() === '') return;
        if (Array.isArray(cleaned) && cleaned.length === 0) return;
        if (typeof cleaned === 'object' && Object.keys(cleaned).length === 0) return;
        result[key] = cleaned;
      });
      return result;
    }

    return value;
  }

  function toYAML(value, indent = 0) {
    const indentStr = '  '.repeat(indent);

    if (Array.isArray(value)) {
      if (value.length === 0) return '';
      return value.map(function (item) {
        if (typeof item === 'object' && item !== null) {
          const nested = toYAML(item, indent + 1);
          return `${indentStr}-\n${nested}`;
        }
        return `${indentStr}- ${formatScalar(item)}`;
      }).join('\n');
    }

    if (value && typeof value === 'object') {
      return Object.keys(value).map(function (key) {
        const val = value[key];
        if (Array.isArray(val)) {
          const arr = toYAML(val, indent + 1);
          if (!arr) return undefined;
          return `${indentStr}${key}:\n${arr}`;
        }
        if (val && typeof val === 'object') {
          const nested = toYAML(val, indent + 1);
          if (!nested) return undefined;
          return `${indentStr}${key}:\n${nested}`;
        }
        return `${indentStr}${key}: ${formatScalar(val)}`;
      }).filter(Boolean).join('\n');
    }

    return `${indentStr}${formatScalar(value)}`;
  }

  function formatScalar(value) {
    if (value === null || value === undefined) return '';
    if (typeof value === 'number') {
      return Number.isInteger(value) ? value.toString() : value.toFixed(2).replace(/\.00$/, '.0');
    }
    const str = String(value);
    if (str === '') return "''";
    if (/[:#\-]|^\s|\s$|\n/.test(str)) {
      return '"' + str.replace(/"/g, '\\"') + '"';
    }
    return str;
  }

  function showStatus(message, type) {
    const status = document.getElementById('editor-status');
    const classes = ['editor-status'];
    if (type) {
      classes.push(`status--${type}`);
    }
    status.className = classes.join(' ');
    status.textContent = message;
    status.style.display = 'block';
    status.setAttribute('aria-busy', type === 'loading' ? 'true' : 'false');
  }

  function clearStatus() {
    const status = document.getElementById('editor-status');
    status.textContent = '';
    status.className = 'editor-status';
    status.style.display = 'none';
    status.setAttribute('aria-busy', 'false');
  }

  function showErrors(form, errors) {
    const container = document.getElementById('editor-errors');
    const list = document.getElementById('editor-errors-list');
    if (!container || !list) return;
    list.innerHTML = '';

    let firstFocusable = null;

    errors.forEach(function (error) {
      const detail = typeof error === 'string' ? makeError(error, null) : error;
      const li = document.createElement('li');
      li.textContent = detail.message;
      list.appendChild(li);

      if (detail.fieldId) {
        const field = form.querySelector('#' + detail.fieldId) || form.querySelector(`[name="${detail.fieldId}"]`);
        if (field) {
          field.setAttribute('aria-invalid', 'true');
          field.setAttribute('data-error-active', 'true');
          if (!firstFocusable) {
            firstFocusable = field;
          }
        }
      }
    });

    container.hidden = false;
    container.focus();

    if (firstFocusable) {
      setTimeout(function () {
        firstFocusable.focus({ preventScroll: false });
      }, 0);
    }

    showStatus('Revisa los campos destacados.', 'error');
  }

  function hideErrors() {
    const container = document.getElementById('editor-errors');
    const list = document.getElementById('editor-errors-list');
    if (!container || !list) return;
    list.innerHTML = '';
    container.hidden = true;
    container.blur();
  }

  function hidePreview() {
    const previewSection = document.getElementById('editor-preview');
    const output = document.getElementById('yaml-output');
    if (previewSection) {
      previewSection.hidden = true;
    }
    if (output) {
      output.textContent = '';
    }
  }

  document.addEventListener('DOMContentLoaded', init);
})();
