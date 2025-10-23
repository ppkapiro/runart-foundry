---
title: "Status History — Tendencias"
updated: "2025-10-23T22:50:01Z"
description: "Historial de snapshots semanales de status.json con visualización de tendencias"
---

# 📊 Status History — Tendencias

Historial de snapshots semanales mostrando la evolución de la documentación del proyecto.

## 📈 Tendencias Temporales

<div style="max-width: 900px; margin: 2rem auto;">
    <canvas id="statusHistory"></canvas>
</div>

## 📋 Tabla de Snapshots

| Fecha | Live Docs | Archive Docs | Total | Snapshot |
|-------|-----------|--------------|-------|----------|
| 2025-10-22 | 45 | 10 | 55 | `status_2025-10-22.json` |
| 2025-10-21 | 42 | 9 | 51 | `status_2025-10-21.json` |
| 2025-10-20 | 40 | 8 | 48 | `status_2025-10-20.json` |

---

**Última actualización:** 2025-10-23T22:50:01Z  
**Total de snapshots:** 3

<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<script>
(function() {
    const ctx = document.getElementById('statusHistory');
    if (!ctx) return;
    
    const data = {
        labels: ["2025-10-20", "2025-10-21", "2025-10-22"],
        datasets: [
            {
                label: 'Docs Live',
                data: [40, 42, 45],
                borderColor: 'rgb(75, 192, 192)',
                backgroundColor: 'rgba(75, 192, 192, 0.2)',
                tension: 0.1
            },
            {
                label: 'Archive',
                data: [8, 9, 10],
                borderColor: 'rgb(255, 159, 64)',
                backgroundColor: 'rgba(255, 159, 64, 0.2)',
                tension: 0.1
            },
            {
                label: 'Total',
                data: [48, 51, 55],
                borderColor: 'rgb(153, 102, 255)',
                backgroundColor: 'rgba(153, 102, 255, 0.2)',
                tension: 0.1,
                borderDash: [5, 5]
            }
        ]
    };
    
    new Chart(ctx, {
        type: 'line',
        data: data,
        options: {
            responsive: true,
            plugins: {
                legend: {
                    position: 'top',
                },
                title: {
                    display: true,
                    text: 'Evolución de Documentación (Snapshots Semanales)'
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: {
                        stepSize: 5
                    }
                }
            }
        }
    });
})();
</script>
