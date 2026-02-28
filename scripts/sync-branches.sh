#!/bin/bash
set -euo pipefail

# Sync feature branches onto main after pushing main.
# Run from the main worktree (Fun-iOS/).
# On conflict: aborts rebase, restores state, exits non-zero.

MAIN_WORKTREE="$(cd "$(dirname "$0")/.." && pwd)"
FEATURE_WORKTREES=(
  "/Users/charleswang/Documents/Source/Fun-iOS-NavigationStack"
  "/Users/charleswang/Documents/Source/Fun-iOS-NavigationStack-Async-Sequence"
)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

info()  { echo -e "${GREEN}[sync]${NC} $1"; }
warn()  { echo -e "${YELLOW}[sync]${NC} $1"; }
error() { echo -e "${RED}[sync]${NC} $1"; }

# --- Preflight: must be on main, must be clean or pushable ---

cd "$MAIN_WORKTREE"

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ "$CURRENT_BRANCH" != "main" ]]; then
  error "Not on main (on $CURRENT_BRANCH). Run from Fun-iOS/ worktree."
  exit 1
fi

if ! git diff --quiet || ! git diff --cached --quiet; then
  error "Main worktree has uncommitted changes. Commit or stash first."
  exit 1
fi

# Push main if ahead of origin
if git log origin/main..main --oneline | grep -q .; then
  info "Pushing main to origin..."
  git push origin main
else
  info "Main is up to date with origin."
fi

# --- Rebase each feature branch ---

FAILED_BRANCHES=()
SYNCED_BRANCHES=()

for WORKTREE in "${FEATURE_WORKTREES[@]}"; do
  if [[ ! -d "$WORKTREE" ]]; then
    warn "Worktree not found: $WORKTREE — skipping"
    continue
  fi

  cd "$WORKTREE"
  BRANCH=$(git rev-parse --abbrev-ref HEAD)
  info "Syncing $BRANCH ($WORKTREE)..."

  # Auto-stash if dirty
  STASHED=false
  if ! git diff --quiet || ! git diff --cached --quiet; then
    warn "  Stashing dirty changes..."
    git stash push -m "sync-branches auto-stash"
    STASHED=true
  fi

  # Rebase onto main (shared .git means local main ref is current)
  if git rebase main; then
    info "  Rebase successful. Force-pushing..."
    git push --force-with-lease origin "$BRANCH"
    SYNCED_BRANCHES+=("$BRANCH")
  else
    error "  Rebase conflict on $BRANCH!"
    git rebase --abort
    FAILED_BRANCHES+=("$BRANCH")
  fi

  # Restore stash
  if [[ "$STASHED" == true ]]; then
    warn "  Restoring stashed changes..."
    git stash pop || warn "  Stash pop had conflicts — check manually."
  fi
done

# --- Summary ---

cd "$MAIN_WORKTREE"
echo ""

if [[ ${#SYNCED_BRANCHES[@]} -gt 0 ]]; then
  info "Synced: ${SYNCED_BRANCHES[*]}"
fi

if [[ ${#FAILED_BRANCHES[@]} -gt 0 ]]; then
  error "Failed (conflicts): ${FAILED_BRANCHES[*]}"
  error "Run /sync in Claude Code for AI-assisted conflict resolution."
  exit 1
fi

info "All branches synced."
