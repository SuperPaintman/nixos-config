NIXOS_VERSION := 20.03

NIX_FILES := $(shell find -type f -name '*.nix')

all: channels upgrade

upgrade: update switch

update: channels
	@sudo nix-channel --update

switch:
	@sudo nixos-rebuild switch

gc:
	@nix-collect-garbage -d

format:
	@nixpkgs-fmt $(NIX_FILES)

# Add NixOS channels.
# See: https://nixos.org/nixos/manual/index.html#sec-upgrading .
channels:
	@sudo nix-channel --add "https://nixos.org/channels/nixos-$(NIXOS_VERSION)" nixos
	@sudo nix-channel --list
