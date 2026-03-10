#!/usr/bin/env bash
set -euo pipefail

SKILL_NAME="github-problem-finder"
DEST=".codex/skills/${SKILL_NAME}"

REPO_URL="${1:-}"
if [[ -z "$REPO_URL" ]]; then
  echo "Usage: ./scripts/install.sh <git-repo-url>"
  exit 1
fi

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p ".codex/skills"

echo "Cloning skill from: $REPO_URL"
git clone --depth 1 "$REPO_URL" "$tmp_dir" >/dev/null

rm -rf "$DEST"
mkdir -p "$DEST"

cp "$tmp_dir/skill.md" "$DEST/skill.md"
[[ -d "$tmp_dir/references" ]] && cp -R "$tmp_dir/references" "$DEST/references"
[[ -d "$tmp_dir/examples"   ]] && cp -R "$tmp_dir/examples"   "$DEST/examples"

echo "Installed skill at: $DEST/skill.md"
