set +e

gh release create v$1-bore --generate-notes
gh release upload v$1-bore linux-xanmod-bore-cjktty-$1-1-x86_64.pkg.tar.zst linux-xanmod-bore-cjktty-headers-$1-1-x86_64.pkg.tar.zst
