{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # system
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" ];
  boot.kernelParams = [
    "snd_intel_dspcfg.dsp_driver=3"
    "snd_hda_intel.dmic_detect=1"
  ];

  # network
  networking.hostName = "tuna";
  networking.networkmanager.enable = true;

  # time and date
  time.timeZone = "America/New_York";

  # language
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };

    inputMethod = {
      # enabled = true;
      # type = "fcitx5";
      enabled = "fcitx5"; # will be deprecated, swap to above
      fcitx5.addons = with pkgs; [
        qt6Packages.fcitx5-chinese-addons
        fcitx5-gtk
        catppuccin-fcitx5
      ];
      fcitx5.settings = {
        inputMethod = {
          "Groups/0" = {
            Name = "Default";
            "Default Layout" = "us";
            DefaultIM = "pinyin";
          };
          "Groups/0/Items/0".Name = "keyboard-us";
          "Groups/0/Items/1".Name = "pinyin";
        };
      };
      fcitx5.ignoreUserConfig = true;
    };
  };

  # lockscreen
  programs.i3lock.enable = true;
  security.pam.services.betterlockscreen = { };
  services.logind = {
    settings = {
      Login = {
        HandleLidSwitch = "ignore";
        HandleLidSwitchDocked = "ignore";
        LidSwitchIgnoreInhibited = "no";
      };
    };
  };

  systemd.services.betterlockscreen-pause = {
    description = "Lock screen before sleep";
    before = [
      "sleep.target"
      "suspend.target"
    ];
    wantedBy = [
      "sleep.target"
      "suspend.target"
    ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.betterlockscreen}/bin/betterlockscreen -l dim";
      User = "twm";
      Environment = "DISPLAY:=0";
    };
  };

  # audio
  security.rtkit.enable = true;
  programs.noisetorch.enable = true;
  services.pipewire = {
    enable = true;
    audio.enable = true;
    wireplumber.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    # pulse.enable = true;
    # jack.enable = true;

    wireplumber.extraConfig."10-no-ucm" = {
      "monitor.alsa.properties" = {
        "alsa.use-ucm" = false;
      };
    };
  };

  # auth
  # services.openssh.enable = true;
  # programs.ssh.startAgent = true;

  services.pcscd.enable = true;
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = with pkgs; pinentry-curses;
    enableSSHSupport = true;
  };

  # i3
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
    autoRepeatDelay = 200;
    autoRepeatInterval = 35;
    dpi = 192;

    desktopManager = {
      xterm.enable = false;
    };

    displayManager = {
      lightdm.enable = false;
    };

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu
        polybar
        i3lock
      ];
    };

    xkb = {
      layout = "us";
      variant = "";
    };
  };

  services.displayManager = {
    defaultSession = "none+i3";
    gdm.enable = true;
  };

  # filesystem
  services.udisks2.enable = true;
  services.gvfs.enable = true;

  # local users
  users.users.twm = {
    isNormalUser = true;
    description = "twm";
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "audio"
    ];
    packages = with pkgs; [ ];

    shell = pkgs.fish;
  };

  # graphics
  hardware.graphics = {
    enable = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  hardware.firmware = [ pkgs.sof-firmware ];
  hardware.enableRedistributableFirmware = true;

  # packages
  environment.systemPackages = with pkgs; [
    # terminal utils
    wget
    lshw
    pciutils
    tree
    fzf
    fish
    kitty

    # auth
    gnupg
    pinentry-curses

    # files
    yazi
    thunar
    thunar-volman
    ntfs3g
    zip
    unzip

    # browser
    librewolf
    firefox

    # programming
    neovim

    # programming langs/related
    (pkgs.texlive.combine {
      inherit (pkgs.texlive) 
        scheme-full;
    })
    (python3.withPackages (python-pkgs: with python-pkgs; [
      pandas
      requests
    ]))
    typst
    typstyle

    # screen
    maim

    # qol
    rofi
    xclip
    feh

    # git
    git

    # display
    brightnessctl
    # autorandr

    # audio
    pavucontrol
    qpwgraph

    # real life
    obsidian

    # game
    osu-lazer-bin
  ];

  # fish lol
  programs.fish.enable = true;

  # language
  fonts = {
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.symbols-only
      noto-fonts
      noto-fonts-color-emoji

      adwaita-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      maple-mono.variable
      wqy_zenhei
    ];

    fontconfig = {
      enable = true;

      defaultFonts = {
        emoji = [ "Noto Color Emoji" ];
        monospace = [
          "JetBrainsMono Nerd Font"
          "Noto Sans Mono CJK SC"
        ];
        sansSerif = [
          "Noto Sans"
          "Noto Sans CJK SC"
        ];
        serif = [
          "Noto Serif"
          "Noto Serif CJK SC"
        ];
      };
    };
  };

  environment.variables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    SDL_IM_MODULE = "fcitx";
    GLFW_IM_MODULE = "ibus";
  };

  # nix
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.11";
}
