# See: https://github.com/NixOS/nixos-hardware/tree/master/dell/xps/15-7590

{ config, lib, pkgs, ... }:

{
  # Boot.
  boot.loader = {
    # Use the systemd-boot EFI boot loader.
    systemd-boot.enable = true;

    efi.canTouchEfiVariables = true;

    # SSD.
    # See: https://github.com/NixOS/nixos-hardware/blob/master/common/pc/ssd/default.nix
    # kernel.sysctl = {
    #   "vm.swappiness" = lib.mkDefault 1;
    # };
  };
  # Intel CPU.
  # See: https://github.com/NixOS/nixos-hardware/blob/master/common/cpu/intel/default.nix
  boot.initrd.kernelModules = [ "i915" ];

  # Networking.
  networking = {
    useDHCP = false;

    interfaces.wlp59s0.useDHCP = true;
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

    nvidia.prime = {
      offload.enable = true;

      # Bus ID of the Intel GPU.
      intelBusId = "PCI:0:2:0";

      # Bus ID of the NVIDIA GPU.
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # Nix Packages.
  # Allow unfree for Nvidia drivers.
  nixpkgs.config.allowUnfree = true;

  # Services.
  services = {
    xserver.videoDrivers = [ "nvidia" ];

    # SSD.
    # See: https://github.com/NixOS/nixos-hardware/blob/master/common/pc/ssd/default.nix
    # fstrim.enable = true;
  };
}
