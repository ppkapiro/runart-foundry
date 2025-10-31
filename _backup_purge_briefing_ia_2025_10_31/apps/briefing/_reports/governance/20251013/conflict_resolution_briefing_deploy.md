# Conflict Resolution: briefing_deploy.yml
**Date**: 2025-10-13T21:09:19Z  
**Issue**: Merge conflict between chore/bootstrap-git and main  
**Resolution**: Keep default branch version (more complete with legacy protection)

## Conflict Analysis

### Default Branch Version (chore/bootstrap-git)
```yaml
name: Briefing Deploy (LEGACY)

on:
  workflow_dispatch:
    inputs:
      confirm_legacy:
        description: "Confirmo que entiendo que este workflow usa rutas legacy briefing/ y NO apps/briefing/"
        required: true
        default: "no"
```

### Main Branch Version  
```yaml
name: Briefing — Deploy to Cloudflare Pages

on:
  push:
    branches: [ "main" ]
```

## Resolution Decision

**KEEP**: Default branch version (chore/bootstrap-git)  
**RATIONALE**: 
- Includes workflow_dispatch capability for manual execution
- Has legacy protection mechanism (confirm_legacy input)  
- More comprehensive trigger configuration
- Aligns with governance requirement for manual deployment control

## Implementation

The default branch version will be preserved during the sync merge to main. This ensures:
1. ✅ Manual execution capability maintained
2. ✅ Legacy path protection active  
3. ✅ Governance compliance (controlled deployments)
4. ✅ Backward compatibility preserved

## Post-Merge Status

After sync completion, main branch will have:
- `name: Briefing Deploy (LEGACY)`
- `workflow_dispatch` trigger with confirmation
- Legacy path protection mechanism
- Complete trigger matrix (push, PR, manual)

**Status**: ✅ RESOLVED - Keep default branch version