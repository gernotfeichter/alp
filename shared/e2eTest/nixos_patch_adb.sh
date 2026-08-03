#!/usr/bin/env bash
# On NixOS, Android SDK binaries are prebuilt dynamically-linked executables
# that cannot run out of the box (they request /lib64/ld-linux-x86-64.so.2,
# which NixOS stubs). This script repoints their ELF interpreter at the
# NixOS glibc dynamic linker so adb/fastboot work under Flutter.
#
# Re-run this after updating/re-extracting the Android SDK platform-tools.
set -euo pipefail

SDK_DIR="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-/home/nix/Android/Sdk}}"
PLATFORM_TOOLS="$SDK_DIR/platform-tools"

if [[ ! -d "$PLATFORM_TOOLS" ]]; then
  echo "platform-tools not found at $PLATFORM_TOOLS" >&2
  exit 1
fi

# Pick the loader with the newest glibc (binutils wrappers may reference several).
LOADER="$(for f in /nix/store/*-binutils-wrapper-*/nix-support/dynamic-linker; do
  [[ -f "$f" ]] || continue
  l="$(cat "$f")"
  v="$(printf '%s' "$l" | sed -E 's#.*/glibc-([0-9.]+-[0-9]+)/.*#\1#')"
  printf '%s %s\n' "$v" "$l"
done | sort -V -k1,1 | tail -n1 | cut -d' ' -f2-)"
if [[ -z "$LOADER" ]]; then
  echo "Could not determine the NixOS dynamic linker (patchelf won't be usable)." >&2
  exit 1
fi

echo "Using dynamic linker: $LOADER"

patched=0
for bin in "$PLATFORM_TOOLS"/*; do
  [[ -x "$bin" && -f "$bin" ]] || continue
  [[ "$(head -c 4 "$bin")" == $'\x7fELF' ]] || continue
  interp="$(readelf -l "$bin" 2>/dev/null | awk '/interpreter/{print $NF; exit}')" || true
  if [[ "$interp" != "$LOADER" ]]; then
    echo "Patching: $bin (was $interp)"
    nix --extra-experimental-features 'nix-command flakes' shell nixpkgs#patchelf -c patchelf --set-interpreter "$LOADER" "$bin"
    patched=$((patched + 1))
  fi
done

echo "Patched $patched binaries in $PLATFORM_TOOLS."

"$PLATFORM_TOOLS/adb" version
