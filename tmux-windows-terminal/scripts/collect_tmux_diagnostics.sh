#!/usr/bin/env bash
set -euo pipefail

conf_path="${1:-$HOME/.tmux.conf}"

print_section() {
  printf '\n== %s ==\n' "$1"
}

print_section "Environment"
printf 'date=%s\n' "$(date -Is)"
printf 'shell=%s\n' "${SHELL:-}"
printf 'TERM=%s\n' "${TERM:-}"
printf 'TMUX=%s\n' "${TMUX:-}"
printf 'SSH_CONNECTION=%s\n' "${SSH_CONNECTION:-}"

print_section "tmux"
tmux -V || true

print_section "terminfo"
if infocmp tmux-256color >/dev/null 2>&1; then
  echo "tmux-256color: present"
else
  echo "tmux-256color: missing"
fi
if infocmp xterm-256color >/dev/null 2>&1; then
  echo "xterm-256color: present"
else
  echo "xterm-256color: missing"
fi

print_section "server options"
tmux show -s 2>/dev/null || echo "tmux server options unavailable"

print_section "global options"
tmux show -g 2>/dev/null || echo "tmux global options unavailable"

print_section "runtime focus"
tmux show -sv default-terminal 2>/dev/null || true
tmux show -sv set-clipboard 2>/dev/null || true
tmux show -gv allow-passthrough 2>/dev/null || true
tmux show -gv focus-events 2>/dev/null || true
tmux show -gv mouse 2>/dev/null || true

print_section "terminal-features"
tmux show -g terminal-features 2>/dev/null || true

print_section "terminal-overrides"
tmux show -g terminal-overrides 2>/dev/null || true

print_section "config file"
printf 'path=%s\n' "$conf_path"
if [ -f "$conf_path" ]; then
  nl -ba "$conf_path"
else
  echo "config file not found"
fi
