# CLAUDE.md

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## Repo layout

```
.chezmoiroot          # points chezmoi source to home/
home/                 # files managed in $HOME
  .chezmoi.yaml.tmpl  # main chezmoi config (interactive prompts)
  .chezmoidata/       # layered YAML data (packages.yaml, theme.yaml)
  .chezmoiignore      # conditional file exclusion via templates
  .chezmoiremove      # files to remove on apply
  .chezmoiscripts/    # chezmoi run scripts (homebrew install, macOS defaults)
  private_dot_config/ # ~/.config/* (17 app configs)
  private_dot_ssh/    # ~/.ssh/*
  dot_zshenv.tmpl     # shell environment bootstrap
install/              # platform and ownership-aware install helpers
bootstrap.sh          # one-shot setup: installs chezmoi, creates AGE key, runs apply
```

## Chezmoi file naming

| Prefix/suffix    | Meaning                                    |
|------------------|--------------------------------------------|
| `dot_`           | Maps to `.` (e.g., `dot_zshenv` -> `.zshenv`) |
| `private_`       | Sets restrictive file permissions          |
| `empty_`         | Ensures file exists (even if empty)        |
| `encrypted_`     | AGE-encrypted file                         |
| `.tmpl`          | Chezmoi Go template                        |
| `.age`           | AGE-encrypted (alternative to `encrypted_` prefix) |

## Targeting model

Templates prompt on first apply for a four-tier targeting model:

- **ownership**: `personal`, `work_flex`, `work_strict`
- **profile**: `portable`, `rig`, `server`
- **capacities**: `gaming`, `development`, `media`
- **programs**: per-category defaults for shell, editor, terminal, browser, password manager

Template variables (e.g., `.is_work_owned`, `.profile`, `.capacities`) gate conditional includes and file exclusion via `.chezmoiignore`.

## Encryption

Secrets are AGE-encrypted (`*.age` files) using `rage`. Identity lives at `~/.config/chezmoi/key.txt`. The `bootstrap.sh` script creates this key if missing.

## Data-driven package management

Homebrew packages are defined in `home/.chezmoidata/packages.yaml` under `packages.brew`, applied in layer order: `base` -> `ownership` -> `profiles` -> `capacities` -> program selectors (`password_managers`, `terminals`, `editors`, `shells`, `toolchains`, `browsers`).

Theme data lives in `home/.chezmoidata/theme.yaml` (Tokyo Night family).

## Managed configs

Under `home/private_dot_config/`:

bat, emacs, ghostty, git, iterm2, kitty, lazygit, mise, npm, nushell, nvim, task, tldr, yazi, zellij, zsh, zsh-abbr

## Common commands

```sh
chezmoi diff       # preview changes
chezmoi apply      # apply changes to $HOME
chezmoi status     # show what would change
chezmoi re-add     # update source from modified target files
```

## Commit conventions

Conventional-commit style: `type(scope): message`

Types: `feat`, `fix`, `tweak`, `refactor`
Scopes: app name or `dotfiles` for cross-cutting changes.
No `Co-Authored-By` trailers.

## Gotchas

- `.chezmoiroot` sets `home/` as the chezmoi source root — files outside `home/` (like this CLAUDE.md) are repo-only and never applied to `$HOME`.
- `.gitignore` excludes unencrypted work files (plaintext git/ssh work configs, work install scripts).
- `.chezmoiignore` conditionally excludes files based on template variables (e.g., work configs excluded on personal machines).
- Encrypted files require the AGE identity to edit; use `chezmoi edit <path>` to decrypt-edit-re-encrypt in place.
