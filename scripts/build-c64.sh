#!/usr/bin/env bash
# Tokenize C64 BASIC source (src/c64/*.bas) into .prg files under build/c64/.
# Usage: scripts/build-c64.sh [file.bas ...]   (no args = build everything)
set -euo pipefail

cd "$(dirname "$0")/.."

command -v petcat >/dev/null || { echo "petcat not found (install VICE)" >&2; exit 1; }

out=build/c64
mkdir -p "$out"

# Build the given files, or every .bas under src/c64 if none were named.
if [ "$#" -gt 0 ]; then
  files=("$@")
else
  files=(src/c64/*.bas)
fi

for src in "${files[@]}"; do
  prg="$out/$(basename "${src%.bas}").prg"
  petcat -w2 -o "$prg" -- "$src"
  printf 'built %s -> %s\n' "$src" "$prg"
done
