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

## Profiles

On first apply, templates prompt for:
- `profile`: `home` or `work`
- work identity values (`name`, `email`) when profile is `work`
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
- `install/`: platform/profile-specific install helpers
- `bootstrap.sh`: one-shot setup script

## Notes

- Secrets are stored as age-encrypted files (`*.age`) in source.
- Work-only Git overrides are included conditionally by profile.
