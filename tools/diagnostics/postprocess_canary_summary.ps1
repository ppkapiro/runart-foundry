#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Post-procesador de artefactos del workflow run_canary_diagnostics.yml

.DESCRIPTION
    Descarga el artefacto RESUMEN de la última ejecución exitosa del workflow
    de diagnóstico canary y copia el RESUMEN_*.md a la carpeta de evidencia
    en docs/internal/security/evidencia/ con timestamp.

.REQUIREMENTS
    - GitHub CLI (gh) autenticado
    - PowerShell 7+

.USAGE
    pwsh tools/diagnostics/postprocess_canary_summary.ps1

.OUTPUTS
    - Archivo RESUMEN copiado a: docs/internal/security/evidencia/RESUMEN_PREVIEW_YYYYMMDD_HHMM.md
    - Imprime run_id, status, y ruta del RESUMEN guardado

.EXIT CODES
    0 - Éxito (RESUMEN descargado y copiado)
    1 - Error (no se encontró run exitoso, o fallo al descargar)
#>

$ErrorActionPreference = "Stop"

Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  RUNART | Post-procesador de RESUMEN Canary Diagnostics" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# 1. Buscar la última ejecución exitosa del workflow
Write-Host "🔍 Buscando última ejecución exitosa de run_canary_diagnostics.yml..." -ForegroundColor Yellow
$runJson = gh run list `
    --workflow=run_canary_diagnostics.yml `
    --status=success `
    --limit=1 `
    --json databaseId,conclusion,createdAt,displayTitle

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ ERROR: No se pudo consultar el historial de runs" -ForegroundColor Red
    exit 1
}

$run = $runJson | ConvertFrom-Json

if ($run.Count -eq 0) {
    Write-Host "❌ ERROR: No se encontró ningún run exitoso del workflow" -ForegroundColor Red
    Write-Host "   Asegúrate de que el workflow haya corrido al menos una vez con éxito" -ForegroundColor Red
    exit 1
}

$runId = $run[0].databaseId
$conclusion = $run[0].conclusion
$createdAt = $run[0].createdAt
$title = $run[0].displayTitle

Write-Host "✅ Run encontrado:" -ForegroundColor Green
Write-Host "   • Run ID: $runId" -ForegroundColor Gray
Write-Host "   • Conclusión: $conclusion" -ForegroundColor Gray
Write-Host "   • Fecha: $createdAt" -ForegroundColor Gray
Write-Host "   • Título: $title" -ForegroundColor Gray
Write-Host ""

# 2. Crear directorio temporal para descarga
$tempDir = New-Item -ItemType Directory -Path "./_tmp/canary_artifacts_$(Get-Date -Format 'yyyyMMddHHmmss')" -Force
Write-Host "📁 Directorio temporal: $($tempDir.FullName)" -ForegroundColor Gray
Write-Host ""

# 3. Descargar artefactos del run
Write-Host "📡 Descargando artefactos del run $runId..." -ForegroundColor Yellow
gh run download $runId --dir "$($tempDir.FullName)"

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ ERROR: Fallo al descargar artefactos" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Artefactos descargados" -ForegroundColor Green
Write-Host ""

# 4. Buscar archivo RESUMEN_*.md
$resumenFiles = Get-ChildItem -Path $tempDir -Recurse -Filter "RESUMEN_*.md"

if ($resumenFiles.Count -eq 0) {
    Write-Host "❌ ERROR: No se encontró ningún archivo RESUMEN_*.md en los artefactos" -ForegroundColor Red
    Write-Host "   Archivos descargados:" -ForegroundColor Red
    Get-ChildItem -Path $tempDir -Recurse | ForEach-Object { Write-Host "   • $($_.FullName)" -ForegroundColor Gray }
    exit 1
}

$resumenFile = $resumenFiles[0]
Write-Host "✅ RESUMEN encontrado: $($resumenFile.Name)" -ForegroundColor Green
Write-Host ""

# 5. Crear directorio de evidencia si no existe
$evidenciaDir = "docs/internal/security/evidencia"
if (-not (Test-Path $evidenciaDir)) {
    New-Item -ItemType Directory -Path $evidenciaDir -Force | Out-Null
    Write-Host "📁 Directorio creado: $evidenciaDir" -ForegroundColor Gray
}

# 6. Copiar RESUMEN con timestamp
$timestamp = Get-Date -Format "yyyyMMdd_HHmm"
$targetFileName = "RESUMEN_PREVIEW_${timestamp}.md"
$targetPath = Join-Path $evidenciaDir $targetFileName

Copy-Item -Path $resumenFile.FullName -Destination $targetPath -Force
Write-Host "✅ RESUMEN copiado a: $targetPath" -ForegroundColor Green
Write-Host ""

# 7. Mostrar contenido del RESUMEN (primeras 50 líneas)
Write-Host "📄 Contenido del RESUMEN (primeras 50 líneas):" -ForegroundColor Yellow
Write-Host "───────────────────────────────────────────────────────────────────" -ForegroundColor Gray
Get-Content $targetPath -TotalCount 50
Write-Host "───────────────────────────────────────────────────────────────────" -ForegroundColor Gray
Write-Host ""

# 8. Limpiar directorio temporal
Remove-Item -Path $tempDir -Recurse -Force
Write-Host "🗑️  Directorio temporal eliminado" -ForegroundColor Gray
Write-Host ""

# 9. Salida final
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "✅ POST-PROCESAMIENTO EXITOSO" -ForegroundColor Green
Write-Host "   • Run ID: $runId" -ForegroundColor Gray
Write-Host "   • RESUMEN guardado en: $targetPath" -ForegroundColor Gray
Write-Host "   • Listo para agregar al changelog de secretos" -ForegroundColor Gray
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
exit 0
