# See: https://nixos.org/nixos/options.html#

{ pkgs, lib, ... }@args:

let
  localPkgs = import ./pkgs args;

  home-manager = builtins.fetchGit {
    url = "https://github.com/rycee/home-manager.git";
    rev = "b78b5fa4a073dfcdabdf0deb9a8cfd56050113be";
    ref = "release-19.09";
  };

  localDotfilesRepo = /home/superpaintman/Projects/github.com/SuperPaintman/dotfiles;

  hasLocalDotfilesRepo = builtins.pathExists localDotfilesRepo;

  dotfiles = (
    # Use local copy of Dotfile if we have one.
    if hasLocalDotfilesRepo
    then localDotfilesRepo
    else (
      # TODO(SuperPaintman): fetch submodules.
      builtins.fetchGit {
        url = "https://github.com/SuperPaintman/dotfiles";
      }
    )
  );

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

  # TODO(SuperPaintman): it doesn't work with my wifi stick :(.
  # boot.extraModulePackages = with config.boot.kernelPackages; [
  #   rtl8812au # WiFi driver.
  # ];

  # Nix.
  nix.trustedUsers = [ "root" "@wheel" ];

  # Nix Packages.
  nixpkgs.config.allowUnfree = true;

  # Networking.
  networking.hostName = "sequoia"; # TODO(SuperPaintman): change it. Sequoia is my desktop.
  networking.networkmanager.enable = true;

  # Environment.
  environment.systemPackages = with pkgs; lib.lists.flatten [
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
    wirelesstools
    lsof

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
    (
      vscode-with-extensions.override {
        vscodeExtensions = let
          vscodeExtensionsFile = "${dotfiles}/vscode/extensions.nix";
        in
          if builtins.pathExists vscodeExtensionsFile
          then (import vscodeExtensionsFile args)
          else [];
      }
    )
    android-studio

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
    (
      # Fix Rust's OpenSSL problem.
      # See: https://discourse.nixos.org/t/openssl-dependency-for-rust/3186
      builtins.map (
        item: writeScriptBin item ''
          #!${stdenv.shell}
          export OPENSSL_INCLUDE_DIR="${openssl.dev}/include"
          export OPENSSL_LIB_DIR="${openssl.out}/lib"
          export OPENSSL_ROOT_DIR="${openssl.out}"

          ${rustup}/bin/${item} $@
        ''
      ) [
        "cargo"
        "cargo-clippy"
        "cargo-fmt"
        "cargo-miri"
        "clippy-driver"
        "rls"
        "rust-gdb"
        "rust-lldb"
        "rustc"
        "rustdoc"
        "rustfmt"
        "rustup"
      ]
    )
    ghc
    stack
    haskellPackages.brittany
    localPkgs.dart
    localPkgs.flutter
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
    fzf # A command-line fuzzy finder written in Go.
    ripgrep # A utility that combines the usability of The Silver Searcher with the raw speed of grep.
    rofi # Window switcher, application launcher and dmenu replacement.
    feh # Image viewer.
    arandr # Visual front end for XRandR.
    pavucontrol # PulseAudio Volume Control.
    dbeaver # Universal SQL client.
    obs-studio # Streaming and recording program.
    audacity # Sound editor with graphical UI.
    scrot # A command-line screen capture utility.
    libnotify # A library that sends desktop notifications to a notification daemon.
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
      "caps:escape" # Caps Lock as Escape.
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
      mkDonfilesSymlinks = files: pkgs.runCommand "symlink-dotfiles" {} ''
        ${lib.concatStringsSep "\n" (
        lib.mapAttrsToList (
          name: file: ''
            # ${name}.
            mkdir -p $out/$(dirname ${name})
            ln -s ${toString file.source} $out/${name}
          ''
        ) files
      )}
      '';

      filesToSymlinks = files: { ignore ? [] }:
        let
          checkIsSymlink = n: v:
            (lib.hasAttr "source" v) && (lib.all (re: builtins.match re n == null) ignore);

          groups = {
            symlinks = lib.filterAttrs (n: v: checkIsSymlink n v) files;
            rest = lib.filterAttrs (n: v: !(checkIsSymlink n v)) files;
          };

          replaceWithSymlinks = files:
            let
              symlinks = mkDonfilesSymlinks files;
            in
              lib.mapAttrs (
                n: v: {
                  source = "${symlinks}/${n}";
                }
              ) files;
        in
          (replaceWithSymlinks groups.symlinks) // groups.rest;

      files = lib.mkMerge [
        # Make symlinks to local dotfiles instead of nix derivatives to
        # enable local editing.
        (
          let
            # Support old dotfiles format.
            callIfFunction = f: args: if builtins.isFunction f then (f args) else f;

            dotfilesFiles = callIfFunction (import dotfiles) {
              isMacOS = pkgs.stdenv.hostPlatform.isMacOS;
            };
          in
            if hasLocalDotfilesRepo then (filesToSymlinks dotfilesFiles {}) else dotfilesFiles
        )
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
