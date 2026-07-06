#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
dist_dir="$repo_dir/dist"
archive="$dist_dir/tmux-windows-terminal-skill.tar.gz"

mkdir -p "$dist_dir"
rm -f "$archive"

tar -C "$repo_dir" -czf "$archive" \
  README.md \
  .gitignore \
  tmux-windows-terminal \
  scripts/package-skill.sh

echo "created=$archive"
