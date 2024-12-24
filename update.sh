#!/usr/bin/env -S nix shell nixpkgs#jq -c bash

set -euo pipefail

regex="^[0-9]\.[0-9]\.[0-9].*$"

info="info.json"
file_exists=$([ -f "$info" ] && echo 0 || echo 1)
oldversion=""

if [ "$file_exists" -eq 0 ]; then
  oldversion=$(jq -rc '.version' "$info")
fi

url="https://api.github.com/repos/zen-browser/desktop/releases?per_page=1"
version="$(curl -s "$url" | jq -rc '.[0].tag_name')"

if [ "$oldversion" != "$version" ] && [[ "$version" =~ $regex ]] && [[ "$file_exists" -eq 1 ]]; then
  echo "Found new version $version"
  sharedUrl="https://github.com/zen-browser/desktop/releases/download/${version}/zen.linux"

  aarch64="${sharedUrl}-aarch64.tar.bz2"
  x86_64="${sharedUrl}-x86_64.tar.bz2"

  # perform downloads in parallel
  echo "Prefetching files..."
  nix store prefetch-file "$aarch64" --log-format raw --json | jq -rc '.hash' >/tmp/aarch64-hash &
  nix store prefetch-file "$x86_64" --log-format raw --json | jq -rc '.hash' >/tmp/x86_64-hash &
  wait
  aarch64_hash=$(</tmp/aarch64-hash)
  x86_64_hash=$(</tmp/x86_64-hash)

  echo '{"version":"'"$version"'","x86_64":{"hash":"'"$x86_64_hash"'","url":"'"$x86_64"'"},"aarch64":{"hash":"'"$aarch64_hash"'","url":"'"$aarch64"'"}}' >"$info"
else
  echo "zen is up to date"
fi
