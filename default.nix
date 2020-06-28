# See: https://nixos.org/nixos/options.html#

{ pkgs, lib, ... }@args:

let
  localPkgs = import ./pkgs args;

  home-manager = builtins.fetchGit {
    url = "https://github.com/rycee/home-manager.git";
    rev = "b78b5fa4a073dfcdabdf0deb9a8cfd56050113be";
    ref = "release-19.09";
  };

  # Check if config file exists.
  vpnConfigs = builtins.filter (item: builtins.pathExists item.config) [
    { name = "server"; config = "/home/superpaintman/.openvpn/server.conf"; }
  ];
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
    zip
    unzip
    unrar
    xclip
    bind # dig

    # Replacements for basic utils.
    exa # ls
    bat # cat
    fd # find

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

    # Messengers.
    localPkgs.tdesktop # Telegram.
    discord
    skypeforlinux

    # Terminals.
    alacritty
    xst

    # Compilers, interpreters and dev packages.
    gnumake
    clang
    clang-tools
    gcc
    cmake
    llvm
    go
    gotools
    godef
    go-outline
    gomodifytags
    impl
    nodejs
    python
    (
      python3.withPackages (
        packages: with packages; [
          telethon
        ]
      )
    )
    ruby
    rustup
    shfmt
    nixpkgs-fmt
    arduino

    # Docker.
    docker
    docker-compose

    # Server configuration utils.
    ansible
    terraform

    # Games.
    steam

    # Misc.
    (polybar.override { pulseSupport = true; })
    tldr # Simple man pages.
    lf # Terminal file manager.
    rofi # Window switcher, application launcher and dmenu replacement.
    feh # Image viewer.
    arandr # Visual front end for XRandR.
    pavucontrol # PulseAudio Volume Control.
    dbeaver # Universal SQL client.
    obs-studio # Streaming and recording program.
    audacity # Sound editor with graphical UI
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
      package = pkgs.pulseaudioFull;
    };

    opengl = {
      enable = true; # TODO(SuperPaintman): enable it only on Sequoia.
      driSupport32Bit = true;
    };

    bluetooth = {
      enable = true;
      package = pkgs.bluezFull;
    };
  };

  # Services.
  services.xserver = {
    enable = true;

    # Keyboard.
    layout = lib.concatStringsSep "," [ "us" "ru" ];
    xkbOptions = lib.concatStringsSep "," [
      "caps:escape" # Caps Lock as Ctrl.
      "grp:alt_shift_toggle" # Toggle layout.
      "grp_led:caps" # Use led as indicator.
    ];

    # Display, desktop and window managers.
    displayManager.sddm = {
      enable = true;
      autoNumlock = true;
    };

    desktopManager.xterm.enable = false;
    desktopManager.plasma5.enable = true;

    windowManager.awesome.enable = true;

    displayManager.sessionCommands = with pkgs; ''
      # Load X resources.
      ${xorg.xrdb}/bin/xrdb -load ~/.Xresources

      # Turn NumLock on.
      ${numlockx}/bin/numlockx on
    '';

    # Misc.
    videoDrivers = [ "nvidia" ]; # TODO(SuperPaintman): enable it only on Sequoia.
  };

  services.picom = {
    enable = true;
    backend = "glx";
    shadow = true;
    vSync = true;
  };

  services.blueman.enable = true;

  services.openvpn.servers =
    # Merge servicers into one set.
    lib.mkMerge (
      builtins.map (
        item: {
          "${item.name}" = {
            config = "config ${item.config}";
            autoStart = false;
          };
        }
      ) vpnConfigs
    );

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

  # Security.
  security.sudo = {
    enable = true;

    # Always ask password.
    wheelNeedsPassword = true;

    extraConfig = let
      vpnServices = builtins.map (item: item.name) vpnConfigs;
      vpnCommands = [ "start" "stop" "restart" "status" ];
    in
      ''
        # No password for `nixos-rebuild`.
        # %wheel ALL=(ALL:ALL) NOPASSWD: /run/current-system/sw/bin/nixos-rebuild switch

        # VPN.
        ${lib.concatStringsSep "\n" (
        lib.lists.flatten (
          builtins.map (
            name: (
              [ "# openvpn-${name}.service." ]
              ++ (
                builtins.map (
                  command: "%wheel ALL=(ALL:ALL) NOPASSWD: ${pkgs.systemd}/bin/systemctl ${command} openvpn-${name}.service"
                ) vpnCommands
              )
            )
          ) vpnServices
        )
      )}

        # Arduino.
        %wheel ALL=(ALL:ALL) NOPASSWD: ${pkgs.arduino}/bin/arduino
      '';
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
      font-awesome-ttf
      siji
      jetbrains-mono
      helvetica-neue-lt-std
    ];

    fontconfig.defaultFonts = {
      sansSerif = [ "Ubuntu" ];
      monospace = [ "JetBrains Mono" ];
    };
  };
}
