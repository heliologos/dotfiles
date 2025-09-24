fish_vi_key_bindings

source ~/.config/fish/conf.d/env.fish
source ~/.config/fish/conf.d/paths.fish
source ~/.config/fish/conf.d/aliases.fish

set -g fish_greeting

{{ if lookPath "zoxide" -}}
zoxide init fish | source
{{ end }}
