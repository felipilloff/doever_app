#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

if [[ "$(uname -s)" != Linux || "$(uname -m)" != x86_64 ]]; then
  echo 'Run this script on Linux x86_64.' >&2
  exit 1
fi
for executable in flutter clang++ cmake ninja pkg-config tar; do
  if ! command -v "$executable" >/dev/null; then
    echo "Missing build dependency: $executable" >&2
    echo 'Ubuntu/Debian: sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev' >&2
    exit 1
  fi
done
pkg-config --exists gtk+-3.0
flutter pub get --enforce-lockfile
flutter build linux --release

bundle=build/linux/x64/release/bundle
output=build/releases
test -x "$bundle/doever"
cp LICENSE THIRD_PARTY_NOTICES.md "$bundle/"
mkdir -p "$output"
tar --exclude='./data/flutter_assets/kernel_blob.bin' -czf "$output/doever-linux-x64.tar.gz" -C "$bundle" .
(cd "$output" && sha256sum doever-linux-x64.tar.gz > doever-linux-x64.tar.gz.sha256)
printf 'Executable: %s/doever
Archive: %s/doever-linux-x64.tar.gz
' "$bundle" "$output"
