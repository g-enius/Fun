---
name: sync
description: Sync feature branches onto main — rebase, push, and resolve conflicts if needed
user_invocable: true
---

# /sync — Multi-Branch Sync

Rebase all feature branch worktrees onto main and force-push. If conflicts arise, resolve them intelligently.

## Steps

1. **Run the sync script**
   ```bash
   cd /Users/charleswang/Documents/Source/Fun-iOS && bash scripts/sync-branches.sh
   ```

2. **If the script succeeds (exit 0)**
   - Report which branches were synced
   - Done

3. **If the script fails (exit non-zero, conflicts)**
   - Parse the output to identify which branch(es) failed
   - For each failed branch:
     a. `cd` to the worktree directory
     b. Run `git rebase main` to restart the rebase
     c. When conflicts occur, read the conflicted files
     d. Resolve conflicts intelligently:
        - For CLAUDE.md / README.md / docs: keep both sides' content, merge logically
        - For code: understand both branches' intent, produce correct merged result
        - For generated files (Package.resolved, etc.): regenerate rather than merge
     e. `git add` resolved files, `git rebase --continue`
     f. Repeat until rebase completes
     g. `git push --force-with-lease origin <branch>`

4. **Report summary**
   - List all branches and their sync status
   - If any branch still failed after AI resolution, explain what went wrong

## Worktree Paths
| Branch | Path |
|--------|------|
| main | `/Users/charleswang/Documents/Source/Fun-iOS` |
| feature/navigation-stack | `/Users/charleswang/Documents/Source/Fun-iOS-NavigationStack` |
| feature/async-sequence | `/Users/charleswang/Documents/Source/Fun-iOS-NavigationStack-Async-Sequence` |

## Important
- Always push main first before rebasing feature branches
- Use `git rebase main` (not `origin/main`) — worktrees share the same `.git`, so local main is already current
- Use `--force-with-lease` (not `--force`) for safety
- Feature branches rebase in order: navigation-stack first, then async-sequence (since async-sequence may depend on navigation-stack changes)
