{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" ];
  # boot.extraModprobeConfig = ''
  #   options snd_intel_dspcfg dsp_driver=1
  # '';
  boot.kernelParams = [ 
    "snd_intel_dspcfg.dsp_driver=3" 
    "snd_hda_intel.dmic_detect=1" 
    ];

  networking.hostName = "tuna";
  networking.networkmanager.enable = true;

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
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

  security.pam.services.betterlockscreen = {};
  services.logind = {
    settings = {
      Login = {
        HandleLidSwitch = "suspend";
        LidSwitchIgnoreInhibited = "no";
      };
    };
  };

  systemd.services.betterlockscreen-pause = {
    description = "Lock screen before sleep";
    before = [ "sleep.target" "suspend.target" ];
    wantedBy = [ "sleep.target" "suspend.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.betterlockscreen}/bin/betterlockscreen -l dim";
      User = "twm";
      Environment = "DISPLAY:=0";
    };
  };

  security.rtkit.enable = true;
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

  services.openssh.enable = true;
  programs.ssh.startAgent = true;

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

  programs.i3lock.enable = true;
  programs.fish.enable = true;
  programs.noisetorch.enable = true;

  services.displayManager = {
    defaultSession = "none+i3";
    gdm.enable = true;
  };

  services.udisks2.enable = true;
  services.gvfs.enable = true;

  users.users.twm = {
    isNormalUser = true;
    description = "twm";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" ];
    packages = with pkgs; [];

    shell = pkgs.fish;
  };

  nixpkgs.config.allowUnfree = true;

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

  environment.systemPackages = with pkgs; [
    # terminal utils
    wget
    lshw
    pciutils
    tree
    fzf
    fish
    kitty

    # files
    yazi
    thunar
    thunar-volman
    ntfs3g

    # browser
    librewolf
    firefox
    
    # text editing
    neovim
    (pkgs.vscode-with-extensions.override {
      vscode = pkgs.vscodium;
      vscodeExtensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        ms-python.python
        james-yu.latex-workshop
        vscodevim.vim
      ];
    })
    (pkgs.texlive.combine {
      inherit (pkgs.texlive) scheme-medium;
    })

    # screen
    maim

    # qol
    rofi
    xclip

    # git!
    git

    # display
    brightnessctl
    # autorandr

    # audio
    pavucontrol
    qpwgraph
  ];

  fonts = {
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      noto-fonts
      noto-fonts-color-emoji
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font" ];
        sansSerif = [ "Noto Sans" ];
        serif = [ "Noto Serif" ];
      };
    };
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "25.11";
}
