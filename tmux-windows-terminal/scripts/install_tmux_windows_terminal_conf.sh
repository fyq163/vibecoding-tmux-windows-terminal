#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
skill_dir="$(cd "$script_dir/.." && pwd)"
source_conf="$skill_dir/assets/tmux.conf.full"
target_conf="${1:-$HOME/.tmux.conf}"
backup_suffix="$(date +%Y%m%d%H%M%S)"

if [ ! -f "$source_conf" ]; then
  echo "template not found: $source_conf" >&2
  exit 1
fi

mkdir -p "$(dirname "$target_conf")"

if [ -f "$target_conf" ]; then
  backup_path="${target_conf}.bak.${backup_suffix}"
  cp "$target_conf" "$backup_path"
  echo "backup=$backup_path"
fi

cp "$source_conf" "$target_conf"
echo "installed=$target_conf"
echo "next=tmux source-file \"$target_conf\" && tmux kill-server && tmux"
