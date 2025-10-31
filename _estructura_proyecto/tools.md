# Estructura: tools/

**Carpeta principal:** `tools/`
**Líneas:** 177
**Generado:** 2025-10-31 16:59:58

---

```
📁 tools/
    📁 ci/
        📄 verify_pages_check.sh — 732.0 B
    📁 diagnostics/
        📄 access_deepcheck.mjs — 16.1 KB
        📄 cf_register_branch_hostname.mjs — 2.0 KB
        📄 export_access_envs.sh — 1.9 KB
        📄 open_branch_preview_issue.sh — 945.0 B
        📄 postprocess_canary_summary.ps1 — 5.9 KB
        📄 postprocess_canary_summary.sh — 4.5 KB
        📄 preview_host_resolver.sh — 1.0 KB
        📄 run_preview_validation.sh — 2.8 KB
        📄 verify_access_service_token.mjs — 5.4 KB
        📄 verify_whoami_with_token.sh — 812.0 B
    📁 lighthouse_mobile/
        📄 package-lock.json — 101.8 KB
        📄 package.json — 355.0 B
        📄 runner.js — 8.0 KB
    📁 log/
        📄 append_bitacora.sh — 2.1 KB
    📁 patches/
        📄 README.md — 1.3 KB
        📄 hero_improve.css — 823.0 B
    📁 runart-ai-visual-panel/
        📁 assets/
            📁 js/
                📄 panel-editor.js — 10.4 KB
        📁 data/
            📄 index.json — 17.0 B
        📁 includes/
            📄 class-runart-ai-visual-admin.php — 1.9 KB
            📄 class-runart-ai-visual-rest.php — 6.2 KB
            📄 class-runart-ai-visual-shortcode.php — 1.5 KB
        📄 README.md — 1.9 KB
        📄 runart-ai-visual-panel.php — 954.0 B
    📁 runart-ia-visual-unified/
        📁 assets/
            📁 css/
                📄 panel-editor.css — 814.0 B
            📁 js/
                📄 panel-editor.js — 11.7 KB
            📄 admin-editor.css — 3.6 KB
            📄 admin-editor.js — 10.8 KB
        📁 data/
            📁 assistants/
                📁 rewrite/
                    📄 index.json — 739.0 B
                    📄 page_42.json — 4.8 KB
                    📄 page_43.json — 3.7 KB
                    📄 page_44.json — 4.6 KB
        📁 includes/
            📄 class-admin-diagnostic.php — 10.0 KB
            📄 class-admin-editor.php — 20.6 KB
            📄 class-data-layer.php — 6.0 KB
            📄 class-permissions.php — 2.0 KB
            📄 class-rest-api.php — 40.2 KB
            📄 class-shortcode.php — 5.7 KB
        📄 CHANGELOG.md — 5.9 KB
        📄 README.md — 8.2 KB
        📄 init_monitor_page.php — 5.1 KB
        📄 runart-ia-visual-unified.php — 111.0 KB
        📄 uninstall.php — 2.2 KB
    📁 uiux_screenshots/
    📁 wpcli-bridge-plugin/
        📁 data/
            📁 assistants/
                📁 rewrite/
                    📄 index.json — 739.0 B
                    📄 page_42.json — 4.8 KB
                    📄 page_43.json — 3.7 KB
                    📄 page_44.json — 4.6 KB
            📁 embeddings/
                📁 correlations/
                    📄 recommendations_cache.json — 1.5 KB
                    📄 similarity_matrix.json — 1.2 KB
                    📄 validation_log.json — 86.0 B
                📁 text/
                    📁 multilingual_mpnet/
                        📁 embeddings/
                📁 visual/
                    📁 clip_512d/
                        📁 embeddings/
                            📄 5aa5b143638dd501.json — 13.4 KB
                        📄 index.json — 1.1 KB
        📄 README.md — 2.2 KB
        📄 init_monitor_page.php — 5.1 KB
        📄 runart-wpcli-bridge-latest.zip — 38.9 KB
        📄 runart-wpcli-bridge.php — 106.6 KB
    📄 README.md — 8.4 KB
    📄 STAGING_VALIDATION_README.md — 11.9 KB
    📄 audit_executive_summary.sh — 4.4 KB
    📄 audit_plugins_indirect.sh — 6.9 KB
    📄 audit_plugins_staging.sh — 8.7 KB
    📄 auto_rollback.py — 6.6 KB
    📄 auto_translate_content.py — 17.9 KB
    📄 cache_purge_pages.sh — 1.1 KB
    📄 capture_header_screens.js — 1.3 KB
    📄 check_env.py — 10.2 KB
    📄 chrome_overflow_audit.js — 4.7 KB
    📄 cleanup_plugins_staging.sh — 7.4 KB
    📄 cleanup_staging_now.sh — 6.2 KB
    📄 collect_metrics_runs.sh — 345.0 B
    📄 commits_to_posts.py — 8.7 KB
    📄 compare_prod_fingerprints.sh — 2.5 KB
    📄 consolidate_briefing_v2.py — 18.1 KB
    📄 create_delivery_package.sh — 13.7 KB
    📄 create_pr_api.sh — 2.3 KB
    📄 debug_polylang_archives.py — 3.5 KB
    📄 deploy_fase2_staging.sh — 7.3 KB
    📄 deploy_wp_ssh.sh — 13.8 KB
    📄 diagnose_staging_permissions.sh — 14.2 KB
    📄 diff_site_snapshots.py — 7.8 KB
    📄 enhance_content_matrix.py — 4.7 KB
    📄 fase3e_verify_rest.py — 8.6 KB
    📄 fase7_collect_evidence.sh — 4.2 KB
    📄 fase7_process_evidence.py — 14.9 KB
    📄 find_horizontal_overflow.js — 1.6 KB
    📄 fix_redirect_loop.py — 1.7 KB
    📄 fix_staging_permissions.sh — 11.1 KB
    📄 generate_auditoria_estructura.py — 9.7 KB
    📄 generate_ui_inventory.py — 6.3 KB
    📄 init_staging_iavisual_structure.sh — 1.5 KB
    📄 install_wp_staging.sh — 11.7 KB
    📄 ionos_create_staging.sh — 2.4 KB
    📄 ionos_create_staging_db.sh — 6.7 KB
    📄 link_and_publish_translations.php — 3.6 KB
    📄 link_pages_translations.py — 1.8 KB
    📄 link_publish_translations.py — 5.1 KB
    📄 lint_docs.py — 4.2 KB
    📄 list_site_pages.py — 2.6 KB
    📄 load_staging_credentials.sh — 7.8 KB
    📄 log_events_summary.py — 5.7 KB
    📄 notify.py — 7.4 KB
    📄 package_template.sh — 1.3 KB
    📄 phase3_validate_ui.py — 15.4 KB
    📄 phase4_apply_ui_corrections.py — 11.4 KB
    📄 phase5_mvp_cliente.py — 9.8 KB
    📄 phase6_owner_equipo.py — 13.7 KB
    📄 phase7_admin_viewas_depuracion.py — 17.9 KB
    📄 phase8_tecnico_glosario_tokens.py — 19.0 KB
    📄 populate_content_matrix.py — 5.0 KB
    📄 publish_mvp_staging.sh — 744.0 B
    📄 publish_showcase_page_staging.sh — 977.0 B
    📄 publish_template_page_staging.sh — 1001.0 B
    📄 purge_all_caches.sh — 2.2 KB
    📄 remediate.sh — 934.0 B
    📄 remote_run_autodetect.sh — 4.9 KB
    📄 remote_run_repair_final.sh — 2.0 KB
    📄 remove_redirect_plugin.py — 1.6 KB
    📄 render_history.py — 7.4 KB
    📄 render_status.py — 5.6 KB
    📄 repair_auto_prod_staging.sh — 17.6 KB
    📄 repair_autodetect_prod_staging.sh — 13.6 KB
    📄 repair_final_prod_staging.sh — 19.2 KB
    📄 rotate_wp_app_password.sh — 441.0 B
    📄 staging_cleanup_auto.sh — 9.0 KB
    📄 staging_cleanup_direct.sh — 4.9 KB
    📄 staging_cleanup_github.sh — 13.1 KB
    📄 staging_cleanup_wpcli.sh — 6.1 KB
    📄 staging_env_loader.sh — 7.3 KB
    📄 staging_full_validation.sh — 14.4 KB
    📄 staging_http_fix.sh — 6.0 KB
    📄 staging_isolation_audit.sh — 11.0 KB
    📄 staging_liberar_escritura.sh — 3.5 KB
    📄 staging_privacy.sh — 321.0 B
    📄 staging_verify_cleanup.sh — 4.0 KB
    📄 sync_enriched_dataset.py — 9.4 KB
    📄 test_staging_write.sh — 8.2 KB
    📄 translate_cpt_content.py — 9.3 KB
    📄 translate_main_pages.py — 7.6 KB
    📄 update_bitacora_briefing_v2.py — 10.1 KB
    📄 validate_access_policy.py — 7.7 KB
    📄 validate_plugin_cleanup.sh — 8.8 KB
    📄 validate_staging_endpoints.sh — 11.6 KB
    📄 validate_status_schema.py — 4.2 KB
    📄 verify_es_content.py — 2.2 KB
    📄 verify_fase2_deployment.sh — 6.8 KB
```
