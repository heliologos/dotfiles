#!/usr/bin/env sh

set -eu

if [ "${DOTFILES_DEBUG:-}" = "1" ] || [ "${DOTFILES_DEBUG:-}" = "true" ]; then
  set -x
fi

DEFAULT_DOTFILES_REPO_URL="https://github.com/tarmuid/dotfiles"
LOCAL_DOTFILES_REPO_URL="git@github.com:tarmuid/dotfiles.git"
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

decrypt_age_identity() {
  chezmoi_cmd="$1"
  source_age_identity="$2"
  age_identity="$3"
  passphrase="${CHEZMOI_AGE_KEY_PASSPHRASE:-}"

  if [ -z "${passphrase}" ]; then
    if [ ! -r /dev/tty ]; then
      die "cannot prompt for age passphrase (no TTY available); set CHEZMOI_AGE_KEY_PASSPHRASE"
    fi

    printf 'Enter passphrase for %s: ' "${source_age_identity}" >/dev/tty
    stty_state="$(stty -g </dev/tty 2>/dev/null || true)"
    stty -echo </dev/tty 2>/dev/null || true
    IFS= read -r passphrase </dev/tty || true
    if [ -n "${stty_state}" ]; then
      stty "${stty_state}" </dev/tty 2>/dev/null || true
    else
      stty echo </dev/tty 2>/dev/null || true
    fi
    printf '\n' >/dev/tty
  fi

  [ -n "${passphrase}" ] || die "empty age passphrase"

  if command -v expect >/dev/null 2>&1; then
    CHEZMOI_EXPECT_CMD="${chezmoi_cmd}" \
    CHEZMOI_EXPECT_OUT="${age_identity}" \
    CHEZMOI_EXPECT_SRC="${source_age_identity}" \
    CHEZMOI_EXPECT_PASS="${passphrase}" \
    expect -c '
      set timeout 120
      log_user 0
      set attempts 0
      set cmd $env(CHEZMOI_EXPECT_CMD)
      set out $env(CHEZMOI_EXPECT_OUT)
      set src $env(CHEZMOI_EXPECT_SRC)
      set pass $env(CHEZMOI_EXPECT_PASS)
      spawn -noecho $cmd age decrypt --use-builtin-age true --passphrase --output $out $src
      expect {
        timeout { exit 124 }
        -nocase -re "enter passphrase: ?" {
          incr attempts
          if {$attempts > 3} { exit 125 }
          send -- "$pass\r"
          exp_continue
        }
        eof
      }
      catch wait result
      exit [lindex $result 3]
    '
    status=$?
  else
    # Fallback to native prompt behavior if expect is unavailable.
    if [ -t 0 ]; then
      "${chezmoi_cmd}" age decrypt --use-builtin-age true --passphrase --output "${age_identity}" "${source_age_identity}"
    elif [ -r /dev/tty ]; then
      "${chezmoi_cmd}" age decrypt --use-builtin-age true --passphrase --output "${age_identity}" "${source_age_identity}" </dev/tty
    else
      die "cannot prompt for age passphrase (no TTY available)"
    fi
    status=$?
  fi

  unset passphrase
  case "${status}" in
    124) die "timed out waiting for age passphrase input" ;;
    125) die "age passphrase was rejected multiple times" ;;
  esac
  return "${status}"
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
  source_age_identity=""

  # Support both source layouts:
  # 1) source dir is repo root   -> ${source_dir}/home/key.txt.age
  # 2) source dir is "home" root -> ${source_dir}/key.txt.age
  for candidate in \
    "${source_dir}/key.txt.age" \
    "${source_dir}/home/key.txt.age"
  do
    if [ -f "${candidate}" ]; then
      source_age_identity="${candidate}"
      break
    fi
  done

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

  if [ -n "${source_age_identity}" ]; then
    log "age identity was not found. Decrypting ${source_age_identity}..."
    decrypt_age_identity "${chezmoi_cmd}" "${source_age_identity}" "${age_identity}"
    if [ ! -s "${age_identity}" ]; then
      die "age identity decryption produced an empty file: ${age_identity}"
    fi
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

  log "[1/5] Ensuring chezmoi is installed..."
  chezmoi_cmd="$(ensure_chezmoi)"

  log "[2/5] Initializing dotfiles from ${dotfiles_repo} (branch: ${dotfiles_branch})..."
  "${chezmoi_cmd}" init --branch "${dotfiles_branch}" "${dotfiles_repo}"

  log "[3/5] Resolving chezmoi source directory..."
  source_dir="$("${chezmoi_cmd}" source-path)"

  log "[4/5] Ensuring age encryption identity..."
  age_identity="$(ensure_age_identity "${chezmoi_cmd}" "${source_dir}")"
  age_recipient="$(resolve_age_recipient "${chezmoi_cmd}" "${age_identity}")"

  export CHEZMOI_AGE_IDENTITY="${age_identity}"
  export CHEZMOI_AGE_RECIPIENT="${age_recipient}"

  log "[5/5] Applying dotfiles..."
  "${chezmoi_cmd}" apply

  log "Bootstrap complete."
}

main "$@"
