#!/usr/bin/env bash
set -euo pipefail

fail() { printf 'ai-nixCfg cloud: %s\n' "$*" >&2; exit 1; }
need() { command -v "$1" >/dev/null || fail "Missing required command: $1"; }

provider=${1:-}
revision=${2:-}
profile=${3:-core}
url=${4:-}
checksum=${5:-}
case "$provider" in codex|claude|cursor) ;; *) fail "Choose codex, claude, or cursor";; esac
[[ $revision =~ ^[0-9a-f]{40}$ ]] || fail "Supply a full lowercase Git commit SHA"
case "$profile" in
  core) package=cloud-agent-tools ;;
  infra) package=cloud-agent-tools-infra ;;
  *) fail "Choose core or infra";;
esac
if [[ -n $url || -n $checksum ]]; then
  [[ ( $url =~ ^https://[^[:space:]]+$ || $url == /* ) && $checksum =~ ^[0-9a-f]{64}$ ]] ||
    fail "An artifact requires an HTTPS URL or absolute file path and a SHA-256 digest"
fi
[[ $# -le 5 ]] || fail "Usage: bootstrap.sh PROVIDER REVISION [core|infra] [HTTPS_URL_OR_FILE SHA256]"

need uname
case "$(uname -s)/$(uname -m)" in
  Linux/x86_64) system=x86_64-linux; nix_hash=eafe5042404e818505e28c5ca3d0885f3ec45c31f955489a25bb38258f87560e ;;
  Linux/aarch64|Linux/arm64) system=aarch64-linux; nix_hash=f1cee64ae7a02330c6421924c28f597c41813f2214ff108622087d8056378b08 ;;
  *) fail "Unsupported platform: $(uname -s)/$(uname -m). A 64-bit Linux worker is required." ;;
esac

: "${HOME:?HOME is required}"
state="$HOME/.local/state/ai-nixcfg-cloud"
for command in flock mkdir mktemp mv ln rm cat cp touch grep; do need "$command"; done
mkdir -p "$state/generations"
exec 9>"$state/lock"
flock 9
work=$(mktemp -d "$state/.setup.XXXXXXXX")
trap 'rm -rf -- "$work"' EXIT

download() {
  need curl
  curl -q --fail --silent --show-error --location --proto '=https' --proto-redir '=https' \
    --connect-timeout 15 --max-time 240 --retry 2 --output "$2" "$1" ||
    fail "Download failed. Check the setup network allowlist and artifact availability."
}
verify_hash() {
  need sha256sum
  printf '%s  %s\n' "$1" "$2" | sha256sum --check --status ||
    fail "SHA-256 verification failed"
}

setup_nix() {
  if [[ -f "$state/single-user" ]]; then
    export PATH="$HOME/.nix-profile/bin:$PATH" NIX_REMOTE=local
  fi
  if ! command -v nix >/dev/null && [[ -x "$HOME/.nix-profile/bin/nix" ]]; then
    export PATH="$HOME/.nix-profile/bin:$PATH"
  fi
  if ! command -v nix >/dev/null; then
    need id
    need tar
    need xz
    if [[ ! -e /nix ]]; then
      if [[ $(id -u) == 0 ]]; then
        mkdir -m 0755 /nix
      elif command -v sudo >/dev/null; then
        sudo -n install -d -m 0755 -o "$(id -u)" /nix ||
          fail "Cannot create /nix. Use a base with Nix or a writable /nix."
      fi
    fi
    [[ -d /nix && -w /nix ]] ||
      fail "Nix is unavailable and /nix is unwritable. Use a Nix-enabled base or the provider's native tools."
    local release="nix-2.34.7-$system"
    download "https://releases.nixos.org/nix/nix-2.34.7/$release.tar.xz" "$work/nix.tar.xz"
    verify_hash "$nix_hash" "$work/nix.tar.xz"
    tar -xJf "$work/nix.tar.xz" -C "$work"
    export NIX_REMOTE=local
    # A disposable single-user store has no nixbld group or daemon.
    export NIX_CONFIG="${NIX_CONFIG:-}"$'\nbuild-users-group =\nsandbox = false'
    if [[ -z ${NIX_SSL_CERT_FILE:-} && -r /etc/ssl/certs/ca-certificates.crt ]]; then
      export NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
    fi
    USER=$(id -un) sh "$work/$release/install" --no-daemon --yes --no-channel-add --no-modify-profile ||
      fail "Single-user Nix installation failed"
    export PATH="$HOME/.nix-profile/bin:$PATH"
    touch "$state/single-user"
  fi
  if [[ -f "$state/single-user" ]]; then
    export NIX_CONFIG="${NIX_CONFIG:-}"$'\nbuild-users-group =\nsandbox = false'
  fi
  need nix
  need nix-store
  nix store ping --extra-experimental-features nix-command >/dev/null ||
    fail "Nix was found but its store is unavailable"
}

import_closure() {
  need gzip
  if [[ $url == /* ]]; then
    [[ -f $url ]] || fail "Closure file is unavailable"
    cp -- "$url" "$work/closure.gz"
  else
    download "$url" "$work/closure.gz"
  fi
  verify_hash "$checksum" "$work/closure.gz"
  gzip -dc "$work/closure.gz" | (
    read -r kind pinned arch variant output extra
    [[ $kind == ai-nixcfg-cloud-v1 && $pinned == "$revision" && $arch == "$system" &&
       $variant == "$profile" && $output =~ ^/nix/store/[0-9a-z]{32}-cloud-agent-$profile$ &&
       -z $extra ]] || fail "Closure metadata does not match revision, architecture, and profile"
    nix-store --import >/dev/null || fail "Cannot import closure into this Nix store"
    nix-store --realise "$output" --add-root "$generation/result" --indirect >/dev/null
  )
}

generation="$state/generations/$revision-$system-$profile-${checksum:-source}"
mkdir -p "$generation"
if [[ ! -e "$generation/ready" || ! -x "$generation/result/bin/nix" ]]; then
  setup_nix
  if [[ -n $url ]]; then
    import_closure
  else
    nix build --extra-experimental-features 'nix-command flakes' --option accept-flake-config false \
      --no-write-lock-file --max-jobs 1 --out-link "$generation/result" \
      "github:DivitMittal/ai-nixCfg/$revision#packages.$system.$package" ||
      fail "Pinned flake build failed. Check GitHub and cache.nixos.org access or supply a verified closure."
  fi

  result="$generation/result"
  [[ $(cat "$result/profile") == "$system"$'\n'"$profile" ]] || fail "Unexpected toolchain profile"
  printf '%s\n' "$revision" > "$generation/revision"
  for name in bin config tools smoke.sh; do ln -sfn "result/$name" "$generation/$name"; done
fi

# Preserve the provider's existing PATH and credentials in the task shell.
cat > "$work/env" <<'ENV'
_ai_cloud_state="$HOME/.local/state/ai-nixcfg-cloud"
case ":$PATH:" in
  *":$_ai_cloud_state/current/bin:"*) ;;
  *) export PATH="$_ai_cloud_state/current/bin:$PATH" ;;
esac
if [ "${AI_NIXCFG_CLOUD_ACTIVE:-}" != "$_ai_cloud_state" ]; then
  export NIX_CONFIG="${NIX_CONFIG:-}"$'\nextra-experimental-features = nix-command flakes'
  if [ -f "$_ai_cloud_state/single-user" ]; then
    export NIX_REMOTE=local
    export NIX_CONFIG="$NIX_CONFIG"$'\nbuild-users-group =\nsandbox = false'
    if [ -z "${NIX_SSL_CERT_FILE:-}" ] && [ -r /etc/ssl/certs/ca-certificates.crt ]; then
      export NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
    fi
  fi
  export AI_NIXCFG_CLOUD_ACTIVE="$_ai_cloud_state"
fi
unset _ai_cloud_state
ENV
mv -f "$work/env" "$state/env"
bash "$generation/smoke.sh" "$provider" "$revision" ||
  fail "Toolchain or provider configuration verification failed"
touch "$generation/ready"
ln -s "$generation" "$work/current"
mv -Tf "$work/current" "$state/current"

# Codex and Cursor commonly open Bash shells. Keep existing startup content
# and leave noninteractive activation to the provider or explicit sourcing.
if [[ $provider != claude ]]; then
  rc="$HOME/.bashrc"
  marker='# ai-nixCfg cloud toolchain'
  if [[ -L $rc || ( -e $rc && ( ! -f $rc || ! -w $rc ) ) ]]; then
    printf 'ai-nixCfg cloud: source %s explicitly in task shells.\n' "$state/env" >&2
  elif ! grep -Fqx -- "$marker" "$rc" 2>/dev/null; then
    {
      printf '\n%s\n' "$marker"
      cat <<'BASHRC'
[ ! -r "$HOME/.local/state/ai-nixcfg-cloud/env" ] || . "$HOME/.local/state/ai-nixcfg-cloud/env"
BASHRC
    } >> "$rc"
  fi
fi
