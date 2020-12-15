# See: https://github.com/NixOS/nixos-hardware/tree/master/dell/xps/15-7590

{ config, lib, pkgs, ... }:

{
  # Boot.
  boot.loader = {
    # Use the systemd-boot EFI boot loader.
    systemd-boot.enable = true;

    efi.canTouchEfiVariables = true;

    # Intel CPI.
    # See: https://github.com/NixOS/nixos-hardware/blob/master/common/cpu/intel/default.nix
    initrd.kernelModules = [ "i915" ];

    # SSD.
    # See: https://github.com/NixOS/nixos-hardware/blob/master/common/pc/ssd/default.nix
    # kernel.sysctl = {
    #   "vm.swappiness" = lib.mkDefault 1;
    # };
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

      # Intel CPI.
      # See: https://github.com/NixOS/nixos-hardware/blob/master/common/cpu/intel/default.nix
      extraPackages = with pkgs; [
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
        intel-media-driver
      ];
    };

    bluetooth = {
      enable = true;
    };

    # Intel CPU.
    # See: https://github.com/NixOS/nixos-hardware/blob/master/common/cpu/intel/default.nix
    # cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };

  # Services.
  services = {
    xserver.videoDrivers = [ "nvidia" ];

    # SSD.
    # See: https://github.com/NixOS/nixos-hardware/blob/master/common/pc/ssd/default.nix
    # fstrim.enable = true;
  };
}
