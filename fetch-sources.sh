#!/usr/bin/env bash
#
# Fetch this PKGBUILD's remote sources with multiple mirror fallbacks and
# sha256 verification. Files are written next to this script (makepkg's SRCDEST
# default), so a later `makepkg` will reuse them without downloading.
#
# Keep the version/shas below in sync when bumping pkgver. curl honours
# https_proxy / all_proxy from the environment.
#
set -euo pipefail
cd "$(dirname "$0")"

fetch() {
  local name=$1 want=$2; shift 2
  local dest="./$name" tmp got u

  if [[ -f $dest ]] && [[ "$(sha256sum "$dest" | cut -d' ' -f1)" == "$want" ]]; then
    printf 'ok   %-28s (cached)\n' "$name"
    return 0
  fi

  # offline fallback: backup/ survives `make purge` and is sha256-verified too
  if [[ -f "backup/$name" ]] && [[ "$(sha256sum "backup/$name" | cut -d' ' -f1)" == "$want" ]]; then
    cp -f "backup/$name" "$dest"
    printf 'ok   %-28s (restored from backup/)\n' "$name"
    return 0
  fi

  tmp=$(mktemp)
  for u in "$@"; do
    printf 'try  %-28s <- %s\n' "$name" "$u"
    if curl -fSL --retry 3 --retry-delay 2 --connect-timeout 20 -o "$tmp" "$u" 2>/dev/null; then
      got=$(sha256sum "$tmp" | cut -d' ' -f1)
      if [[ "$got" == "$want" ]]; then
        mv -f "$tmp" "$dest"
        printf 'ok   %-28s\n' "$name"
        return 0
      fi
      printf 'warn %-28s sha mismatch: %s\n' "$name" "$got"
    fi
  done
  rm -f "$tmp"
  printf 'FAIL %-28s (all mirrors failed)\n' "$name" >&2
  return 1
}

# Linux 7.3 tarball
fetch linux-7.3.tar.xz \
  87363c24f10e06321eb362765521094e94471f6bff8bce2d6b3e40f39f004953 \
  https://cdn.kernel.org/pub/linux/kernel/v7.x/linux-7.3.tar.xz \
  https://mirrors.edge.kernel.org/pub/linux/kernel/v7.x/linux-7.3.tar.xz

# XanMod 7.3.4 patch (SourceForge mirrors rotate; try several)
fetch patch-7.3.4-xanmod1.xz \
  3dffaf5a372654fa0cf718b1a60e6a94afcd8ee931f78e5a180c37a403598d9d \
  https://downloads.sourceforge.net/project/xanmod/releases/main/7.3.4-xanmod1/patch-7.3.4-xanmod1.xz \
  https://master.dl.sourceforge.net/project/xanmod/releases/main/7.3.4-xanmod1/patch-7.3.4-xanmod1.xz \
  https://netix.dl.sourceforge.net/project/xanmod/releases/main/7.3.4-xanmod1/patch-7.3.4-xanmod1.xz \
  https://versaweb.dl.sourceforge.net/project/xanmod/releases/main/7.3.4-xanmod1/patch-7.3.4-xanmod1.xz \
  https://cytranet.dl.sourceforge.net/project/xanmod/releases/main/7.3.4-xanmod1/patch-7.3.4-xanmod1.xz \
  https://sourceforge.net/projects/xanmod/files/releases/main/7.3.4-xanmod1/patch-7.3.4-xanmod1.xz/download

# cjktty CJK console patch
fetch cjktty-7.3.4.patch \
  e70aacb66cf4f015fe83e91119705c5fc354ff7009fddb5dd2dec38e3a337bb7 \
  https://raw.githubusercontent.com/bigshans/cjktty-patches/master/v7.x/cjktty-7.3.4.patch \
  https://cdn.jsdelivr.net/gh/bigshans/cjktty-patches@master/v7.x/cjktty-7.3.4.patch \
  https://github.com/bigshans/cjktty-patches/raw/master/v7.x/cjktty-7.3.4.patch

# cjktty CJK 32x32 font data (same upstream repo, unversioned file pinned by commit)
# No jsDelivr mirror here: it rejects files larger than 20 MiB.
fetch cjktty-add-cjk32x32-font-data.patch \
  c648ff21f0a5714743bbae85d6c6e1ed2bf961b6bca976d4c6b4c8d3f6b2739f \
  https://raw.githubusercontent.com/bigshans/cjktty-patches/b43d618da6d6536338761a5fc7c9c377c318fb9e/cjktty-add-cjk32x32-font-data.patch \
  https://github.com/bigshans/cjktty-patches/raw/b43d618da6d6536338761a5fc7c9c377c318fb9e/cjktty-add-cjk32x32-font-data.patch

# BORE scheduler patch (pinned to a commit)
fetch 0001-bore-7.3.4-7.0.1.patch \
  59349771e5cde001b5456b29b9d302f5dca9cdbe60beb43d1161a85b21c1a82d \
  https://raw.githubusercontent.com/firelzrd/bore-scheduler/715ea6fe8192ada3a0de6deb7015571bc638b5cc/patches/testing/0001-linux7.3-rc2-bore-7.0.1.patch \
  https://cdn.jsdelivr.net/gh/firelzrd/bore-scheduler@715ea6fe8192ada3a0de6deb7015571bc638b5cc/patches/testing/0001-linux7.3-rc2-bore-7.0.1.patch

printf '\nAll sources verified.\n'
