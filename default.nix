{ pkgs, ... }:
{
  # Boot.
  boot.cleanTmpDir = true; # Delete all files in `/tmp` during boot.

  # Nix Packages.
  nixpkgs.config.allowUnfree = true;

  # Networking.
  networking.hostName = "sequoia"; # TODO(SuperPaintman): change it. Sequoia is my desktop.
  networking.networkmanager.enable = true;

  # Environment.
  environment.systemPackages = with pkgs; [
    # Basic packages.
    coreutils
    wget
    curl
    atop
    htop
    git
    jq
    tmux
    xclip

    # Shells.
    bash
    fish
    zsh

    # Editors.
    vim
    vscode

    # Browsers.
    firefox

    # Terminals.
    xst

    # Compilers and interpreters.
    go
  ];

  # Programs.
  programs = {
    fish.enable = true;
    zsh.enable = true;
  };

  # Time.
  time.timeZone = "Europe/Moscow";

  # Sound.
  sound.enable = true;

  # Hardware.
  hardware = {
    pulseaudio.enable = true; # Enable the PulseAudio sound server.

    opengl.enable = true; # TODO(SuperPaintman): enable it only on Sequoia.
  };

  # Services.
  services.xserver = {
    enable = true;

    displayManager.sddm.enable = true;

    desktopManager.xterm.enable = false;
    desktopManager.plasma5.enable = true;

    videoDrivers = [ "nvidia" ]; # TODO(SuperPaintman): enable it only on Sequoia.
  };

  # Users.
  users.defaultUserShell = pkgs.fish;

  users.users.superpaintman = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
  };
}
