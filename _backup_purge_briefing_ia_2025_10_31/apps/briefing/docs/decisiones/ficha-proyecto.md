# Formulario — Nueva Ficha de Proyecto

Por favor, complete los campos disponibles para documentar una obra/proyecto.  
Puede dejar en blanco lo que no aplique y usar la sección **Otros campos** para proponer información adicional.

<form method="POST" action="/api/decisiones" aria-label="Formulario de ficha de proyecto">
  <label for="title">Título del proyecto:</label><br>
  <input type="text" id="title" name="title" required><br><br>

  <label for="artist">Artista(s):</label><br>
  <input type="text" id="artist" name="artist"><br><br>

  <label for="year">Año:</label><br>
  <input type="text" id="year" name="year"><br><br>

  <label for="location">Ubicación:</label><br>
  <input type="text" id="location" name="location"><br><br>

  <label for="materials">Materiales (ej. bronce, resina):</label><br>
  <input type="text" id="materials" name="materials"><br><br>

  <label for="dimensions">Dimensiones (cm):</label><br>
  <input type="text" id="dimensions" name="dimensions"><br><br>

  <label for="process">Proceso (modelado, colada, pátina):</label><br>
  <textarea id="process" name="process"></textarea><br><br>

  <label for="credits">Créditos (fundición, equipo):</label><br>
  <textarea id="credits" name="credits"></textarea><br><br>

  <label for="links">Enlaces externos (prensa, catálogos):</label><br>
  <input type="url" id="links" name="links"><br><br>

  <label for="testimony">Testimonio (autor y cita):</label><br>
  <textarea id="testimony" name="testimony"></textarea><br><br>

  <label for="notes">Notas adicionales:</label><br>
  <textarea id="notes" name="notes"></textarea><br><br>

  <label for="otros">Otros campos (sugeridos por cliente):</label><br>
  <textarea id="otros" name="otros"></textarea><br><br>

  <button type="submit">Enviar ficha</button>
</form>

---
