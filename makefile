.PHONY: get clean clear purge build install info fetch
build:
	makepkg -sfi
get:
	proxychains -q makepkg -g
fetch:
	./fetch-sources.sh
clean:
	rm -rf pkg src
clear:
	rm -rf pkg src linux-xanmod*
purge:
	rm -rf pkg src ./linux* ./config.last ./patch-* v*.patch cjktty-* ./0001-bore-*.patch
install:
	sudo pacman -U ./*.zst
info:
	makepkg --printsrcinfo > .SRCINFO
