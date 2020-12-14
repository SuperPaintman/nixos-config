{ config, pkgs, ... }:

{
  # Boot.
  boot.loader = {
    # Use the systemd-boot EFI boot loader.
    systemd-boot.enable = true;

    efi.canTouchEfiVariables = true;
  };

  # Networking.
  networking = {
    useDHCP = false;

    interfaces.eno1.useDHCP = true;
  };

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
