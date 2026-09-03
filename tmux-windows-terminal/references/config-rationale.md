# Full Config Rationale

## Overview

This reference explains the intent behind the full template in `assets/tmux.conf.full`.

## Terminal Core

### `default-terminal`

Use:

```tmux
set -g default-terminal "tmux-256color"
```

Reason:

- `tmux-256color` is more capable than `screen-256color`.
- Use it only when the terminfo entry exists on the target system.

### `terminal-overrides`

List every outer terminal that actually appears in the user's chain. For a Ghostty-on-macOS chain that also reaches Windows Terminal, list both:

```tmux
set -g terminal-overrides "xterm-ghostty:Tc:RGB,xterm-256color:Tc:RGB,tmux-256color:Tc:RGB,tmux:Tc:RGB"
set -ag terminal-overrides ",xterm-ghostty:Ms=\\E]52;c;%p2%s\\007,xterm-256color:Ms=\\E]52;c;%p2%s\\007,tmux-256color:Ms=\\E]52;c;%p2%s\\007,tmux:Ms=\\E]52;c;%p2%s\\007"
```

Reason:

- `Tc` and `RGB` cover truecolor capability reporting.
- `Ms` enables OSC 52 clipboard output.
- Narrow matching avoids falsely claiming capability support for unrelated terminals.
- `xterm-ghostty` is required when the outer terminal is Ghostty. Omitting it leaves that chain without `RGB`, truecolor, or OSC 52.

### `terminal-features`

Use:

```tmux
set -g terminal-features "xterm-ghostty:RGB:mouse:extkeys:clipboard,xterm-256color:RGB:mouse:extkeys:clipboard,tmux-256color:RGB:mouse:extkeys:clipboard,tmux:RGB:mouse:extkeys:clipboard"
```

Reason:

- This is the modern high-level declaration for capability classes.
- It is cleaner than stacking many old-style override fragments.
- The terminal name list must match `terminal-overrides`. A terminal missing here silently loses `extkeys` and `clipboard` even when `Ms` is set.

### `extended-keys` and `extended-keys-format`

Use:

```tmux
set -s extended-keys on
set -g extended-keys-format csi-u
```

Reason:

- Without extended keys, tmux collapses `Shift+Enter`, `Ctrl+Enter`, and `Alt+Enter` into plain `\r`, so applications cannot distinguish them.
- `csi-u` forwards modified keys as `\x1b[13;2u` instead of the xterm `modifyOtherKeys` form `\x1b[27;5;13~`. It is the more reliable encoding.
- `extended-keys-format` requires tmux 3.5 or later. Omit the line on tmux 3.2 through 3.4, where the default xterm format still works.
- `extended-keys on` selects the encoding. `extkeys` in `terminal-features` declares that the outer terminal supports it. Both are required.

See `references/extended-keys.md` for the full key-sequence tables and version fallback.

### `focus-events`

Use:

```tmux
set -g focus-events on
```

Reason:

- Modern terminals such as Ghostty, Kitty, iTerm2, WezTerm, and Windows Terminal handle focus notifications correctly, and applications rely on them for focus-dependent rendering.
- Turn it `off` only when Windows Terminal, WSL, ConPTY, or SSH-latency paths visibly leak focus or device-attribute responses into the pane as raw text such as `61;...c`.

### `allow-passthrough`

Use:

```tmux
set -g allow-passthrough all
```

Reason:

- `all` is the safest default when nested clipboard and passthrough behavior must survive remote or non-visible-pane scenarios.

### `set-clipboard`

Use:

```tmux
set -s set-clipboard on
```

Reason:

- Remote tmux should emit clipboard content outward to the host terminal instead of only accepting application-originated clipboard updates.
- `on` covers both directions: tmux accepts application-initiated clipboard writes and emits OSC 52 to the host terminal.
- Older guides use `external`, which only emits outward. `on` is the value to prefer unless an application misbehaves by writing the clipboard on focus or selection.

## Copying and Selection

### vi copy mode

Use explicit bindings for selection and copy so the copy path is obvious.

### Mouse fallback

Keep a toggle such as:

```tmux
bind-key -n F12 if-shell -F '#{mouse}' \
  'set -g mouse off; display-message "tmux mouse: off (use terminal selection / Shift-drag)"' \
  'set -g mouse on; display-message "tmux mouse: on"'
```

Reason:

- The fallback is practical in Windows Terminal even when tmux mouse itself is working.

## Full Config Sections To Keep

When building a complete `~/.tmux.conf`, do not stop at terminal lines. Keep these sections coherent:

- prefix and basic indexing;
- history and `escape-time`;
- status bar;
- pane borders;
- window list formatting;
- activity and resize behavior;
- copy mode;
- navigation bindings;
- popup terminal;
- zoom binding.

## Warning About Runtime Drift

If the user has been iterating with `tmux source-file`, runtime state may still contain stale appended `terminal-overrides` or `terminal-features`. Fix the file, then restart the tmux server.
