{ pkgs, ... }@args:

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
  users.defaultUserShell = pkgs.fish;

  users.users.superpaintman = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.fish;
  };

  # Home Manager.
  home-manager.users.superpaintman = (
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
    in
      {
        home.file = {
          # Dotfiles.
          ".dotfiles".source = dotfiles;

          # Bash.
          ".bashrc".source = "${dotfiles}/bash/.bashrc";
          ".bash_profile".source = "${dotfiles}/bash/.bash_profile";
          ".bash".source = "${dotfiles}/bash/.bash";

          # Git.
          ".gitconfig".source = "${dotfiles}/git/.gitconfig";

          # Htop.
          ".config/htop/htoprc".source = "${dotfiles}/htop/htoprc";

          # NPM.
          ".npmrc".source = "${dotfiles}/npm/.npmrc";

          # Prettier.
          ".prettierrc.js".source = "${dotfiles}/prettier/.prettierrc.js";

          # TMUX.
          ".tmux.conf".source = "${dotfiles}/tmux/.tmux.conf";
          ".tmux".source = "${dotfiles}/tmux/.tmux";

          # VIM.
          ".vimrc".source = "${dotfiles}/vim/.vimrc";
          ".vim".source = "${dotfiles}/vim/.vim";

          # VS Code.
          ".config/Code/User/settings.json".source = "${dotfiles}/vscode/settings.json";
          ".config/Code/User/snippets".source = "${dotfiles}/vscode/snippets";

          # Yarn.
          ".yarnrc".source = "${dotfiles}/yarn/.yarnrc";

          # ZSH.
          ".zshrc".source = "${dotfiles}/zsh/.zshrc";
          ".zsh".source = "${dotfiles}/zsh/.zsh";
          ".oh-my-zsh".source = "${dotfiles}/zsh/.oh-my-zsh";
          ".oh-my-zsh-custom".source = "${dotfiles}/zsh/.oh-my-zsh-custom";
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
