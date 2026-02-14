#!/usr/bin/env sh

set -eu

if [ "${DOTFILES_DEBUG:-}" = "1" ] || [ "${DOTFILES_DEBUG:-}" = "true" ]; then
  set -x
fi

DEFAULT_DOTFILES_REPO_URL="https://github.com/heliologos/dotfiles"
LOCAL_DOTFILES_REPO_URL="git@github.com:heliologos/dotfiles.git"
DEFAULT_DOTFILES_BRANCH="master"

log() {
  printf '%s\n' "$*" >&2
}

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

resolve_dotfiles_repo() {
  if [ $# -gt 0 ] && [ -n "$1" ]; then
    printf '%s\n' "$1"
    return 0
  fi

  if [ -n "${DOTFILES_REPO_URL:-}" ]; then
    printf '%s\n' "${DOTFILES_REPO_URL}"
    return 0
  fi

  if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    origin_url="$(git config --get remote.origin.url || true)"
    if [ "${origin_url}" = "${LOCAL_DOTFILES_REPO_URL}" ]; then
      printf '%s\n' "${origin_url}"
      return 0
    fi
  fi

  printf '%s\n' "${DEFAULT_DOTFILES_REPO_URL}"
}

resolve_bin_dir() {
  if [ -n "${XDG_BIN_HOME:-}" ]; then
    printf '%s\n' "${XDG_BIN_HOME}"
    return 0
  fi

  if [ -n "${HOME:-}" ]; then
    printf '%s\n' "${HOME}/.local/bin"
    return 0
  fi

  die "HOME is not set"
}

resolve_age_identity() {
  if [ -n "${CHEZMOI_AGE_IDENTITY:-}" ]; then
    printf '%s\n' "${CHEZMOI_AGE_IDENTITY}"
    return 0
  fi

  if [ -n "${XDG_CONFIG_HOME:-}" ]; then
    printf '%s\n' "${XDG_CONFIG_HOME}/chezmoi/key.txt"
    return 0
  fi

  if [ -n "${HOME:-}" ]; then
    printf '%s\n' "${HOME}/.config/chezmoi/key.txt"
    return 0
  fi

  die "HOME is not set"
}

ensure_chezmoi() {
  if command -v chezmoi >/dev/null 2>&1; then
    command -v chezmoi
    return 0
  fi

  bin_dir="$(resolve_bin_dir)"
  mkdir -p "${bin_dir}"
  log "chezmoi was not found. Installing to ${bin_dir}..."

  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "${bin_dir}"

  chezmoi_cmd="${bin_dir}/chezmoi"
  [ -x "${chezmoi_cmd}" ] || die "failed to install chezmoi"
  printf '%s\n' "${chezmoi_cmd}"
}

ensure_age_identity() {
  chezmoi_cmd="$1"
  source_dir="$2"
  age_identity="$(resolve_age_identity)"
  age_identity_dir="$(dirname "${age_identity}")"
  source_age_identity="${source_dir}/home/key.txt.age"

  mkdir -p "${age_identity_dir}"
  chmod 700 "${age_identity_dir}" 2>/dev/null || true

  if [ -f "${age_identity}" ]; then
    chmod 600 "${age_identity}" 2>/dev/null || true
    printf '%s\n' "${age_identity}"
    return 0
  fi

  if [ -e "${age_identity}" ]; then
    die "age identity path exists but is not a regular file: ${age_identity}"
  fi

  if [ -f "${source_age_identity}" ]; then
    log "age identity was not found. Decrypting ${source_age_identity}..."
    "${chezmoi_cmd}" age decrypt --use-builtin-age true --passphrase --output "${age_identity}" "${source_age_identity}"
    chmod 600 "${age_identity}" 2>/dev/null || true
    printf '%s\n' "${age_identity}"
    return 0
  fi

  log "age identity was not found and no encrypted key was committed. Generating ${age_identity}..."
  "${chezmoi_cmd}" age-keygen -o "${age_identity}" >/dev/null
  chmod 600 "${age_identity}" 2>/dev/null || true
  printf '%s\n' "${age_identity}"
}

resolve_age_recipient() {
  chezmoi_cmd="$1"
  age_identity="$2"

  if [ -n "${CHEZMOI_AGE_RECIPIENT:-}" ]; then
    printf '%s\n' "${CHEZMOI_AGE_RECIPIENT}"
    return 0
  fi

  "${chezmoi_cmd}" age-keygen -y "${age_identity}"
}

main() {
  dotfiles_repo="$(resolve_dotfiles_repo "${1:-}")"
  dotfiles_branch="${DOTFILES_BRANCH:-${DEFAULT_DOTFILES_BRANCH}}"
  chezmoi_cmd="$(ensure_chezmoi)"
  "${chezmoi_cmd}" init --branch "${dotfiles_branch}" "${dotfiles_repo}"
  source_dir="$("${chezmoi_cmd}" source-path)"
  age_identity="$(ensure_age_identity "${chezmoi_cmd}" "${source_dir}")"
  age_recipient="$(resolve_age_recipient "${chezmoi_cmd}" "${age_identity}")"

  export CHEZMOI_AGE_IDENTITY="${age_identity}"
  export CHEZMOI_AGE_RECIPIENT="${age_recipient}"

  "${chezmoi_cmd}" apply --use-builtin-age true
}

main "$@"
