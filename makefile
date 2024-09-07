.PHONY: get clean purge build
build:
	makepkg -sfi
get:
	proxychains -q makepkg -g
clean:
	rm -rf pkg src
clear:
	rm -rf pkg src linux-xanmod*
purge:
	rm -rf pkg src ./linux* ./config.last ./patch-* v*.patch cjktty-*
install:
	sudo pacman -U ./*.zst
info:
	makepkg --printsrcinfo > .SRCINFO
