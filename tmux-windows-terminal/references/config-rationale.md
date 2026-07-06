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

Use explicit terminal names:

```tmux
set -g terminal-overrides "xterm-256color:Tc:RGB,tmux-256color:Tc:RGB,tmux:Tc:RGB"
set -ag terminal-overrides ",xterm-256color:Ms=\\E]52;c;%p2%s\\007,tmux-256color:Ms=\\E]52;c;%p2%s\\007,tmux:Ms=\\E]52;c;%p2%s\\007"
```

Reason:

- `Tc` and `RGB` cover truecolor capability reporting.
- `Ms` enables OSC 52 clipboard output.
- Narrow matching avoids falsely claiming capability support for unrelated terminals.

### `terminal-features`

Use:

```tmux
set -g terminal-features "xterm-256color:RGB:mouse:extkeys:clipboard,tmux-256color:RGB:mouse:extkeys:clipboard,tmux:RGB:mouse:extkeys:clipboard"
```

Reason:

- This is the modern high-level declaration for capability classes.
- It is cleaner than stacking many old-style override fragments.

### `focus-events`

Use:

```tmux
set -g focus-events off
```

Reason:

- In Windows Terminal, WSL, ConPTY, or SSH-latency paths, focus-related terminal responses can leak into the pane as raw text.

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
set -s set-clipboard external
```

Reason:

- Remote tmux should emit clipboard content outward to the host terminal instead of only accepting application-originated clipboard updates.

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
