# See: https://github.com/NixOS/nixos-hardware/tree/master/dell/xps/15-7590
# See: https://wiki.archlinux.org/index.php/Dell_XPS_15
# See: https://xps-15.fandom.com/wiki/XPS_15_Wiki

{ config, pkgs, ... }:

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
    xserver = {
      videoDrivers = [ "nvidia" ];

      # Display manager.
      displayManager =
        let
          xrandrCommands = with pkgs; ''
            ${xorg.xrandr}/bin/xrandr --output eDP-1 --primary --pos 0x1080 --output DP-3 --pos 0x0
          '';

          # See: `xbindkeys -d`
          # See: `xbindkeys -k`
          # See: `xmodmap -pk`
          xbindkeysRC = pkgs.writeText ".xbindkeysrc" (with pkgs; ''
            # Fn+F1.
            "${pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle"
              XF86AudioMute

            # Fn+F2.
            "${pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%"
              XF86AudioRaiseVolume

            # Fn+F3.
            "${pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%"
              XF86AudioLowerVolume

            # Fn+F11.
            "${brightnessctl}/bin/brightnessctl set 5%-"
              XF86MonBrightnessDown

            # Fn+F12.
            "${brightnessctl}/bin/brightnessctl set +5%"
              XF86MonBrightnessUp
          '');
        in
        {
          setupCommands = with pkgs; ''
            # Setup displays.
            ${xrandrCommands}

            # Setup Fn keys.
            ${procps}/bin/pkill xbindkeys || true
            ${xbindkeys}/bin/xbindkeys --file ${xbindkeysRC}
          '';

          sessionCommands = ''
            # Setup displays.
            ${xrandrCommands}
          '';
        };

      # Touchpad.
      libinput = {
        enable = true;

        additionalOptions = ''
          MatchIsTouchpad "on"
        '';

        # Enable natural scrolling behavior.
        naturalScrolling = true;
      };
    };

    # SSD.
    # See: https://github.com/NixOS/nixos-hardware/blob/master/common/pc/ssd/default.nix
    # fstrim.enable = true;

    thermald.enable = true;
  };
}
