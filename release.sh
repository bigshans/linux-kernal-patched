#!/usr/bin/env bash
set -euo pipefail

ver="${1:?usage: $0 <pkgver, e.g. 7.3.4>}"
tag="v${ver}-bore"

pkg="linux-xanmod-bore-cjktty-${ver}-1-x86_64.pkg.tar.zst"
hdr="linux-xanmod-bore-cjktty-headers-${ver}-1-x86_64.pkg.tar.zst"

for f in "$pkg" "$hdr"; do
  [[ -f "$f" ]] || { echo "missing: $f" >&2; exit 1; }
done

sha256sum "$pkg" "$hdr" > SHA256SUMS

gh release create "$tag" --generate-notes
gh release upload "$tag" "$pkg" "$hdr" SHA256SUMS
