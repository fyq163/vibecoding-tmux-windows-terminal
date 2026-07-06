# Tmux Windows Terminal Troubleshooting

## Scope

Use this reference for:

- mouse coordinate leakage such as `61;4;...c` or other raw control-sequence fragments;
- copy or paste failures in Windows Terminal, WSL, SSH, and nested tmux;
- `DCS passthrough is disabled` style errors;
- requests to preserve a full-featured `~/.tmux.conf` instead of only fixing one line.

## Primary Symptoms

### Mouse movement leaks garbage into the shell

Common signs:

- shell input fills with fragments like `61;4;...c`;
- moving the mouse makes the pane unusable;
- the issue appears only in Windows Terminal, WSL, ConPTY, or SSH paths.

Primary fixes:

1. Set `set -g focus-events off`.
2. Keep `terminal-features` narrow and explicit for the actual outer terminal type.
3. Avoid piling up repeated `set -ga terminal-overrides` and `set -ga terminal-features` across reloads.
4. Restart the tmux server after capability changes.

Why:

- The leaked text is often not literal mouse coordinates. It is commonly a delayed terminal response mixed with mouse reporting and left unread by tmux in an unstable path.

### Clipboard does not reach the local machine

Common signs:

- copy mode appears to work but nothing reaches the local clipboard;
- nested clipboard checks complain about passthrough;
- behavior differs between local macOS terminals and Windows Terminal over SSH.

Primary fixes:

1. Set `set -g allow-passthrough all`.
2. Set `set -s set-clipboard external`.
3. Ensure `Ms` exists for the active terminal type via `terminal-overrides`.
4. Verify that the host terminal supports OSC 52.

Why:

- Remote tmux needs to emit clipboard data outward rather than only maintaining internal tmux buffers.

### Copying text is inconvenient even after tmux is stable

Common fixes:

1. Keep tmux mouse on for pane selection and scrolling.
2. Add a binding to toggle `mouse off` temporarily for native terminal selection.
3. Keep vi copy mode bindings explicit.

Suggested fallback:

- `F12` toggles `mouse on/off`.
- `Shift + drag` stays available for Windows Terminal native selection.

### Repeated reloads make behavior inconsistent

Common signs:

- `show -g terminal-overrides` contains duplicates;
- the file looks correct but runtime values still show stale broad entries.

Primary fixes:

1. Replace append-only declarations with deterministic base assignments:
   - `set -g terminal-overrides "..."`
   - `set -g terminal-features "..."`
2. Use append mode only for an intentional second phase.
3. Restart the tmux server.

## Runtime Inspection

Run:

```bash
~/.codex/skills/tmux-windows-terminal/scripts/collect_tmux_diagnostics.sh
```

Inspect:

- `tmux -V`
- `TERM`
- `infocmp tmux-256color`
- `tmux show -s`
- `tmux show -g`
- `terminal-features`
- `terminal-overrides`

Pay attention to:

- `default-terminal`
- `focus-events`
- `set-clipboard`
- `allow-passthrough`
- `mouse`
- duplicate terminal declarations

## Validation Sequence

1. `tmux source-file ~/.tmux.conf`
2. `tmux show -s`
3. `tmux show -g`
4. `tmux kill-server && tmux`
5. Re-test:
   - mouse movement;
   - copy mode;
   - local clipboard;
   - native terminal selection fallback.

## Full Config Path

When the user asks for a complete known-good config rather than a patch, use `assets/tmux.conf.full` and keep these principles:

- terminal behavior first;
- copy mode and clipboard explicit;
- fallback path for native selection;
- non-terminal UX sections kept coherent: status, pane borders, navigation, popup, zoom.
