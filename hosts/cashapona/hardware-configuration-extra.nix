# See: https://github.com/NixOS/nixos-hardware/tree/master/dell/xps/15-7590

{ config, pkgs, ... }:

{
  # Boot.
  boot.loader = {
    # Use the systemd-boot EFI boot loader.
    boot.loader.systemd-boot.enable = true;

    efi.canTouchEfiVariables = true;
  };

  # Networking.
  networking = {
    useDHCP = false;

    networking.interfaces.wlp59s0.useDHCP = true;
  };

  # Sound.
  sound.enable = true;

  # Hardware.
  hardware = {
    pulseaudio = {
      enable = true;
    };

    opengl = {
      enable = true;
    };

    bluetooth = {
      enable = true;
    };
  };

  # Services.
  services.xserver = {
    videoDrivers = [ "nvidia" ];
  };
}
