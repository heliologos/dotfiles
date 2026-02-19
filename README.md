# dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## Quick start

Run bootstrap from this repo:

```sh
./bootstrap.sh
```

What it does:
- installs `chezmoi` if missing
- initializes this repo as your chezmoi source
- ensures an AGE identity exists at `~/.config/chezmoi/key.txt`
- runs `chezmoi apply`

## Targeting model

On first apply, templates prompt for:
- `ownership`: `personal`, `work_flex`, or `work_strict`
- `profile`: `portable`, `rig`, or `server`
- `capacities`: `gaming`, `development`, and/or `media`
- work identity values (`name`, `email`) when ownership is work-owned
- defaults for shell/editor/terminal/browser/password manager

You can preseed work identity via env vars:

```sh
WORK_NAME="Your Name" WORK_EMAIL="you@company.com" chezmoi apply
```

## Common commands

```sh
chezmoi diff
chezmoi apply
chezmoi status
chezmoi re-add
```

## Repo layout

- `home/`: files managed in `$HOME`
- `install/`: platform and ownership-aware install helpers
- `bootstrap.sh`: one-shot setup script

## Notes

- Secrets are stored as age-encrypted files (`*.age`) in source.
- Work-sensitive package data can live in `install/macos/work/packages.work.yaml.age`
  and is merged into package templates only for work-owned systems.
- Homebrew package selection uses layered data in `home/.chezmoidata/packages.yaml`
  under `packages.brew`, applied in this order: `base`, `ownership`, `profiles`,
  `capacities`, then program selectors (`password_managers`, `terminals`,
  `editors`, `shells`, `toolchains`, `browsers`).
- Homebrew package installation is data-driven through the layered config above;
  there is no separate work-only imperative package installer script.
- Work-only Git overrides are included when `ownership` is work-owned.
