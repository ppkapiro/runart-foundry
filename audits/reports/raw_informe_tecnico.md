# Informe Técnico Consolidado – RUN Art Foundry (raw)

## Índice
1. Resumen Ejecutivo
2. Infraestructura y Accesos
3. Snapshots y Artefactos
4. Resultados de Auditoría
5. Mapa del Sitio
6. Diagnóstico Global
7. Conclusiones Técnicas
8. Referencias de Archivos

---
## 1) Resumen Ejecutivo

## 2) Infraestructura y Accesos

## 3) Snapshots y Artefactos

<details><summary><code>audits/_structure/raw_sizes_overview.txt</code></summary>

```
1001M	.
760M	./mirror
237M	./.tools
4.3M	./audits
8.0K	./docs
4.0K	./source
```
</details>


## 4) Resultados de Auditoría
### 4.1 SEO
### 4.2 Performance
### 4.3 Accesibilidad
### 4.4 Seguridad
### 4.5 Inventarios

## 5) Mapa del Sitio
Total páginas: 6

<details><summary><code>audits/_structure/raw_sitemap.txt</code></summary>

```
comments/feed/index.html
feed/index.html
index.html
www.runartfoundry.com/comments/feed/index.html
www.runartfoundry.com/feed/index.html
www.runartfoundry.com/index.html
```
</details>


## 6) Diagnóstico Global
- Imágenes JPG detectadas: 5608
- Páginas sin meta description: 6
- Herramientas Google en snapshot: no evidencias de GA/GTM/GSC.

## 7) Conclusiones Técnicas
- Cuello de botella principal: **imágenes pesadas** en uploads.
- SEO incompleto: **meta descriptions** ausentes en todas las páginas.
- Acceso DB por phpMyAdmin pendiente para cerrar snapshot completo.
- Estructura de proyecto ya **ordenada y trazable** con auditorías.

## 8) Referencias de Archivos

<details><summary><code>audits/_structure/raw_project_tree.txt</code></summary>

```
.
├── .env
├── .env.example
├── .gitignore
├── README.md
├── audits
│   ├── 2025-10-01_auditoria_integral.md
│   ├── 2025-10-01_db_check.log
│   ├── 2025-10-01_db_dump.log
│   ├── 2025-10-01_fase1_status.md
│   ├── 2025-10-01_fase2_snapshot.md
│   ├── 2025-10-01_mirror_sftp_final.md
│   ├── 2025-10-01_sftp_check.log
│   ├── 2025-10-01_sftp_wp-content.log
│   ├── 2025-10-01_ssh_config_status.md
│   ├── 2025-10-01_wget_site.log
│   ├── README.md
│   ├── _structure
│   │   ├── 2025-10-01_audits_file_list.txt
│   │   ├── 2025-10-01_audits_overview.txt
│   │   ├── 2025-10-01_audits_root_scripts.txt
│   │   ├── 2025-10-01_count_by_extension.csv
│   │   ├── 2025-10-01_docs_overview.txt
│   │   ├── 2025-10-01_file_index.csv
│   │   ├── 2025-10-01_mirror_overview.txt
│   │   ├── 2025-10-01_no_meta_description.txt
│   │   ├── 2025-10-01_project_tree.txt
│   │   ├── 2025-10-01_resumen_estructura.md
│   │   ├── 2025-10-01_sitemap.txt
│   │   ├── 2025-10-01_sizes_overview.txt
│   │   ├── 2025-10-01_source_overview.txt
│   │   ├── 2025-10-01_top100_files_by_size.csv
│   │   ├── raw_count_by_extension.csv
│   │   ├── raw_file_index.csv
│   │   ├── raw_no_meta_description.txt
│   │   ├── raw_project_tree.txt
│   │   ├── raw_sitemap.txt
│   │   ├── raw_sizes_overview.txt
│   │   └── raw_top100_files_by_size.csv
│   ├── axe
│   ├── checklist.md
│   ├── http_server_2025-10-01.pid
│   ├── inventory
│   │   ├── 2025-10-01_imagenes_pesadas.txt
│   │   ├── 2025-10-01_plugins.txt
│   │   └── 2025-10-01_themes.txt
│   ├── lighthouse
│   ├── reports
│   ├── scripts
│   ├── security
│   └── seo
│       ├── 2025-10-01_multiples_h1.txt
│       ├── 2025-10-01_sin_meta_description.txt
│       └── 2025-10-01_titulos.txt
├── docs
│   └── README.md
├── escaneo_estructura_completa.sh
├── fase3_auditoria.sh
├── fase3_auditoria_simplificada.sh
├── generar_informes_maestros.sh
├── mirror
│   ├── normalized
│   └── raw
│       └── 2025-10-01
│           ├── db_dump.sql
│           ├── site_static
│           │   ├── comments
│           │   │   └── feed
│           │   │       └── index.html
│           │   ├── feed
│           │   │   └── index.html
│           │   ├── index.html
│           │   ├── robots.txt
│           │   ├── wp-content
│           │   │   ├── plugins
│           │   │   │   └── siteorigin-panels
│           │   │   │       └── css
│           │   │   │           └── front-flex.min.css?ver=2.31.6.css
│           │   │   ├── themes
│           │   │   │   ├── generatepress
│           │   │   │   │   └── assets
│           │   │   │   │       └── css
│           │   │   │   │           ├── all.min.css?ver=3.5.1.css
│           │   │   │   │           └── components
│           │   │   │   │               └── font-icons.min.css?ver=3.5.1.css
│           │   │   │   └── generatepress_child
│           │   │   │       └── style.css?ver=1681659562.css
│           │   │   └── uploads
│           │   │       ├── 2023
│           │   │       │   └── 04
│           │   │       │       └── runartfoundry-home.jpg
│           │   │       └── siteorigin-widgets
│           │   │           └── sow-social-media-buttons-atom-71ec5b83f2bc.css?ver=6.8.3.css
│           │   ├── wp-includes
│           │   │   └── css
│           │   │       ├── dashicons.min.css?ver=6.8.3.css
│           │   │       └── dist
│           │   │           └── block-library
│           │   │               └── style.min.css?ver=6.8.3.css
│           │   └── www.runartfoundry.com
│           │       ├── comments
│           │       │   └── feed
│           │       │       └── index.html
│           │       ├── feed
│           │       │   └── index.html
│           │       ├── index.html
│           │       └── wp-includes
│           │           └── css
│           │               └── dist
│           │                   └── block-library
│           │                       └── style.min.css?ver=6.8.3.css
│           └── wp-content
│               ├── index.php
│               ├── languages
│               │   ├── admin-es_ES.l10n.php
│               │   ├── admin-es_ES.mo
│               │   ├── admin-es_ES.po
│               │   ├── admin-network-es_ES.l10n.php
│               │   ├── admin-network-es_ES.mo
│               │   ├── admin-network-es_ES.po
│               │   ├── continents-cities-es_ES.l10n.php
│               │   ├── continents-cities-es_ES.mo
│               │   ├── continents-cities-es_ES.po
│               │   ├── es_ES-0cc31205f20441b3df1d1b46100f6b8d.json
│               │   ├── es_ES-0ce75ad2f775d1cac9696967d484808c.json
│               │   ├── es_ES-0eebe503220d4a00341eb011b92769b4.json
│               │   ├── es_ES-17179a5f2930647c89151e365f843b6e.json
│               │   ├── es_ES-1780a2033cf98d69ce13c2e5c8510004.json
│               │   ├── es_ES-1a0cd6a7128913b15c1a10dd68951869.json
│               │   ├── es_ES-1bba9045bb07c89671c88a3f328548e8.json
│               │   ├── es_ES-1c4303f02ff93b290e9faad991eeb06f.json
│               │   ├── es_ES-1d17475f620f63a92e2c5d2681c51ee8.json
│               │   ├── es_ES-2617ce121227a46077ede6c69aa9fcb5.json
│               │   ├── es_ES-270d72d1cff17227d37f3244759cbecb.json
│               │   ├── es_ES-28b3c3d595952907e08d98287077426c.json
│               │   ├── es_ES-2b390f85a3048c5b4255fb45960b6514.json
│               │   ├── es_ES-2c5d274ea625dd91556554ad82901529.json
│               │   ├── es_ES-320f4ad9792aaa6dedb1e71cbdf85d57.json
│               │   ├── es_ES-440127dd25bde48a531ded36f33e927b.json
│               │   ├── es_ES-49c6d4acf36cf3aca9f0b2a77617304f.json
│               │   ├── es_ES-4a38fe1c0c45989e44682ba6109d9f46.json
│               │   ├── es_ES-4bfa11da57ff2600004bb500368247f4.json
│               │   ├── es_ES-50278328b502f4eb3f2b8b7ab49324a1.json
│               │   ├── es_ES-5251f7623766a714c8207c7edb938628.json
│               │   ├── es_ES-529362903a5a05b34b06b5e793fb4cf8.json
│               │   ├── es_ES-569e85ef168299eb8c8f24d8ef8c8a78.json
│               │   ├── es_ES-6025add6bde16aaeb12787d250f9b414.json
│               │   ├── es_ES-60d06fac6f98e8e8f0ec5a945738b660.json
│               │   ├── es_ES-68f2cec7514bf8563c723a4d675fcfe6.json
│               │   ├── es_ES-7233008897033de5ee0d14f86a42a65a.json
│               │   ├── es_ES-7289286ed59e90a8f36ae797df62220b.json
│               │   ├── es_ES-7436b7ee9e4f11ac0d618d8cc886eb66.json
│               │   ├── es_ES-77fdfadaf2e1ca3a027d1956b910bc50.json
│               │   ├── es_ES-7b74c8457eaa7fcc50db41b431f8a003.json
│               │   ├── es_ES-7c90cd4398ee2d9d3628c387a87a70e5.json
│               │   ├── es_ES-7d5ca435e60d92f024d46c9257aaa0f7.json
│               │   ├── es_ES-7f13c36c641b114bf18cd0bcc9ecc7e0.json
│               │   ├── es_ES-803bf1ce2131e13efc590c1bc47851fc.json
│               │   ├── es_ES-81c889563f09dd13de1701135dc62941.json
│               │   ├── es_ES-81d6f084cb273e02e15b01bd9ece87f7.json
│               │   ├── es_ES-8240df461220d1d3a028a9a4c5652a5b.json
│               │   ├── es_ES-8860e58c20c6a2ab5876a0f07be43bd9.json
│               │   ├── es_ES-93882e8f9976382d7f724ac595ed7151.json
│               │   ├── es_ES-947c76bb5095da30e16668eec15406b2.json
│               │   ├── es_ES-9b256ea9cd54df92095e04c76758ceb0.json
│               │   ├── es_ES-9c3519f4870fac83dc0dbf18cb6bd4c4.json
│               │   ├── es_ES-9d47a87c240c1d10701cd6a02b28aa1b.json
│               │   ├── es_ES-a25d1cc7bf7ca0b4e114f6bea64943f4.json
│               │   ├── es_ES-a2796e57f680e25d84c4b352ee6d7280.json
│               │   ├── es_ES-a9dc201dcd011fe71849743133052619.json
│               │   ├── es_ES-aabfce98c410957228848dc581e3c420.json
│               │   ├── es_ES-ac23eee47530ac63a1178c827db28087.json
│               │   ├── es_ES-bf0f094965d3d4a95b47babcb35fc136.json
│               │   ├── es_ES-bf23b24175490c2e46aaf92ff6a0c70f.json
│               │   ├── es_ES-c31d5f185753910c14afebc6deb2ce24.json
│               │   ├── es_ES-ca28138671823450e87dfd354f7afc6b.json
│               │   ├── es_ES-daeb084aab42199d26393a56c3465bc0.json
│               │   ├── es_ES-e2791ba830489d23043be8650a22a22b.json
│               │   ├── es_ES-e2e4c4b80f3adf2c70b431bfdb1b4872.json
│               │   ├── es_ES-e53526243551a102928735ec9eed4edf.json
│               │   ├── es_ES-f575f481034e90e21d832e415fd95fcf.json
│               │   ├── es_ES-f70806bf0c7d62f2908bd5a1c3fe4efc.json
│               │   ├── es_ES-f8f49d9fc4a9cf7d78ec99285417bd9c.json
│               │   ├── es_ES.l10n.php
│               │   ├── es_ES.mo
│               │   ├── es_ES.po
│               │   ├── plugins
│               │   │   ├── add-to-any-es_ES.l10n.php
│               │   │   ├── add-to-any-es_ES.mo
│               │   │   ├── add-to-any-es_ES.po
│               │   │   ├── portfolio-post-type-es_ES.mo
│               │   │   ├── portfolio-post-type-es_ES.po
│               │   │   ├── siteorigin-panels-es_ES-e253a16c69fcefea8dc73bf33fd8abdb.json
│               │   │   ├── siteorigin-panels-es_ES.l10n.php
│               │   │   ├── siteorigin-panels-es_ES.mo
│               │   │   ├── siteorigin-panels-es_ES.po
│               │   │   ├── so-widgets-bundle-es_ES-7c92f8f1e9b5fde763c4549425c43ce2.json
│               │   │   ├── so-widgets-bundle-es_ES-ff6b49c49b5211006326f2e3c5ec3e67.json
│               │   │   ├── so-widgets-bundle-es_ES.l10n.php
│               │   │   ├── so-widgets-bundle-es_ES.mo
│               │   │   ├── so-widgets-bundle-es_ES.po
│               │   │   ├── wordpress-seo-es_ES-06ac8eb626d13e53d0f09739a2ab6a7e.json
│               │   │   ├── wordpress-seo-es_ES-1765c84b9a2e3034c5ab0a9b0842cb21.json
│               │   │   ├── wordpress-seo-es_ES-3ab1863386cca0be6ab4aa906cacadbd.json
│               │   │   ├── wordpress-seo-es_ES-58afcf2303c7e92a99f4dfdf75c54842.json
│               │   │   ├── wordpress-seo-es_ES-59a157b73a79db8a63459f9a2e1b874b.json
│               │   │   ├── wordpress-seo-es_ES-606033e8cb263b032d13356d7a627ed5.json
│               │   │   ├── wordpress-seo-es_ES-6ade687c7936490c88bc39df19ea71a0.json
│               │   │   ├── wordpress-seo-es_ES-6f380ab0bcb032c00d3d0ff21664335d.json
│               │   │   ├── wordpress-seo-es_ES-6ffccefef7026e678d85c6b56bd29680.json
│               │   │   ├── wordpress-seo-es_ES-753e370a61af6ba5ccabe91cc950cbcb.json
│               │   │   ├── wordpress-seo-es_ES-786eeb1e9fb710b6d8885049b18564b3.json
│               │   │   ├── wordpress-seo-es_ES-81d02401639ac0f30dc9d7738fcbf629.json
│               │   │   ├── wordpress-seo-es_ES-826f41c23138627439d01b2b0133dbc5.json
│               │   │   ├── wordpress-seo-es_ES-8a9083701e738b3c956ea2c9a8a84375.json
│               │   │   ├── wordpress-seo-es_ES-8c2f72a2c46baea606be9a7b0c1a23d8.json
│               │   │   ├── wordpress-seo-es_ES-8d6ddb629914013ba22594dab46408c3.json
│               │   │   ├── wordpress-seo-es_ES-9f6244fe05b49fabf96551959cf899a6.json
│               │   │   ├── wordpress-seo-es_ES-9fc912fe9f73e39d5df0779b31bb1a6f.json
│               │   │   ├── wordpress-seo-es_ES-9ff580649b466f65633b98bb16c34525.json
│               │   │   ├── wordpress-seo-es_ES-a35a702af4a7fbb6d2d4db8c193dd940.json
│               │   │   ├── wordpress-seo-es_ES-a4e25a0fbd268367ae0af1e06b841f78.json
│               │   │   ├── wordpress-seo-es_ES-afe43fe171170bbc6083c10610a75434.json
│               │   │   ├── wordpress-seo-es_ES-b1439a828d6d7684a875580ccba87936.json
│               │   │   ├── wordpress-seo-es_ES-b2bb3542a05d1a95a5866b83cc7b8a5f.json
│               │   │   ├── wordpress-seo-es_ES-b7ad74768b6540fffc24bcde63413725.json
│               │   │   ├── wordpress-seo-es_ES-c1a0e4b150b113a514f162d42c0c8ab5.json
│               │   │   ├── wordpress-seo-es_ES-c1b15194a6181a17d3344302011bddf5.json
│               │   │   ├── wordpress-seo-es_ES-cab448a7f08880f4d86d9bdf409b7cb7.json
│               │   │   ├── wordpress-seo-es_ES-d084ad2ca2d23f1331bbd1040999834e.json
│               │   │   ├── wordpress-seo-es_ES-d6bf43f32d0c3331e709fa67e6be35a2.json
│               │   │   ├── wordpress-seo-es_ES-e422758335e56c41009e56217163c93a.json
│               │   │   ├── wordpress-seo-es_ES-fb9a41ab0ae57dcb4b10ea3343658bcc.json
│               │   │   ├── wordpress-seo-es_ES.mo
│               │   │   ├── wordpress-seo-es_ES.po
│               │   │   ├── wp-fastest-cache-es_ES.mo
│               │   │   ├── wp-fastest-cache-es_ES.po
│               │   │   ├── wp-optimize-es_ES.l10n.php
│               │   │   ├── wp-optimize-es_ES.mo
│               │   │   └── wp-optimize-es_ES.po
│               │   └── themes
│               │       ├── generatepress-es_ES-6ab8cd0da0092f2242f67a88400ac416.json
│               │       ├── generatepress-es_ES-a4d5c25d2326d956ff983a2c33d1c10c.json
│               │       ├── generatepress-es_ES.l10n.php
│               │       ├── generatepress-es_ES.mo
│               │       ├── generatepress-es_ES.po
│               │       ├── twentytwentyfive-es_ES.l10n.php
│               │       ├── twentytwentyfive-es_ES.mo
│               │       ├── twentytwentyfive-es_ES.po
│               │       ├── twentytwentyfour-es_ES.l10n.php
│               │       ├── twentytwentyfour-es_ES.mo
│               │       └── twentytwentyfour-es_ES.po
│               ├── mu-plugins
│               │   └── sso.php
│               ├── plugins
│               │   ├── add-to-any
│               │   │   ├── README.txt
│               │   │   ├── add-to-any.php
│               │   │   ├── addtoany.admin.js
│               │   │   ├── addtoany.admin.php
│               │   │   ├── addtoany.amp.css
│               │   │   ├── addtoany.compat.php
│               │   │   ├── addtoany.min.css
│               │   │   ├── addtoany.min.js
│               │   │   ├── addtoany.services.php
│               │   │   ├── addtoany.update.php
│               │   │   ├── addtoany.widgets.php
│               │   │   ├── changelog.txt
│               │   │   ├── icons
│               │   │   │   ├── a2a.svg
│               │   │   │   ├── amazon.svg
│               │   │   │   ├── aol.svg
│               │   │   │   ├── balatarin.svg
│               │   │   │   ├── behance.svg
│               │   │   │   ├── bibsonomy.svg
│               │   │   │   ├── blogger.svg
│               │   │   │   ├── blogmarks.svg
│               │   │   │   ├── bluesky.svg
│               │   │   │   ├── bookmarks_fr.svg
│               │   │   │   ├── box.svg
│               │   │   │   ├── buffer.svg
│               │   │   │   ├── dailyrotation.svg
│               │   │   │   ├── diary_ru.svg
│               │   │   │   ├── diaspora.svg
│               │   │   │   ├── digg.svg
│               │   │   │   ├── diigo.svg
│               │   │   │   ├── discord.svg
│               │   │   │   ├── douban.svg
│               │   │   │   ├── download.svg
│               │   │   │   ├── draugiem.svg
│               │   │   │   ├── email.svg
│               │   │   │   ├── evernote.svg
│               │   │   │   ├── facebook.svg
│               │   │   │   ├── facebook_like_2x.png
│               │   │   │   ├── facebook_messenger.svg
│               │   │   │   ├── fark.svg
│               │   │   │   ├── feed.svg
│               │   │   │   ├── feedbin.svg
│               │   │   │   ├── feedblitz.svg
│               │   │   │   ├── feedly.svg
│               │   │   │   ├── find.svg
│               │   │   │   ├── flickr.svg
│               │   │   │   ├── flipboard.svg
│               │   │   │   ├── folkd.svg
│               │   │   │   ├── foursquare.svg
│               │   │   │   ├── github.svg
│               │   │   │   ├── gmail.svg
│               │   │   │   ├── google.svg
│               │   │   │   ├── google_classroom.svg
│               │   │   │   ├── google_maps.svg
│               │   │   │   ├── google_translate.svg
│               │   │   │   ├── hatena.svg
│               │   │   │   ├── houzz.svg
│               │   │   │   ├── instagram.svg
│               │   │   │   ├── instapaper.svg
│               │   │   │   ├── itunes.svg
│               │   │   │   ├── kakao.svg
│               │   │   │   ├── kindle.svg
│               │   │   │   ├── known.svg
│               │   │   │   ├── line.svg
│               │   │   │   ├── link.svg
│               │   │   │   ├── linkedin.svg
│               │   │   │   ├── linkedin_share_2x.png
│               │   │   │   ├── livejournal.svg
│               │   │   │   ├── mail_ru.svg
│               │   │   │   ├── mastodon.svg
│               │   │   │   ├── medium.svg
│               │   │   │   ├── mendeley.svg
│               │   │   │   ├── meneame.svg
│               │   │   │   ├── mewe.svg
│               │   │   │   ├── micro_blog.svg
│               │   │   │   ├── microsoft_teams.svg
│               │   │   │   ├── mix.svg
│               │   │   │   ├── mixi.svg
│               │   │   │   ├── myspace.svg
│               │   │   │   ├── netvibes.svg
│               │   │   │   ├── newsalloy.svg
│               │   │   │   ├── odnoklassniki.svg
│               │   │   │   ├── oldreader.svg
│               │   │   │   ├── outlook_com.svg
│               │   │   │   ├── papaly.svg
│               │   │   │   ├── pinboard.svg
│               │   │   │   ├── pinterest.svg
│               │   │   │   ├── pinterest_pin_2x.png
│               │   │   │   ├── plurk.svg
│               │   │   │   ├── pocket.svg
│               │   │   │   ├── podnova.svg
│               │   │   │   ├── print.svg
│               │   │   │   ├── printfriendly.svg
│               │   │   │   ├── pusha.svg
│               │   │   │   ├── qzone.svg
│               │   │   │   ├── raindrop_io.svg
│               │   │   │   ├── reddit.svg
│               │   │   │   ├── rediff.svg
│               │   │   │   ├── refind.svg
│               │   │   │   ├── share1.svg
│               │   │   │   ├── share2.svg
│               │   │   │   ├── sina_weibo.svg
│               │   │   │   ├── sitejot.svg
│               │   │   │   ├── skype.svg
│               │   │   │   ├── slashdot.svg
│               │   │   │   ├── sms.svg
│               │   │   │   ├── snapchat.svg
│               │   │   │   ├── steam.svg
│               │   │   │   ├── stocktwits.svg
│               │   │   │   ├── svejo.svg
│               │   │   │   ├── symbaloo.svg
│               │   │   │   ├── telegram.svg
│               │   │   │   ├── thefreedictionary.svg
│               │   │   │   ├── threads.svg
│               │   │   │   ├── threema.svg
│               │   │   │   ├── tiktok.svg
│               │   │   │   ├── transparent.gif
│               │   │   │   ├── trello.svg
│               │   │   │   ├── tumblr.svg
│               │   │   │   ├── twiddla.svg
│               │   │   │   ├── twitch.svg
│               │   │   │   ├── twitter.svg
│               │   │   │   ├── twitter_tweet_2x.png
│               │   │   │   ├── typepad.svg
│               │   │   │   ├── viber.svg
│               │   │   │   ├── vimeo.svg
│               │   │   │   ├── vk.svg
│               │   │   │   ├── wechat.svg
│               │   │   │   ├── whatsapp.svg
│               │   │   │   ├── wordpress.svg
│               │   │   │   ├── wykop.svg
│               │   │   │   ├── x.svg
│               │   │   │   ├── xing.svg
│               │   │   │   ├── y18.svg
│               │   │   │   ├── yahoo.svg
│               │   │   │   ├── yelp.svg
│               │   │   │   ├── youtube.svg
│               │   │   │   └── yummly.svg
│               │   │   └── wpml-config.xml
│               │   ├── gp-premium
│               │   │   ├── backgrounds
│               │   │   │   ├── functions
│               │   │   │   │   ├── css.php
│               │   │   │   │   ├── functions.php
│               │   │   │   │   └── secondary-nav-backgrounds.php
│               │   │   │   └── generate-backgrounds.php
│               │   │   ├── blog
│               │   │   │   ├── functions
│               │   │   │   │   ├── columns.php
│               │   │   │   │   ├── css
│               │   │   │   │   │   ├── columns.css
│               │   │   │   │   │   ├── columns.min.css
│               │   │   │   │   │   ├── featured-images.css
│               │   │   │   │   │   ├── featured-images.min.css
│               │   │   │   │   │   ├── style.css
│               │   │   │   │   │   └── style.min.css
│               │   │   │   │   ├── customizer.php
│               │   │   │   │   ├── defaults.php
│               │   │   │   │   ├── generate-blog.php
│               │   │   │   │   ├── images.php
│               │   │   │   │   ├── js
│               │   │   │   │   │   ├── controls.js
│               │   │   │   │   │   ├── customizer.js
│               │   │   │   │   │   ├── infinite-scroll.pkgd.min.js
│               │   │   │   │   │   ├── scripts.js
│               │   │   │   │   │   └── scripts.min.js
│               │   │   │   │   └── migrate.php
│               │   │   │   └── generate-blog.php
│               │   │   ├── colors
│               │   │   │   ├── functions
│               │   │   │   │   ├── functions.php
│               │   │   │   │   ├── js
│               │   │   │   │   │   ├── customizer.js
│               │   │   │   │   │   ├── menu-plus-customizer.js
│               │   │   │   │   │   └── wc-customizer.js
│               │   │   │   │   ├── secondary-nav-colors.php
│               │   │   │   │   ├── slideout-nav-colors.php
│               │   │   │   │   └── woocommerce-colors.php
│               │   │   │   └── generate-colors.php
│               │   │   ├── copyright
│               │   │   │   ├── functions
│               │   │   │   │   ├── functions.php
│               │   │   │   │   └── js
│               │   │   │   │       └── customizer.js
│               │   │   │   └── generate-copyright.php
│               │   │   ├── disable-elements
│               │   │   │   ├── functions
│               │   │   │   │   └── functions.php
│               │   │   │   └── generate-disable-elements.php
│               │   │   ├── dist
│               │   │   │   ├── adjacent-posts.asset.php
│               │   │   │   ├── adjacent-posts.js
│               │   │   │   ├── block-elements-rtl.css
│               │   │   │   ├── block-elements.asset.php
│               │   │   │   ├── block-elements.css
│               │   │   │   ├── block-elements.js
│               │   │   │   ├── customizer.asset.php
│               │   │   │   ├── customizer.js
│               │   │   │   ├── dashboard.asset.php
│               │   │   │   ├── dashboard.js
│               │   │   │   ├── editor-rtl.css
│               │   │   │   ├── editor.asset.php
│               │   │   │   ├── editor.css
│               │   │   │   ├── editor.js
│               │   │   │   ├── font-library-rtl.css
│               │   │   │   ├── font-library.asset.php
│               │   │   │   ├── font-library.css
│               │   │   │   ├── font-library.js
│               │   │   │   ├── packages-rtl.css
│               │   │   │   ├── packages.asset.php
│               │   │   │   ├── packages.css
│               │   │   │   ├── packages.js
│               │   │   │   ├── site-library-rtl.css
│               │   │   │   ├── site-library.asset.php
│               │   │   │   ├── site-library.css
│               │   │   │   ├── site-library.js
│               │   │   │   ├── style-dashboard-rtl.css
│               │   │   │   └── style-dashboard.css
│               │   │   ├── elements
│               │   │   │   ├── assets
│               │   │   │   │   ├── admin
│               │   │   │   │   │   ├── author-image-placeholder.png
│               │   │   │   │   │   ├── background-image-fallback.jpg
│               │   │   │   │   │   ├── balloon.css
│               │   │   │   │   │   ├── elements.css
│               │   │   │   │   │   ├── elements.js
│               │   │   │   │   │   ├── featured-image-placeholder.png
│               │   │   │   │   │   ├── metabox.css
│               │   │   │   │   │   ├── metabox.js
│               │   │   │   │   │   └── spinner.gif
│               │   │   │   │   └── js
│               │   │   │   │       ├── parallax.js
│               │   │   │   │       └── parallax.min.js
│               │   │   │   ├── class-block-elements.php
│               │   │   │   ├── class-block.php
│               │   │   │   ├── class-conditions.php
│               │   │   │   ├── class-elements-helper.php
│               │   │   │   ├── class-hero.php
│               │   │   │   ├── class-hooks.php
│               │   │   │   ├── class-layout.php
│               │   │   │   ├── class-metabox.php
│               │   │   │   ├── class-post-type.php
│               │   │   │   └── elements.php
│               │   │   ├── font-library
│               │   │   │   ├── class-font-library-cpt.php
│               │   │   │   ├── class-font-library-optimize.php
│               │   │   │   ├── class-font-library-rest.php
│               │   │   │   └── class-font-library.php
│               │   │   ├── general
│               │   │   │   ├── class-external-file-css.php
│               │   │   │   ├── enqueue-scripts.php
│               │   │   │   ├── icons
│               │   │   │   │   ├── gp-premium.eot
│               │   │   │   │   ├── gp-premium.svg
│               │   │   │   │   ├── gp-premium.ttf
│               │   │   │   │   ├── gp-premium.woff
│               │   │   │   │   ├── icons.css
│               │   │   │   │   └── icons.min.css
│               │   │   │   ├── icons.php
│               │   │   │   ├── js
│               │   │   │   │   ├── smooth-scroll.js
│               │   │   │   │   └── smooth-scroll.min.js
│               │   │   │   └── smooth-scroll.php
│               │   │   ├── gp-premium.php
│               │   │   ├── hooks
│               │   │   │   ├── functions
│               │   │   │   │   ├── assets
│               │   │   │   │   │   ├── css
│               │   │   │   │   │   │   └── hooks.css
│               │   │   │   │   │   └── js
│               │   │   │   │   │       ├── admin.js
│               │   │   │   │   │       └── jquery.cookie.js
│               │   │   │   │   ├── functions.php
│               │   │   │   │   └── hooks.php
│               │   │   │   └── generate-hooks.php
│               │   │   ├── inc
│               │   │   │   ├── class-adjacent-posts.php
│               │   │   │   ├── class-dashboard.php
│               │   │   │   ├── class-register-dynamic-tags.php
│               │   │   │   ├── class-rest.php
│               │   │   │   ├── class-singleton.php
│               │   │   │   ├── deprecated-admin.php
│               │   │   │   ├── deprecated.php
│               │   │   │   ├── functions.php
│               │   │   │   └── legacy
│               │   │   │       ├── activation.php
│               │   │   │       ├── assets
│               │   │   │       │   ├── dashboard.css
│               │   │   │       │   └── dashboard.js
│               │   │   │       ├── dashboard.php
│               │   │   │       ├── import-export.php
│               │   │   │       └── reset.php
│               │   │   ├── langs
│               │   │   │   ├── gp-premium-ar.mo
│               │   │   │   ├── gp-premium-bn_BD.mo
│               │   │   │   ├── gp-premium-cs_CZ.mo
│               │   │   │   ├── gp-premium-da_DK.mo
│               │   │   │   ├── gp-premium-de_DE-42da344ccb044413769d16ed3484307b.json
│               │   │   │   ├── gp-premium-de_DE-53e2a1d5945b8d2b1c35e81ae1e532f3.json
│               │   │   │   ├── gp-premium-de_DE-92fa58377f1b6f7bef9c785c31ae29ff.json
│               │   │   │   ├── gp-premium-de_DE-cbab080b0f20fd6c323029398be6c986.json
│               │   │   │   ├── gp-premium-de_DE-ecf9f3c2af10c4f2dfbf4f42504922d1.json
│               │   │   │   ├── gp-premium-de_DE.mo
│               │   │   │   ├── gp-premium-es_AR.mo
│               │   │   │   ├── gp-premium-es_ES-42da344ccb044413769d16ed3484307b.json
│               │   │   │   ├── gp-premium-es_ES-53e2a1d5945b8d2b1c35e81ae1e532f3.json
│               │   │   │   ├── gp-premium-es_ES-92fa58377f1b6f7bef9c785c31ae29ff.json
│               │   │   │   ├── gp-premium-es_ES-cbab080b0f20fd6c323029398be6c986.json
│               │   │   │   ├── gp-premium-es_ES-ecf9f3c2af10c4f2dfbf4f42504922d1.json
│               │   │   │   ├── gp-premium-es_ES.mo
│               │   │   │   ├── gp-premium-fi-42da344ccb044413769d16ed3484307b.json
│               │   │   │   ├── gp-premium-fi-53e2a1d5945b8d2b1c35e81ae1e532f3.json
│               │   │   │   ├── gp-premium-fi-92fa58377f1b6f7bef9c785c31ae29ff.json
│               │   │   │   ├── gp-premium-fi-cbab080b0f20fd6c323029398be6c986.json
│               │   │   │   ├── gp-premium-fi-ecf9f3c2af10c4f2dfbf4f42504922d1.json
│               │   │   │   ├── gp-premium-fi.mo
│               │   │   │   ├── gp-premium-fr_FR-42da344ccb044413769d16ed3484307b.json
│               │   │   │   ├── gp-premium-fr_FR-53e2a1d5945b8d2b1c35e81ae1e532f3.json
│               │   │   │   ├── gp-premium-fr_FR-92fa58377f1b6f7bef9c785c31ae29ff.json
│               │   │   │   ├── gp-premium-fr_FR.mo
│               │   │   │   ├── gp-premium-hr.mo
│               │   │   │   ├── gp-premium-hu_HU.mo
│               │   │   │   ├── gp-premium-it_IT.mo
│               │   │   │   ├── gp-premium-nb_NO.mo
│               │   │   │   ├── gp-premium-nl_NL-42da344ccb044413769d16ed3484307b.json
│               │   │   │   ├── gp-premium-nl_NL-53e2a1d5945b8d2b1c35e81ae1e532f3.json
│               │   │   │   ├── gp-premium-nl_NL-92fa58377f1b6f7bef9c785c31ae29ff.json
│               │   │   │   ├── gp-premium-nl_NL-cbab080b0f20fd6c323029398be6c986.json
│               │   │   │   ├── gp-premium-nl_NL-ecf9f3c2af10c4f2dfbf4f42504922d1.json
│               │   │   │   ├── gp-premium-nl_NL.mo
│               │   │   │   ├── gp-premium-pl_PL.mo
│               │   │   │   ├── gp-premium-pt_BR.mo
│               │   │   │   ├── gp-premium-pt_PT-42da344ccb044413769d16ed3484307b.json
│               │   │   │   ├── gp-premium-pt_PT-53e2a1d5945b8d2b1c35e81ae1e532f3.json
│               │   │   │   ├── gp-premium-pt_PT-92fa58377f1b6f7bef9c785c31ae29ff.json
│               │   │   │   ├── gp-premium-pt_PT.mo
│               │   │   │   ├── gp-premium-ru_RU-42da344ccb044413769d16ed3484307b.json
│               │   │   │   ├── gp-premium-ru_RU-53e2a1d5945b8d2b1c35e81ae1e532f3.json
│               │   │   │   ├── gp-premium-ru_RU-92fa58377f1b6f7bef9c785c31ae29ff.json
│               │   │   │   ├── gp-premium-ru_RU-cbab080b0f20fd6c323029398be6c986.json
│               │   │   │   ├── gp-premium-ru_RU-ecf9f3c2af10c4f2dfbf4f42504922d1.json
│               │   │   │   ├── gp-premium-ru_RU.mo
│               │   │   │   ├── gp-premium-sv_SE-42da344ccb044413769d16ed3484307b.json
│               │   │   │   ├── gp-premium-sv_SE-53e2a1d5945b8d2b1c35e81ae1e532f3.json
│               │   │   │   ├── gp-premium-sv_SE-92fa58377f1b6f7bef9c785c31ae29ff.json
│               │   │   │   ├── gp-premium-sv_SE-cbab080b0f20fd6c323029398be6c986.json
│               │   │   │   ├── gp-premium-sv_SE-ecf9f3c2af10c4f2dfbf4f42504922d1.json
│               │   │   │   ├── gp-premium-sv_SE.mo
│               │   │   │   ├── gp-premium-uk.mo
│               │   │   │   ├── gp-premium-vi.mo
│               │   │   │   └── gp-premium-zh_CN.mo
│               │   │   ├── library
│               │   │   │   ├── alpha-color-picker
│               │   │   │   │   ├── wp-color-picker-alpha.js
│               │   │   │   │   └── wp-color-picker-alpha.min.js
│               │   │   │   ├── class-make-css.php
│               │   │   │   ├── class-plugin-updater.php
│               │   │   │   ├── customizer
│               │   │   │   │   ├── active-callbacks.php
│               │   │   │   │   ├── controls
│               │   │   │   │   │   ├── class-action-button-control.php
│               │   │   │   │   │   ├── class-alpha-color-control.php
│               │   │   │   │   │   ├── class-backgrounds-control.php
│               │   │   │   │   │   ├── class-control-toggle.php
│               │   │   │   │   │   ├── class-copyright-control.php
│               │   │   │   │   │   ├── class-deprecated.php
│               │   │   │   │   │   ├── class-information-control.php
│               │   │   │   │   │   ├── class-range-slider-control.php
│               │   │   │   │   │   ├── class-refresh-button-control.php
│               │   │   │   │   │   ├── class-section-shortcuts-control.php
│               │   │   │   │   │   ├── class-spacing-control.php
│               │   │   │   │   │   ├── class-title-control.php
│               │   │   │   │   │   ├── class-typography-control.php
│               │   │   │   │   │   ├── css
│               │   │   │   │   │   │   ├── alpha-color-picker.css
│               │   │   │   │   │   │   ├── button-actions.css
│               │   │   │   │   │   │   ├── control-toggle-customizer.css
│               │   │   │   │   │   │   ├── information-control.css
│               │   │   │   │   │   │   ├── section-shortcuts.css
│               │   │   │   │   │   │   ├── selectWoo.min.css
│               │   │   │   │   │   │   ├── slider-customizer.css
│               │   │   │   │   │   │   ├── spacing-customizer.css
│               │   │   │   │   │   │   ├── title-customizer.css
│               │   │   │   │   │   │   ├── transparency-grid.png
│               │   │   │   │   │   │   └── typography-customizer.css
│               │   │   │   │   │   └── js
│               │   │   │   │   │       ├── alpha-color-picker.js
│               │   │   │   │   │       ├── backgrounds-customizer.js
│               │   │   │   │   │       ├── button-actions.js
│               │   │   │   │   │       ├── control-toggle-customizer.js
│               │   │   │   │   │       ├── copyright-customizer.js
│               │   │   │   │   │       ├── generatepress-controls.js
│               │   │   │   │   │       ├── section-shortcuts.js
│               │   │   │   │   │       ├── selectWoo.min.js
│               │   │   │   │   │       ├── slider-customizer.js
│               │   │   │   │   │       ├── spacing-customizer.js
│               │   │   │   │   │       └── typography-customizer.js
│               │   │   │   │   ├── deprecated.php
│               │   │   │   │   └── sanitize.php
│               │   │   │   ├── customizer-helpers.php
│               │   │   │   └── select2
│               │   │   │       ├── select2.full.min.js
│               │   │   │       └── select2.min.css
│               │   │   ├── menu-plus
│               │   │   │   ├── fields
│               │   │   │   │   └── slideout-nav-colors.php
│               │   │   │   ├── functions
│               │   │   │   │   ├── css
│               │   │   │   │   │   ├── menu-logo.css
│               │   │   │   │   │   ├── menu-logo.min.css
│               │   │   │   │   │   ├── navigation-branding-flex.css
│               │   │   │   │   │   ├── navigation-branding-flex.min.css
│               │   │   │   │   │   ├── navigation-branding.css
│               │   │   │   │   │   ├── navigation-branding.min.css
│               │   │   │   │   │   ├── offside.css
│               │   │   │   │   │   ├── offside.min.css
│               │   │   │   │   │   ├── sticky.css
│               │   │   │   │   │   └── sticky.min.css
│               │   │   │   │   ├── generate-menu-plus.php
│               │   │   │   │   └── js
│               │   │   │   │       ├── offside.js
│               │   │   │   │       ├── offside.min.js
│               │   │   │   │       ├── sticky.js
│               │   │   │   │       └── sticky.min.js
│               │   │   │   └── generate-menu-plus.php
│               │   │   ├── page-header
│               │   │   │   ├── functions
│               │   │   │   │   ├── css
│               │   │   │   │   │   ├── metabox.css
│               │   │   │   │   │   ├── page-header.css
│               │   │   │   │   │   └── page-header.min.css
│               │   │   │   │   ├── functions.php
│               │   │   │   │   ├── global-locations.php
│               │   │   │   │   ├── js
│               │   │   │   │   │   ├── full-height.js
│               │   │   │   │   │   ├── full-height.min.js
│               │   │   │   │   │   ├── jquery.vide.min.js
│               │   │   │   │   │   ├── lc_switch.js
│               │   │   │   │   │   ├── metabox.js
│               │   │   │   │   │   ├── parallax.js
│               │   │   │   │   │   └── parallax.min.js
│               │   │   │   │   ├── metabox.php
│               │   │   │   │   ├── page-header.php
│               │   │   │   │   ├── post-image.php
│               │   │   │   │   └── post-type.php
│               │   │   │   └── generate-page-header.php
│               │   │   ├── readme.txt
│               │   │   ├── secondary-nav
│               │   │   │   ├── fields
│               │   │   │   │   └── secondary-navigation.php
│               │   │   │   ├── functions
│               │   │   │   │   ├── css
│               │   │   │   │   │   ├── main-mobile.css
│               │   │   │   │   │   ├── main-mobile.min.css
│               │   │   │   │   │   ├── main.css
│               │   │   │   │   │   ├── main.min.css
│               │   │   │   │   │   ├── style-mobile.css
│               │   │   │   │   │   ├── style-mobile.min.css
│               │   │   │   │   │   ├── style.css
│               │   │   │   │   │   └── style.min.css
│               │   │   │   │   ├── css.php
│               │   │   │   │   ├── functions.php
│               │   │   │   │   └── js
│               │   │   │   │       └── customizer.js
│               │   │   │   └── generate-secondary-nav.php
│               │   │   ├── sections
│               │   │   │   ├── functions
│               │   │   │   │   ├── css
│               │   │   │   │   │   ├── style.css
│               │   │   │   │   │   └── style.min.css
│               │   │   │   │   ├── generate-sections.php
│               │   │   │   │   ├── js
│               │   │   │   │   │   ├── parallax.js
│               │   │   │   │   │   └── parallax.min.js
│               │   │   │   │   ├── metaboxes
│               │   │   │   │   │   ├── css
│               │   │   │   │   │   │   ├── generate-sections-metabox.css
│               │   │   │   │   │   │   └── lc_switch.css
│               │   │   │   │   │   ├── js
│               │   │   │   │   │   │   ├── generate-sections-metabox-4.9.js
│               │   │   │   │   │   │   └── generate-sections-metabox.js
│               │   │   │   │   │   ├── metabox-functions.php
│               │   │   │   │   │   └── views
│               │   │   │   │   │       ├── sections-template.php
│               │   │   │   │   │       ├── sections.php
│               │   │   │   │   │       └── use-sections.php
│               │   │   │   │   └── templates
│               │   │   │   │       └── template.php
│               │   │   │   └── generate-sections.php
│               │   │   ├── site-library
│               │   │   │   ├── class-site-library-helper.php
│               │   │   │   ├── class-site-library-rest.php
│               │   │   │   ├── class-site-library.php
│               │   │   │   ├── classes
│               │   │   │   │   ├── class-beaver-builder-batch-processing.php
│               │   │   │   │   ├── class-content-importer.php
│               │   │   │   │   ├── class-site-import-image.php
│               │   │   │   │   └── class-site-widget-importer.php
│               │   │   │   └── libs
│               │   │   │       └── wxr-importer
│               │   │   │           ├── WPImporterLogger.php
│               │   │   │           ├── WXRImportInfo.php
│               │   │   │           └── WXRImporter.php
│               │   │   ├── spacing
│               │   │   │   ├── functions
│               │   │   │   │   ├── customizer
│               │   │   │   │   │   ├── content-spacing.php
│               │   │   │   │   │   ├── footer-spacing.php
│               │   │   │   │   │   ├── header-spacing.php
│               │   │   │   │   │   ├── js
│               │   │   │   │   │   │   └── customizer.js
│               │   │   │   │   │   ├── navigation-spacing.php
│               │   │   │   │   │   ├── secondary-nav-spacing.php
│               │   │   │   │   │   ├── sidebar-spacing.php
│               │   │   │   │   │   └── top-bar-spacing.php
│               │   │   │   │   ├── functions.php
│               │   │   │   │   └── migration.php
│               │   │   │   └── generate-spacing.php
│               │   │   ├── typography
│               │   │   │   ├── functions
│               │   │   │   │   ├── functions.php
│               │   │   │   │   ├── google-fonts.json
│               │   │   │   │   ├── js
│               │   │   │   │   │   └── customizer.js
│               │   │   │   │   ├── migration.php
│               │   │   │   │   ├── secondary-nav-fonts.php
│               │   │   │   │   ├── slideout-nav-fonts.php
│               │   │   │   │   └── woocommerce-fonts.php
│               │   │   │   └── generate-fonts.php
│               │   │   ├── webpack.config.js
│               │   │   ├── woocommerce
│               │   │   │   ├── fields
│               │   │   │   │   └── woocommerce-colors.php
│               │   │   │   ├── functions
│               │   │   │   │   ├── css
│               │   │   │   │   │   ├── woocommerce-mobile.css
│               │   │   │   │   │   ├── woocommerce-mobile.min.css
│               │   │   │   │   │   ├── woocommerce.css
│               │   │   │   │   │   └── woocommerce.min.css
│               │   │   │   │   ├── customizer
│               │   │   │   │   │   ├── customizer.php
│               │   │   │   │   │   └── js
│               │   │   │   │   │       └── customizer.js
│               │   │   │   │   ├── functions.php
```
</details>


<details><summary><code>audits/_structure/raw_count_by_extension.csv</code></summary>

```
.jpg,5608
.php,2476
.png,746
.js,666
.css,307
.svg,284
.json,191
.md,137
.mo,78
.woff2,63
.txt,58
.html,52
.less,47
.webp,46
.po,43
,28
.gif,24
.eot,21
.ttf,21
.woff,21
.xml,12
.jpg~20251001145720~,9
.jpg~20251001145701~,8
.jpg~20251001145703~,8
.jpg~20251001145705~,8
.jpg~20251001145717~,8
.jpg~20251001145718~,8
.jpg~20251001145722~,8
.jpg~20251001145735~,8
.jpg~20251001145737~,8
.jpg~20251001145739~,8
.jpg~20251001145740~,8
.jpg~20251001145743~,8
.jpg~20251001145749~,8
.jpg~20251001145752~,8
.jpg~20251001145753~,8
.jpg~20251001145756~,8
.jpg~20251001145758~,8
.jpg~20251001145800~,8
.jpg~20251001145806~,8
.jpg~20251001145827~,8
.jpg~20251001145832~,8
.jpg~20251001145834~,8
.jpg~20251001145841~,8
.jpg~20251001145849~,8
.jpg~20251001145903~,8
.jpg~20251001145906~,8
.jpg~20251001145909~,8
.jpg~20251001145912~,8
.jpg~20251001145923~,8
.jpg~20251001145925~,8
.jpg~20251001145927~,8
.jpg~20251001145939~,8
.jpg~20251001145941~,8
.jpg~20251001145947~,8
.jpg~20251001145949~,8
.jpg~20251001145951~,8
.jpg~20251001145953~,8
.jpg~20251001145956~,8
.jpg~20251001145958~,8
.jpg~20251001150001~,8
.jpg~20251001145702~,7
.jpg~20251001145706~,7
.jpg~20251001145713~,7
.jpg~20251001145714~,7
.jpg~20251001145715~,7
.jpg~20251001145716~,7
.jpg~20251001145721~,7
.jpg~20251001145733~,7
.jpg~20251001145734~,7
.jpg~20251001145744~,7
.jpg~20251001145745~,7
.jpg~20251001145746~,7
.jpg~20251001145747~,7
.jpg~20251001145751~,7
.jpg~20251001145802~,7
.jpg~20251001145803~,7
.jpg~20251001145804~,7
.jpg~20251001145826~,7
.jpg~20251001145828~,7
.jpg~20251001145830~,7
.jpg~20251001145836~,7
.jpg~20251001145839~,7
.jpg~20251001145840~,7
.jpg~20251001145842~,7
.jpg~20251001145843~,7
.jpg~20251001145846~,7
.jpg~20251001145847~,7
.jpg~20251001145850~,7
.jpg~20251001145851~,7
.jpg~20251001145852~,7
.jpg~20251001145853~,7
.jpg~20251001145855~,7
.jpg~20251001145856~,7
.jpg~20251001145859~,7
.jpg~20251001145904~,7
.jpg~20251001145905~,7
.jpg~20251001145907~,7
.jpg~20251001145908~,7
.jpg~20251001145910~,7
.jpg~20251001145911~,7
.jpg~20251001145914~,7
.jpg~20251001145916~,7
.jpg~20251001145930~,7
.jpg~20251001145932~,7
.jpg~20251001145936~,7
.jpg~20251001145938~,7
.jpg~20251001145944~,7
.jpg~20251001145945~,7
.jpg~20251001145946~,7
.jpg~20251001145952~,7
.jpg~20251001145954~,7
.jpg~20251001145959~,7
.jpg~20251001150000~,7
.jpg~20251001150002~,7
.jpg~20251001150003~,7
.jpg~20251001150006~,7
.log,7
.jpg~20251001145658~,6
.jpg~20251001145659~,6
.jpg~20251001145700~,6
.jpg~20251001145707~,6
.jpg~20251001145708~,6
.jpg~20251001145719~,6
.jpg~20251001145724~,6
.jpg~20251001145725~,6
.jpg~20251001145726~,6
.jpg~20251001145730~,6
.jpg~20251001145731~,6
.jpg~20251001145732~,6
.jpg~20251001145736~,6
.jpg~20251001145738~,6
.jpg~20251001145741~,6
.jpg~20251001145742~,6
.jpg~20251001145748~,6
.jpg~20251001145750~,6
.jpg~20251001145754~,6
.jpg~20251001145755~,6
.jpg~20251001145757~,6
.jpg~20251001145759~,6
.jpg~20251001145801~,6
.jpg~20251001145805~,6
.jpg~20251001145807~,6
.jpg~20251001145808~,6
.jpg~20251001145825~,6
.jpg~20251001145831~,6
.jpg~20251001145833~,6
.jpg~20251001145835~,6
.jpg~20251001145844~,6
.jpg~20251001145845~,6
.jpg~20251001145848~,6
.jpg~20251001145854~,6
.jpg~20251001145857~,6
.jpg~20251001145858~,6
.jpg~20251001145900~,6
.jpg~20251001145901~,6
.jpg~20251001145902~,6
.jpg~20251001145913~,6
.jpg~20251001145917~,6
.jpg~20251001145924~,6
.jpg~20251001145926~,6
.jpg~20251001145928~,6
.jpg~20251001145929~,6
.jpg~20251001145931~,6
.jpg~20251001145933~,6
.jpg~20251001145934~,6
.jpg~20251001145937~,6
.jpg~20251001145940~,6
.jpg~20251001145942~,6
.jpg~20251001145943~,6
.jpg~20251001145948~,6
.jpg~20251001145950~,6
.jpg~20251001145957~,6
.jpg~20251001150005~,6
.pot,6
.sh,6
.jpg~20251001145704~,5
.jpg~20251001145723~,5
.jpg~20251001145729~,5
.jpg~20251001145811~,5
.jpg~20251001145812~,5
.jpg~20251001145814~,5
.jpg~20251001145821~,5
.jpg~20251001145829~,5
.jpg~20251001145837~,5
.jpg~20251001145838~,5
.jpg~20251001145935~,5
.jpg~20251001145955~,5
.jpg~20251001150004~,5
.jpg~20251001145444~,4
.jpg~20251001145446~,4
.jpg~20251001145503~,4
.jpg~20251001145506~,4
.jpg~20251001145514~,4
.jpg~20251001145518~,4
.jpg~20251001145535~,4
.jpg~20251001145540~,4
.jpg~20251001145601~,4
.jpg~20251001145603~,4
.jpg~20251001145605~,4
.jpg~20251001145607~,4
.jpg~20251001145651~,4
.jpg~20251001145652~,4
.jpg~20251001145655~,4
.jpg~20251001145657~,4
.jpg~20251001145727~,4
.jpg~20251001145728~,4
.jpg~20251001145809~,4
.jpg~20251001145815~,4
.jpg~20251001145822~,4
.jpg~20251001145919~,4
.jpg~20251001150007~,4
.md~20251001145605~,4
.md~20251001145606~,4
.md~20251001145607~,4
.csv,3
.dist,3
.jpg~20251001145414~,3
.jpg~20251001145422~,3
.jpg~20251001145433~,3
.jpg~20251001145434~,3
.jpg~20251001145436~,3
.jpg~20251001145437~,3
.jpg~20251001145439~,3
.jpg~20251001145440~,3
.jpg~20251001145441~,3
.jpg~20251001145442~,3
.jpg~20251001145443~,3
.jpg~20251001145447~,3
.jpg~20251001145448~,3
.jpg~20251001145449~,3
.jpg~20251001145450~,3
.jpg~20251001145455~,3
.jpg~20251001145456~,3
.jpg~20251001145457~,3
.jpg~20251001145458~,3
.jpg~20251001145459~,3
.jpg~20251001145500~,3
.jpg~20251001145501~,3
.jpg~20251001145502~,3
.jpg~20251001145504~,3
.jpg~20251001145505~,3
.jpg~20251001145507~,3
.jpg~20251001145508~,3
.jpg~20251001145509~,3
.jpg~20251001145510~,3
.jpg~20251001145511~,3
.jpg~20251001145512~,3
.jpg~20251001145513~,3
.jpg~20251001145521~,3
.jpg~20251001145528~,3
.jpg~20251001145533~,3
.jpg~20251001145534~,3
.jpg~20251001145536~,3
.jpg~20251001145537~,3
.jpg~20251001145541~,3
.jpg~20251001145543~,3
.jpg~20251001145544~,3
.jpg~20251001145545~,3
.jpg~20251001145546~,3
.jpg~20251001145548~,3
.jpg~20251001145549~,3
.jpg~20251001145550~,3
.jpg~20251001145552~,3
.jpg~20251001145556~,3
.jpg~20251001145559~,3
.jpg~20251001145600~,3
.jpg~20251001145602~,3
.jpg~20251001145604~,3
.jpg~20251001145606~,3
.jpg~20251001145611~,3
.jpg~20251001145613~,3
.jpg~20251001145618~,3
.jpg~20251001145620~,3
.jpg~20251001145623~,3
.jpg~20251001145624~,3
.jpg~20251001145629~,3
.jpg~20251001145649~,3
.jpg~20251001145650~,3
.jpg~20251001145654~,3
.jpg~20251001145656~,3
.jpg~20251001145711~,3
.jpg~20251001145813~,3
.jpg~20251001145823~,3
.jpg~20251001145915~,3
.jpg~20251001145920~,3
.md~20251001145608~,3
.md~20251001145609~,3
.md~20251001145612~,3
.md~20251001145633~,3
.php~20251001145557~,3
.png~20251001145358~,3
.png~20251001145359~,3
.png~20251001145403~,3
.png~20251001145404~,3
.png~20251001145406~,3
.png~20251001145524~,3
.png~20251001150004~,3
.jpg~20251001145412~,2
.jpg~20251001145416~,2
.jpg~20251001145418~,2
.jpg~20251001145428~,2
.jpg~20251001145429~,2
.jpg~20251001145432~,2
.jpg~20251001145435~,2
.jpg~20251001145445~,2
.jpg~20251001145452~,2
.jpg~20251001145519~,2
.jpg~20251001145529~,2
.jpg~20251001145538~,2
.jpg~20251001145539~,2
.jpg~20251001145542~,2
.jpg~20251001145547~,2
.jpg~20251001145551~,2
.jpg~20251001145554~,2
.jpg~20251001145555~,2
.jpg~20251001145557~,2
.jpg~20251001145558~,2
.jpg~20251001145608~,2
.jpg~20251001145610~,2
.jpg~20251001145612~,2
.jpg~20251001145614~,2
.jpg~20251001145617~,2
.jpg~20251001145619~,2
.jpg~20251001145621~,2
.jpg~20251001145622~,2
.jpg~20251001145625~,2
.jpg~20251001145626~,2
.jpg~20251001145628~,2
.jpg~20251001145653~,2
.jpg~20251001145810~,2
.jpg~20251001145819~,2
.jpg~20251001145921~,2
.jpg~20251001145922~,2
.md~20251001145604~,2
.md~20251001145614~,2
.md~20251001145619~,2
.md~20251001145630~,2
.neon,2
.png~20251001145352~,2
.png~20251001145354~,2
.png~20251001145355~,2
.png~20251001145356~,2
.png~20251001145357~,2
.png~20251001145400~,2
.png~20251001145401~,2
.png~20251001145402~,2
.png~20251001145405~,2
.png~20251001145408~,2
.png~20251001145409~,2
.png~20251001145525~,2
.yml,2
.bak,1
.cnf,1
.combine,1
.css~20251001145634~,1
.example,1
.jpg~20251001145415~,1
.jpg~20251001145417~,1
.jpg~20251001145419~,1
.jpg~20251001145421~,1
.jpg~20251001145423~,1
.jpg~20251001145426~,1
.jpg~20251001145427~,1
.jpg~20251001145431~,1
.jpg~20251001145438~,1
.jpg~20251001145451~,1
.jpg~20251001145453~,1
.jpg~20251001145454~,1
.jpg~20251001145515~,1
.jpg~20251001145517~,1
.jpg~20251001145520~,1
.jpg~20251001145522~,1
.jpg~20251001145523~,1
.jpg~20251001145527~,1
.jpg~20251001145553~,1
.jpg~20251001145609~,1
.jpg~20251001145616~,1
.jpg~20251001145712~,1
.jpg~20251001145816~,1
.jpg~20251001145818~,1
.json~20251001145558~,1
.lock,1
.lock~20251001145559~,1
.markdown,1
.md~20251001145558~,1
.md~20251001145615~,1
.md~20251001145618~,1
.md~20251001145622~,1
.md~20251001145624~,1
.md~20251001145625~,1
.md~20251001145628~,1
.md~20251001145631~,1
.md~20251001145632~,1
.otf,1
.php~20251001145559~,1
.pid,1
.png~20251001145353~,1
.png~20251001145407~,1
.png~20251001145523~,1
.png~20251001145526~,1
.rst,1
.scss,1
.sql,1
.xsl,1
.yml~20251001145559~,1
```
</details>


<details><summary><code>audits/_structure/raw_top100_files_by_size.csv</code></summary>

```
size_bytes,mtime_iso,ext,path
5195531,2023-04-14T14:14:21,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2015/06/IMG_5994.jpg
3056347,2023-04-14T14:14:22,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2015/09/20150708_115725-e1446218438917.jpg
2959967,2023-04-14T14:14:21,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2015/05/DSC_0605.jpg
2931055,2023-04-14T14:14:21,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2015/05/DSC_0961.jpg
2924272,2023-04-14T14:14:21,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2015/05/DSC_0022.jpg
2924272,2023-04-14T14:14:21,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2015/05/DSC_00221.jpg
2867452,2023-04-14T14:14:21,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2015/05/DSC_0024.jpg
2847688,2023-04-14T14:14:21,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2015/05/DSC_0957.jpg
2847688,2023-04-14T14:14:21,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2015/05/DSC_09571.jpg
2832747,2023-04-14T14:14:21,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2015/05/DSC_0613.jpg
2790843,2023-04-14T14:14:21,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2015/05/DSC_0604.jpg
2691796,2023-04-14T14:14:22,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2015/09/20150708_115725.jpg
2652502,2023-04-14T14:14:22,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2015/09/20150713_123029.jpg
2450275,2023-04-14T14:14:22,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2016/03/10.jpg
2450275,2025-10-01T14:55:54,.jpg~20251001145554~,mirror/raw/2025-10-01/wp-content/uploads/2016/03/10.jpg~20251001145554~
2398259,2023-04-14T14:14:22,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2016/03/18.jpg
2398259,2025-10-01T14:56:13,.jpg~20251001145612~,mirror/raw/2025-10-01/wp-content/uploads/2016/03/18.jpg~20251001145612~
2367847,2023-04-14T14:14:22,.png,mirror/raw/2025-10-01/wp-content/uploads/2015/09/06.png
2287249,2023-04-14T14:14:21,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2015/05/10.jpg
2281838,2023-04-14T14:14:21,.png,mirror/raw/2025-10-01/wp-content/uploads/2015/05/Screen-Shot-2015-09-01-at-11.20.45-AM.png
2281838,2023-04-14T14:14:21,.png,mirror/raw/2025-10-01/wp-content/uploads/2015/05/Screen-Shot-2015-09-01-at-11.20.45-AM1.png
2214696,2023-04-14T14:14:21,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2015/05/IMG_2162.jpg
2210157,2023-04-14T14:14:21,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2015/05/IMG_2157.jpg
2149744,2023-04-14T14:14:21,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2015/05/IMG_2234.jpg
2112801,2023-04-14T14:14:21,.png,mirror/raw/2025-10-01/wp-content/uploads/2015/06/Screen-Shot-2015-09-01-at-11.47.58-AM.png
2082922,2023-04-14T14:14:21,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2015/05/Photos-courtesy-of-Carlos-Guzman-KOKO-Design-Studios-2.jpg
2076327,2023-04-14T14:14:22,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2016/03/17.jpg
2076327,2025-10-01T14:56:08,.jpg~20251001145608~,mirror/raw/2025-10-01/wp-content/uploads/2016/03/17.jpg~20251001145608~
2064992,2023-04-14T14:14:21,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2015/05/IMG_2163.jpg
2061719,2023-04-14T14:14:22,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2016/03/11.jpg
2061719,2025-10-01T14:55:58,.jpg~20251001145557~,mirror/raw/2025-10-01/wp-content/uploads/2016/03/11.jpg~20251001145557~
2028490,2023-04-14T14:14:21,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2015/05/IMG_2233.jpg
1913558,2023-04-14T14:14:21,.png,mirror/raw/2025-10-01/wp-content/uploads/2015/05/Screen-Shot-2015-07-17-at-5.22.39-PM.png
1876775,2023-04-14T14:14:22,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2015/09/11.jpg
1866923,2023-04-14T14:14:21,.png,mirror/raw/2025-10-01/wp-content/uploads/2015/05/Screen-Shot-2015-09-01-at-11.59.49-AM.png
1852197,2023-04-14T14:14:21,.png,mirror/raw/2025-10-01/wp-content/uploads/2015/05/Screen-Shot-2015-09-01-at-11.57.28-AM.png
1841136,2023-04-14T14:14:22,.png,mirror/raw/2025-10-01/wp-content/uploads/2015/09/Screen-Shot-2015-09-01-at-11.41.16-AM.png
1841136,2025-10-01T14:53:54,.png~20251001145354~,mirror/raw/2025-10-01/wp-content/uploads/2015/09/Screen-Shot-2015-09-01-at-11.41.16-AM.png~20251001145354~
1815340,2023-04-14T14:14:21,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2015/05/IMG_2230.jpg
1780478,2023-04-14T14:14:21,.png,mirror/raw/2025-10-01/wp-content/uploads/2015/05/Screen-Shot-2015-08-21-at-5.51.57-PM.png
1720008,2023-04-14T14:14:21,.png,mirror/raw/2025-10-01/wp-content/uploads/2015/05/Screen-Shot-2015-09-01-at-11.38.50-AM.png
1694136,2023-04-14T14:14:21,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2015/05/IMG_2235.jpg
1679776,2023-04-14T14:14:21,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2015/07/bckg-image.jpg
1653037,2023-04-14T14:14:21,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2015/05/IMG_2123.jpg
1646505,2023-04-14T14:14:21,.png,mirror/raw/2025-10-01/wp-content/uploads/2015/05/Screen-Shot-2015-07-17-at-1.31.49-PM-1024x762.png
1626306,2023-04-14T14:14:21,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2015/05/IMG_2122.jpg
1625792,2023-04-14T14:14:21,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2015/05/IMG_2257.jpg
1620395,2023-04-14T14:14:21,.png,mirror/raw/2025-10-01/wp-content/uploads/2015/05/Screen-Shot-2015-09-01-at-11.58.18-AM.png
1610147,2023-04-14T14:14:21,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2015/05/IMG_2145.jpg
1582148,2023-04-14T14:14:21,.png,mirror/raw/2025-10-01/wp-content/uploads/2015/05/Screen-Shot-2015-09-01-at-12.04.25-PM.png
1561363,2023-04-14T14:14:21,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2015/05/IMG_2239.jpg
1559699,2023-04-14T14:14:21,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2015/05/IMG_2157-e1446221499248.jpg
1559101,2023-04-14T14:14:21,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2015/05/IMG_2162-e1446221478836.jpg
1551095,2023-04-14T14:14:21,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2015/05/IMG_2144.jpg
1549851,2023-04-14T14:14:21,.png,mirror/raw/2025-10-01/wp-content/uploads/2015/05/Screen-Shot-2015-09-01-at-11.43.06-AM.png
1547337,2023-04-14T14:14:21,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2015/05/IMG_2260.jpg
1539683,2023-04-14T14:14:22,.png,mirror/raw/2025-10-01/wp-content/uploads/2015/09/Screen-Shot-2015-09-01-at-11.25.42-AM.png
1520273,2023-04-14T14:14:21,.png,mirror/raw/2025-10-01/wp-content/uploads/2015/05/Screen-Shot-2015-09-01-at-11.16.11-AM.png
1520273,2023-04-14T14:14:21,.png,mirror/raw/2025-10-01/wp-content/uploads/2015/05/Screen-Shot-2015-09-01-at-11.16.11-AM1.png
1513106,2025-10-01T15:47:39,.csv,audits/_structure/2025-10-01_file_index.csv
1505879,2023-04-14T14:14:22,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2015/10/IMG_2212.jpg
1505879,2025-10-01T14:55:23,.jpg~20251001145523~,mirror/raw/2025-10-01/wp-content/uploads/2015/10/IMG_2212.jpg~20251001145523~
1497195,2023-04-14T14:14:21,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2015/05/IMG_2143.jpg
1453662,2023-04-14T14:14:21,.png,mirror/raw/2025-10-01/wp-content/uploads/2015/05/Screen-Shot-2015-09-01-at-12.03.47-PM.png
1448784,2023-04-14T14:14:22,.png,mirror/raw/2025-10-01/wp-content/uploads/2015/09/06-1024x572.png
1431006,2023-04-14T14:14:21,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2015/05/IMG_2233-e1446222277922.jpg
1421886,2023-04-14T14:14:21,.png,mirror/raw/2025-10-01/wp-content/uploads/2015/05/Screen-Shot-2015-09-01-at-11.58.18-AM-1024x795.png
1387375,2023-04-14T14:14:21,.png,mirror/raw/2025-10-01/wp-content/uploads/2015/05/Screen-Shot-2015-09-01-at-11.24.32-AM.png
1355902,2023-04-14T14:14:21,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2015/05/IMG_2237.jpg
1320108,2023-04-14T14:14:21,.png,mirror/raw/2025-10-01/wp-content/uploads/2015/05/Screen-Shot-2015-09-01-at-11.26.37-AM.png
1313311,2023-04-14T14:14:21,.png,mirror/raw/2025-10-01/wp-content/uploads/2015/05/Screen-Shot-2015-08-16-at-1.06.40-PM.png
1287918,2023-04-14T14:14:21,.png,mirror/raw/2025-10-01/wp-content/uploads/2015/05/Screen-Shot-2015-09-01-at-12.04.59-PM.png
1276882,2023-04-14T14:14:21,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2015/05/IMG_2230-e1446222218960.jpg
1269449,2023-04-14T14:14:21,.png,mirror/raw/2025-10-01/wp-content/uploads/2015/05/Screen-Shot-2015-09-01-at-11.20.45-AM-1024x543.png
1269449,2023-04-14T14:14:21,.png,mirror/raw/2025-10-01/wp-content/uploads/2015/05/Screen-Shot-2015-09-01-at-11.20.45-AM1-1024x543.png
1252606,2023-04-14T14:14:21,.png,mirror/raw/2025-10-01/wp-content/uploads/2015/05/Screen-Shot-2015-09-01-at-11.57.28-AM-1024x680.png
1232374,2023-04-14T14:14:21,.png,mirror/raw/2025-10-01/wp-content/uploads/2015/05/Screen-Shot-2015-09-01-at-11.08.34-AM.png
1200564,2023-04-14T14:14:22,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2016/05/02.jpg
1200564,2025-10-01T14:56:23,.jpg~20251001145622~,mirror/raw/2025-10-01/wp-content/uploads/2016/05/02.jpg~20251001145622~
1200337,2023-04-14T14:14:21,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2015/05/IMG_2123-e1446221875523.jpg
1185317,2023-04-14T14:14:21,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2015/05/IMG_2122-e1446221899655.jpg
1179045,2023-04-14T14:14:21,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2015/04/el-beso_Final_Welding.jpg
1172588,2023-04-14T14:14:22,.png,mirror/raw/2025-10-01/wp-content/uploads/2015/09/Screen-Shot-2015-09-01-at-12.01.16-PM.png
1169538,2023-04-14T14:14:21,.png,mirror/raw/2025-10-01/wp-content/uploads/2015/05/Screen-Shot-2015-09-01-at-11.24.32-AM-1024x679.png
1168929,2023-04-14T14:14:21,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2015/05/IMG_2145-e1446221808865.jpg
1168187,2023-04-14T14:14:22,.png,mirror/raw/2025-10-01/wp-content/uploads/2015/09/Screen-Shot-2015-09-01-at-11.46.19-AM.png
1168187,2025-10-01T14:53:57,.png~20251001145357~,mirror/raw/2025-10-01/wp-content/uploads/2015/09/Screen-Shot-2015-09-01-at-11.46.19-AM.png~20251001145357~
1166400,2023-04-14T14:14:21,.png,mirror/raw/2025-10-01/wp-content/uploads/2015/05/Screen-Shot-2015-07-17-at-1.31.49-PM.png
1161754,2023-04-14T14:14:21,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2015/05/IMG_2257-e1446220314963.jpg
1155130,2023-04-14T14:14:21,.png,mirror/raw/2025-10-01/wp-content/uploads/2015/05/Screen-Shot-2015-09-01-at-11.59.49-AM-1024x646.png
1143276,2025-10-01T15:47:38,.txt,audits/_structure/2025-10-01_project_tree.txt
1123831,2023-04-14T14:14:21,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2015/05/IMG_2144-e1446221829121.jpg
1118695,2023-04-14T14:14:21,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2015/05/IMG_2260-e1446220291514.jpg
1107032,2023-04-14T14:14:21,.png,mirror/raw/2025-10-01/wp-content/uploads/2015/05/Screen-Shot-2015-09-01-at-11.37.51-AM.png
1103393,2023-04-14T14:14:21,.png,mirror/raw/2025-10-01/wp-content/uploads/2015/05/Screen-Shot-2015-09-01-at-11.12.11-AM.png
1101240,2023-04-14T14:14:21,.png,mirror/raw/2025-10-01/wp-content/uploads/2015/05/Screen-Shot-2015-09-01-at-11.35.09-AM.png
1066883,2023-04-14T14:14:21,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2015/05/IMG_2143-e1446221852531.jpg
1065968,2023-04-14T14:14:21,.png,mirror/raw/2025-10-01/wp-content/uploads/2015/05/Screen-Shot-2015-08-16-at-1.05.19-PM.png
1051096,2023-04-14T14:14:22,.jpg,mirror/raw/2025-10-01/wp-content/uploads/2015/10/IMG_2212-e1446226112975.jpg
1051096,2025-10-01T14:55:22,.jpg~20251001145522~,mirror/raw/2025-10-01/wp-content/uploads/2015/10/IMG_2212-e1446226112975.jpg~20251001145522~
```
</details>


<details><summary><code>audits/_structure/raw_audits_file_list.txt</code></summary>

```
2025-10-01 15:56  audits/_structure/raw_top100_files_by_size.csv
2025-10-01 15:56  audits/_structure/raw_sizes_overview.txt
2025-10-01 15:56  audits/_structure/raw_sitemap.txt
2025-10-01 15:56  audits/_structure/raw_project_tree.txt
2025-10-01 15:56  audits/_structure/raw_no_meta_description.txt
2025-10-01 15:56  audits/_structure/raw_file_index.csv
2025-10-01 15:56  audits/_structure/raw_count_by_extension.csv
2025-10-01 15:56  audits/_structure/raw_audits_file_list.txt
2025-10-01 15:47  audits/_structure/2025-10-01_top100_files_by_size.csv
2025-10-01 15:47  audits/_structure/2025-10-01_source_overview.txt
2025-10-01 15:47  audits/_structure/2025-10-01_sizes_overview.txt
2025-10-01 15:47  audits/_structure/2025-10-01_sitemap.txt
2025-10-01 15:47  audits/_structure/2025-10-01_resumen_estructura.md
2025-10-01 15:47  audits/_structure/2025-10-01_project_tree.txt
2025-10-01 15:47  audits/_structure/2025-10-01_no_meta_description.txt
2025-10-01 15:47  audits/_structure/2025-10-01_mirror_overview.txt
2025-10-01 15:47  audits/_structure/2025-10-01_file_index.csv
2025-10-01 15:47  audits/_structure/2025-10-01_docs_overview.txt
2025-10-01 15:47  audits/_structure/2025-10-01_count_by_extension.csv
2025-10-01 15:47  audits/_structure/2025-10-01_audits_root_scripts.txt
2025-10-01 15:47  audits/_structure/2025-10-01_audits_overview.txt
2025-10-01 15:47  audits/_structure/2025-10-01_audits_file_list.txt
2025-10-01 15:23  audits/2025-10-01_auditoria_integral.md
2025-10-01 15:21  audits/inventory/2025-10-01_imagenes_pesadas.txt
2025-10-01 15:20  audits/inventory/2025-10-01_themes.txt
2025-10-01 15:20  audits/inventory/2025-10-01_plugins.txt
2025-10-01 15:19  audits/seo/2025-10-01_titulos.txt
2025-10-01 15:19  audits/seo/2025-10-01_sin_meta_description.txt
2025-10-01 15:19  audits/seo/2025-10-01_multiples_h1.txt
2025-10-01 15:16  audits/http_server_2025-10-01.pid
2025-10-01 14:56  audits/2025-10-01_fase2_snapshot.md
2025-10-01 14:53  audits/2025-10-01_sftp_wp-content.log
2025-10-01 14:31  audits/2025-10-01_db_dump.log
2025-10-01 14:04  audits/2025-10-01_mirror_sftp_final.md
2025-10-01 12:11  audits/2025-10-01_ssh_config_status.md
2025-10-01 11:36  audits/2025-10-01_wget_site.log
2025-10-01 11:28  audits/2025-10-01_sftp_check.log
2025-10-01 11:28  audits/2025-10-01_fase1_status.md
2025-10-01 11:28  audits/2025-10-01_db_check.log
2025-10-01 11:17  audits/checklist.md
2025-10-01 11:17  audits/README.md
```
</details>

