---
name: sync
description: Sync feature branches in PR-chain order — rebase, push, and resolve conflicts if needed
user_invocable: true
---

# /sync — Multi-Branch Sync

Rebase feature branches in PR-chain order and force-push. If conflicts arise, resolve them intelligently.

**Chain:** `main` → `navigation-stack` → `async-sequence`
- `navigation-stack` rebases onto `main`
- `async-sequence` rebases onto `navigation-stack` (matches PR #4 target)

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
     b. Run `git rebase <target>` to restart the rebase (main for navigation-stack, feature/navigation-stack for async-sequence)
     c. When conflicts occur, read the conflicted files
     d. Resolve conflicts intelligently:
        - For CLAUDE.md / README.md / docs: keep the current branch's version for branch-specific content, merge shared content
        - For code: understand both branches' intent, produce correct merged result
        - For generated files (Package.resolved, etc.): regenerate rather than merge
     e. `git add` resolved files, `git rebase --continue`
     f. Repeat until rebase completes
     g. `git push --force-with-lease origin <branch>`

4. **Report summary**
   - List all branches and their sync status
   - If any branch still failed after AI resolution, explain what went wrong

## Worktree Paths
| Branch | Rebase onto | Path |
|--------|-------------|------|
| main | — | `/Users/charleswang/Documents/Source/Fun-iOS` |
| feature/navigation-stack | main | `/Users/charleswang/Documents/Source/Fun-iOS-NavigationStack` |
| feature/async-sequence | feature/navigation-stack | `/Users/charleswang/Documents/Source/Fun-iOS-NavigationStack-Async-Sequence` |

## Important
- Always push main first before rebasing feature branches
- Rebase order matters: navigation-stack first (onto main), then async-sequence (onto navigation-stack)
- Use local branch refs (not `origin/`) — worktrees share the same `.git`, so local refs are already current
- Use `--force-with-lease` (not `--force`) for safety
