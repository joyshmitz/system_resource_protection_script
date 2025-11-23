#!/usr/bin/env bash
set -euo pipefail

REPO="Dicklesworthstone/system_resource_protection_script"
REF="${1:-main}"   # branch, tag, or commit sha (default: main)

die() { echo "[verify] $*" >&2; exit 1; }

require() { command -v "$1" >/dev/null 2>&1 || die "Missing required tool: $1"; }

require curl

sha_cmd=""
if command -v sha256sum >/dev/null 2>&1; then
  sha_cmd="sha256sum"
elif command -v shasum >/dev/null 2>&1; then
  sha_cmd="shasum -a 256"
else
  die "Missing required tool: sha256sum or shasum"
fi

CB="$(date +%s)"  # cache-buster
BASE="https://raw.githubusercontent.com/${REPO}/${REF}"
echo "[verify] Using ref: $REF"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

curl -fsSL "${BASE}/install.sh?cb=${CB}" -o "$tmp/install.sh" || die "Failed to download install.sh"
curl -fsSL "${BASE}/SHA256SUMS?cb=${CB}" -o "$tmp/SHA256SUMS" || die "Failed to download SHA256SUMS"

echo "[verify] Verifying checksum..."
(
  cd "$tmp"
  grep "  install.sh$" SHA256SUMS > install.sha
  $sha_cmd -c install.sha
)

echo "[verify] Checksum OK"

dest="${PWD}/install.sh"
cp "$tmp/install.sh" "$dest" || die "Failed to copy installer to $dest"
chmod +x "$dest" || true

echo "[verify] Wrote installer to: $dest"
echo "[verify] To run the installer:"
echo "$dest [--plan|--install|--uninstall]"
