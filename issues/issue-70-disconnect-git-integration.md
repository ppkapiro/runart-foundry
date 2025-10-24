---
title: "Disconnect Pages Git Integration — enforce direct upload only"
labels: ["ops", "cloudflare-pages", "P1-critical"]
assignees: ["ppkapiro"]
---

## Context

**Investigation**: Forensics analysis revealed that `runart-foundry` Pages project has **Git Integration active**, causing dual-source deployments that override GitHub Action direct uploads.

**Evidence**:
- `cf_project_settings.json` shows `source.type: "github"` connected to `ppkapiro/runart-foundry`
- ALL recent prod deploys are `source: github` (Git Integration), NONE are `direct_upload` (Action)
- Build config in Pages: `npm run build` from `apps/briefing` → `site/`
- Build caching active: `build_caching: true`

**Impact**:
- GitHub Action `pages-deploy.yml` uploads artifacts but Git Integration overwrites them immediately
- Automated builds may use stale cache or fail silently
- Race conditions between Action and Git Integration cause inconsistencies
- No control over deploy timing or verification integration

## Root Cause

Git Integration executing automatic builds from repo on every push to `main`, **prevailing over GitHub Action's direct upload**.

Full analysis: [`docs/_meta/_deploy_forensics/WORKFLOW_AUDIT_DEPLOY.md`](../docs/_meta/_deploy_forensics/WORKFLOW_AUDIT_DEPLOY.md)

## Required Action (Manual)

**Location**: Cloudflare Dashboard → Pages → `runart-foundry` → Settings → Builds & deployments

**Steps**:
1. Navigate to [Cloudflare Dashboard - Pages runart-foundry](https://dash.cloudflare.com/?to=/:account/pages/view/runart-foundry/settings/builds-deployments)
2. Scroll to "**Production and preview branches**" section
3. Click **"Disconnect"** next to repo `ppkapiro/runart-foundry`
4. Confirm disconnection

**Expected Result**:
- `source.type` changes from `github` to `null` or `direct`
- Next deploys will be **only** via GitHub Action with `pages-action`
- API will show `source: direct_upload` or `upload` instead of `github`

## Validation

After disconnecting, trigger a deploy:
```bash
gh workflow run "Deploy to Cloudflare Pages (Briefing)"
```

Then verify:
1. Deploy workflow completes successfully
2. Fetch latest deploy via API:
   ```bash
   curl -sS "https://api.cloudflare.com/client/v4/accounts/$CF_ACCOUNT_ID/pages/projects/runart-foundry/deployments" \
     -H "Authorization: Bearer $CF_API_TOKEN" | jq '.result[0] | {id, source: .source.type, commit: .deployment_trigger.metadata.commit_hash}'
   ```
   Expected: `"source": "direct_upload"` or `"upload"`
3. Check `docs/_meta/BRIEFING_STATUS_PIPELINE_RUN.md`:
   ```
   - Deploy: <timestamp> | SHA: <commit> | source: direct_upload | dir: site
   ```

## Acceptance Criteria

- [ ] Git Integration disconnected (confirmed in Dashboard - screenshot preferred)
- [ ] First deploy post-disconnect shows `source: direct_upload` in API
- [ ] Subsequent deploys triggered by Action only (no automatic GitHub builds)
- [ ] Meta-log entry: `"Forensics OK — root cause: Git Integration — fix: disconnected — source: direct_upload"`

## Related Issues

- #69: Configure prod Access Service Tokens

## References

- Forensics investigation: `docs/_meta/_deploy_forensics/`
  - [`WORKFLOW_AUDIT_DEPLOY.md`](../docs/_meta/_deploy_forensics/WORKFLOW_AUDIT_DEPLOY.md)
  - [`REMediation.md`](../docs/_meta/_deploy_forensics/REMediation.md)
  - [`cf_project_settings.json`](../docs/_meta/_deploy_forensics/cf_project_settings.json)
  - [`cf_deploys.json`](../docs/_meta/_deploy_forensics/cf_deploys.json)

## Priority Justification

**P1-critical**: Dual-source deployments cause unpredictable content in production, breaking CI/CD pipeline integrity and verification.

## Assignee

@ppkapiro (owner with Cloudflare Dashboard access)
