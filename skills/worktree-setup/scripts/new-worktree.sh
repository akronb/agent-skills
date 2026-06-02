#!/usr/bin/env bash
# Create a git worktree for a branch, copy gitignored env files from the main
# checkout into it, and install dependencies. Works from any worktree of the repo.
#
# Usage: new-worktree.sh <branch> [base-ref] [--no-install]
#   <branch>    branch to check out (created from base-ref if it doesn't exist)
#   [base-ref]  start point for a new branch (default: HEAD)
#   --no-install  skip dependency install
set -euo pipefail

BRANCH=""
BASE_REF="HEAD"
DO_INSTALL=1
for arg in "$@"; do
  case "$arg" in
    --no-install) DO_INSTALL=0 ;;
    -*) echo "unknown flag: $arg" >&2; exit 2 ;;
    *) if [ -z "$BRANCH" ]; then BRANCH="$arg"; else BASE_REF="$arg"; fi ;;
  esac
done
[ -n "$BRANCH" ] || { echo "usage: new-worktree.sh <branch> [base-ref] [--no-install]" >&2; exit 2; }

# Resolve the main checkout root from wherever we are (root or a linked worktree).
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" && pwd -P)
MAIN_ROOT=$(dirname "$GIT_COMMON")

# Choose where worktrees live: project-local .worktrees if it's gitignored,
# else a per-repo global dir so we never pollute a tracked path.
if git -C "$MAIN_ROOT" check-ignore -q .worktrees; then
  BASE="$MAIN_ROOT/.worktrees"
else
  BASE="$HOME/.worktrees/$(basename "$MAIN_ROOT")"
  echo "note: .worktrees is not gitignored in this repo; using $BASE" >&2
fi
SLUG="${BRANCH//\//-}"
WT="$BASE/$SLUG"
mkdir -p "$BASE"

if [ -e "$WT" ]; then
  echo "error: $WT already exists" >&2; exit 1
fi

# Attach existing branch, or create a new one from base-ref.
if git -C "$MAIN_ROOT" show-ref --verify --quiet "refs/heads/$BRANCH"; then
  echo "→ adding worktree for existing branch '$BRANCH'"
  git -C "$MAIN_ROOT" worktree add "$WT" "$BRANCH"
else
  echo "→ creating branch '$BRANCH' from '$BASE_REF'"
  git -C "$MAIN_ROOT" worktree add -b "$BRANCH" "$WT" "$BASE_REF"
fi

# Copy gitignored env files from the main root. .env.example is tracked, so it
# is already present in the worktree — skip it to avoid clobbering.
echo "→ copying env files"
copied=0
shopt -s nullglob dotglob
for f in "$MAIN_ROOT"/.env*; do
  base=$(basename "$f")
  [ "$base" = ".env.example" ] && continue
  if [ -f "$f" ]; then cp "$f" "$WT/$base"; echo "  + $base"; copied=$((copied+1)); fi
done
shopt -u nullglob dotglob
[ "$copied" -eq 0 ] && echo "  (no env files found in $MAIN_ROOT)"

# Install dependencies with the detected package manager.
if [ "$DO_INSTALL" -eq 1 ]; then
  echo "→ installing dependencies"
  cd "$WT"
  if [ -f pnpm-lock.yaml ]; then pnpm install
  elif [ -f yarn.lock ]; then yarn install
  elif [ -f bun.lockb ]; then bun install
  elif [ -f package-lock.json ] || [ -f package.json ]; then npm install
  elif [ -f Cargo.toml ]; then cargo build
  elif [ -f go.mod ]; then go mod download
  elif [ -f uv.lock ]; then uv sync
  elif [ -f requirements.txt ]; then pip install -r requirements.txt
  else echo "  (no recognized manifest; skipping install)"; fi
else
  echo "→ skipping install (--no-install)"
fi

echo
echo "✓ worktree ready: $WT"
echo "  cd $WT"
