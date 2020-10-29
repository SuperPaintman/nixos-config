NIXOS_VERSION := 20.03

NIX_FILES := $(shell find -type f -name '*.nix')

all: channels upgrade

.PHONY: upgrade
upgrade: update switch

.PHONY: update
update: channels
	@sudo nix-channel --update

.PHONY: switch
switch:
	@sudo nixos-rebuild switch

.PHONY: build
build:
	nixos-rebuild build

.PHONY: dry-build
dry-build:
	nixos-rebuild dry-build

.PHONY: gc
gc:
	@sudo nix-collect-garbage -d

.PHONY: format
format:
	@nixpkgs-fmt $(NIX_FILES)

# Add NixOS channels.
# See: https://nixos.org/nixos/manual/index.html#sec-upgrading .
.PHONY: channels
channels:
	@sudo nix-channel --add "https://nixos.org/channels/nixos-$(NIXOS_VERSION)" nixos
	@sudo nix-channel --list

.PHONY: uninstall-users-packages
uninstall-users-packages:
	@nix-env --uninstall $$(nix-env -q)

.PHONY: clean
clean:
	@rm -f result
