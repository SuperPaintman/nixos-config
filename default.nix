{ pkgs, lib, ... }@args:

let
  localPkgs = import ./pkgs args;

  home-manager = builtins.fetchGit {
    url = "https://github.com/rycee/home-manager.git";
    rev = "b78b5fa4a073dfcdabdf0deb9a8cfd56050113be";
    ref = "release-19.09";
  };
in
{
  # Imports.
  imports = [
    (import "${home-manager}/nixos")
  ];

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
    unrar
    xclip

    # Replacements for basic utils.
    exa # ls
    bat # cat

    # Shells.
    bash
    fish
    zsh

    # Editors.
    vim
    vscode

    # Browsers.
    firefox
    chromium

    # Terminals.
    xst

    # Compilers, interpreters and dev packages.
    clang
    gcc
    cmake
    go
    nodejs
    python3
    ruby

    # Docker.
    docker
    docker-compose

    # Server configuration utils.
    ansible
    terraform

    # Games.
    steam

    # Misc.
    dbeaver # Universal SQL client.
    obs-studio # Streaming and recording program.
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

  # Virtualisation.
  virtualisation.docker.enable = true;

  # Users.
  users.defaultUserShell = pkgs.zsh;

  users.users.superpaintman = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.zsh;
  };

  # Home Manager.
  home-manager.users = (
    let
      dotfiles = (
        # Use local copy of Dotfile if we have one.
        if builtins.pathExists /home/superpaintman/Projects/github.com/SuperPaintman/dotfiles
        then /home/superpaintman/Projects/github.com/SuperPaintman/dotfiles
        else (
          # TODO(SuperPaintman): fetch submodules.
          builtins.fetchGit {
            url = "https://github.com/SuperPaintman/dotfiles";
          }
        )
      );

      files = lib.mkMerge [
        (import dotfiles)
        # {
        #   # Dotfiles.
        #   ".dotfiles".source = dotfiles;
        # }
      ];
    in
      {
        superpaintman = {
          # Or pick manually.
          # lib.getAttrs [
          #   # Dotfiles.
          #   ".dotfiles"
          # ] files;

          home.file = files;
        };

        root = {
          home.file = files;
        };
      }
  );

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
