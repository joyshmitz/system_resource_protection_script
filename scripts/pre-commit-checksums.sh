#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

scripts/update_checksums.sh

if ! git diff --quiet -- SHA256SUMS; then
  echo "[pre-commit] SHA256SUMS updated. Add it to your commit."
  git status --short SHA256SUMS
  exit 1
fi

echo "[pre-commit] checksums OK"
