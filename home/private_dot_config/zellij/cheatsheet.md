# Zellij Cheat Sheet

This setup is lock-first for app-friendly keybinds (LazyVim, shells, etc).

Modes and help
- `Ctrl-g`: toggle locked/normal
- `Alt-/`: open this cheat sheet (floating)
- `Alt-w`: pane mode
- `Alt-t`: tab mode
- `Alt-r`: resize mode
- `Alt-m`: move mode
- `Alt-e`: scroll mode
- `Alt-s`: session mode
- `Esc` or `Enter`: return to normal mode

Start here (new-user defaults)
- `Alt-/`: open this page whenever you forget keys
- `Alt-g`: make a quick 70/30 split (main pane left)
- `Alt-Shift-g`: quick double split (main left + two right panes)

Locked mode quick controls
- `Alt-1..9`: go to tab 1-9
- `Alt-n`: new tab
- `Alt-p`: previous tab
- `Alt-]`: next tab
- `Alt-x`: close current tab

Shared controls (all unlocked modes)
- `Alt-h/j/k/l`: move focus (left/down/up/right)
- `Alt-Left/Down/Up/Right`: same as above
- `Alt-g`: quick 70/30 split (main pane left)
- `Alt-Shift-g`: quick double split (main left + two right panes)
- `Alt-n`: new pane
- `Alt-Shift-x`: close focused pane
- `Alt-i` / `Alt-o`: move tab left/right
- `Alt-f`: toggle floating panes
- `Alt-=` or `Alt-+`: increase size
- `Alt--`: decrease size
- `Alt-[` / `Alt-]`: previous/next swap layout
- `Alt-p`: toggle pane group
- `Alt-Shift-p`: toggle group marking

Pane mode (`Alt-w`)
- `h/j/k/l` or arrows: move focus
- `n`: new pane
- `d`: split down
- `r`: split right
- `s`: split stacked
- `x`: close focused pane
- `f`: toggle fullscreen
- `w`: toggle floating panes
- `e`: embed/floating for focused pane
- `z`: toggle pane frames
- `i`: toggle pin
- `c`: rename pane

Tab mode (`Alt-t`)
- `h/j/k/l` or arrows: previous/next tab
- `1..9`: jump to tab
- `n`: new tab
- `x`: close tab
- `r`: rename tab
- `s`: toggle sync tab
- `b`: break pane
- `[` / `]`: break pane left/right

Resize mode (`Alt-r`)
- `h/j/k/l` or arrows: increase toward direction
- `H/J/K/L`: decrease toward direction
- `+`, `=`, `-`: increase/increase/decrease

Move mode (`Alt-m`)
- `h/j/k/l` or arrows: move pane
- `n` or `Tab`: rotate pane forward
- `p`: rotate pane backward

Scroll and search
- `Alt-e`: enter/exit scroll mode
- `j/k`: scroll down/up
- `h/l` or `PageUp/PageDown`: page scroll
- `d/u`: half-page down/up
- `Ctrl-f` / `Ctrl-b`: page down/up
- `s` (in scroll mode): enter search prompt
- `n/p` (in search mode): next/previous match
- `c`, `o`, `w` (in search mode): case/word/wrap toggles

Tmux compatibility mode
- `Ctrl-b`: enter tmux mode
- `"`: split down
- `%`: split right
- `c`: new tab
- `,`: rename tab
- `[`: scroll mode
- `x`: close pane

Session mode (`Alt-s`)
- `w`: session manager
- `c`: configuration plugin
- `p`: plugin manager
- `a`: about
- `s`: share
- `d`: detach
