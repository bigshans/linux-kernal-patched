.PHONY: get clean purge build
build:
	makepkg -sfi
get:
	makepkg -g
clean:
	rm -rf pkg src
purge:
	rm -rf pkg src ./linux* ./config.last ./patch-* v*.patch cjktty-*
