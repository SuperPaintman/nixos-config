{ pkgs, ... }@args:

let
  localPkgs = import ./pkgs args;
in
{
  # Boot.
  boot.cleanTmpDir = true; # Delete all files in `/tmp` during boot.

  # Nix.
  nix.trustedUsers = [ "root" "@wheel" ];

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
    unzip
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

    # Compilers, interpreters and dev packages.
    clang
    gcc
    cmake
    go
    nodejs

    # Server configuration utils.
    ansible
    terraform

    # Games.
    steam

    # Misc.
    nixpkgs-fmt
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
    pulseaudio = {
      enable = true; # Enable the PulseAudio sound server.
      support32Bit = true;
    };

    opengl = {
      enable = true; # TODO(SuperPaintman): enable it only on Sequoia.
      driSupport32Bit = true;
    };
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

  # Fonts.
  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;

    fonts = with pkgs; [
      ubuntu_font_family
      dejavu_fonts
      fira-code

      localPkgs.jetbrains-mono
    ];

    fontconfig.defaultFonts = {
      sansSerif = [ "Ubuntu" ];
      monospace = [ "JetBrains Mono" ];
    };
  };
}
