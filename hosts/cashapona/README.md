# Cashapona

My laptop.

> [Cashapona](https://en.wikipedia.org/wiki/Socratea_exorrhiza)

## Specs

[DELL XPS 15 7590-6401](https://github.com/NixOS/nixos-hardware/tree/master/dell/xps/15-7590)

## Installation

```bash
# Make sure you in the dotfiles dir.
$ DOTFILES="$(pwd)"

# Backup generated configuration file.
$ sudo cp /etc/nixos/configuration.nix "/etc/nixos/configuration.nix.$(date +'%s').bu"

$ sudo tee /etc/nixos/configuration.nix <<EOF
{ config, pkgs, ... }:

{
  imports = [
    $DOTFILES/hosts/cashapona
  ];
}
EOF
```
