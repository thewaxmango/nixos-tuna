{
  config,
  pkgs,
  lib,
  ...
}:

{
  home.username = "twm";
  home.homeDirectory = "/home/twm";
  home.stateVersion = "25.11";

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.catppuccin-cursors.mochaLavender;
    name = "catppuccin-mocha-lavender-cursors";
    size = 44;
  };

  home.sessionVariables = {
    GTK_THEME = "catppuccin-mocha-lavender-standard";
    QT_AUTO_SCREEN_SCALE_FACTOR = "0";
    QT_SCREEN_SCALE_FACTORS = "1;1";
    QT_SCALE_FACTOR = "1";
  };

  xresources.properties = {
    "Xft.dpi" = 192;
    "Xcursor.size" = 44;
  };

  xsession.initExtra = ''
    ${pkgs.xrandr}/bin/xrandr --dpi 192
    if ${pkgs.xrandr}/bin/xrandr | grep -q "HDMI-0 connected"; then
      ${pkgs.xrandr}/bin/xrandr --output HDMI-0 --auto --right-of DP-4
    fi
  '';

  xsession.windowManager.i3 = let
    laptop = "DP-4";
    laptopRes = "2560x1600";
    laptopHz = "165.00";

    external = "HDMI-0";
    externalRes = "1920x1080";
    externalHz = "60.00";
  in {
    enable = true;

    config = {
      terminal = "kitty";
      modifier = "Mod4";
      bars = [];

      gaps = {
        inner = 10;
        outer = 0;
      };

      window = {
        border = 0;
        titlebar = false;

        commands = [
          {
            command = "floating enable, resize set 1200 900, move position center";
            criteria = {
              class = "Xdg-desktop-portal-gtk";
            };
          }
          {
            command = "floating enable, resize set 1200 900, move position center";
            criteria = {
              window_role = "GtkFileChooserDialog";
            };
          }
          {
            command = "floating enable, resize set 1200 900, move position center";
            criteria = {
              title = "Open File";
            };
          }
          {
            command = "floating enable, resize set 1200 900, move position center";
            criteria = {
              title = "Save File";
            };
          }
        ];
      };

      floating = {
        border = 0;
        titlebar = false;
      };

      fonts = {
        names = [ "JetBrainsMono Nerd Font" ];
        size = 12.0;
      };

      startup = [
        {
          command = ''
            ${pkgs.writeShellScript "monitor-setup" ''
              if ${pkgs.xrandr}/bin/xrandr | ${pkgs.gnugrep}/bin/grep "${external} connected"; then
                if ${pkgs.gnugrep}/bin/grep -q "closed" /proc/acpi/button/lid/LID0/state; then
                  ${pkgs.xrandr}/bin/xrandr \
                    --output ${laptop} --off \
                    --output ${external} --primary --mode ${externalRes} --rate ${externalHz} --scale 1.5x1.5
                else
                  ${pkgs.xrandr}/bin/xrandr \
                    --output ${laptop} --primary --mode ${laptopRes} --rate ${laptopHz} \
                    --output ${external} --mode ${externalRes} --rate ${externalHz} --right-of ${laptop} --scale 1.5x1.5
                fi
              else
                ${pkgs.xrandr}/bin/xrandr \
                  --output ${laptop} --primary --mode ${laptopRes} --rate ${laptopHz} \
                  --output ${external} --off
              fi
              
              ${pkgs.feh}/bin/feh --bg-fill ${config.home.homeDirectory}/nixos-tuna/assets/wallpapers/sample2.jpg
              ${pkgs.betterlockscreen}/bin/betterlockscreen -u ${config.home.homeDirectory}/nixos-tuna/assets/wallpapers/sample2.jpg
            ''}
          '';
          always = true;
          notification = false;
        }
        {
          command = "fcitx5 -d";
          always = true;
          notification = false;
        }
        {
          command = "systemctl --user restart polybar";
          always = true;
          notification = false;
        }
        {
          command = "xset s 300 600";
          always = true;
          notification = false;
        }
        {
          command = "${pkgs.xss-lock}/bin/xss-lock -- betterlockscreen -l dim";
          always = true;
          notification = false;
        }
        # {
        #   command = "${pkgs.xautolock}/bin/xautolock -time 5 -locker 'betterlockscreen -l dim' -killer 'systemctl suspend' -killtime 10";
        #   always = true;
        #   notification = false;
        # }
      ];

      workspaceAutoBackAndForth = true;
      workspaceOutputAssign = [
      { workspace = "1"; output = laptop; }
      { workspace = "2"; output = laptop; }
      { workspace = "3"; output = laptop; }
      { workspace = "4"; output = laptop; }
      { workspace = "5"; output = laptop; }
      { workspace = "6"; output = external; }
      { workspace = "7"; output = external; }
      { workspace = "8"; output = external; }
      { workspace = "9"; output = external; }
      { workspace = "10"; output = external; }
    ];

      keybindings =
        let
          mod = "Mod4";
          ws1 = "1";
          ws2 = "2";
          ws3 = "3";
          ws4 = "4";
          ws5 = "5";
          ws6 = "6";
          ws7 = "7";
          ws8 = "8";
          ws9 = "9";
          ws10 = "10";
        in
        {
          "${mod}+Return" = "exec ${pkgs.kitty}/bin/kitty";
          "${mod}+Shift+t" = "reload";
          "${mod}+Shift+r" = "restart";
          "${mod}+q" = "kill";
          
          "${mod}+d" = "exec rofi -show run";    
          "${mod}+b" = "exec firefox";
          "${mod}+g" = "exec thunar";
          "${mod}+c" = "exec codium";
          "${mod}+Shift+c" = "exec codium ${config.home.homeDirectory}/nixos-tuna";

          "${mod}+l" = "exec --no-startup-id betterlockscreen -l dim";
          "${mod}+Shift+l" = "exec i3-msg exit";
          "${mod}+Escape" = "exec --no-startup-id betterlockscreen --suspend dim";
          "${mod}+Shift+Escape" = "exec --no-startup-id systemctl reboot";
          "${mod}+Control+Escape" = "exec --no-startup-id systemctl poweroff";

          "${mod}+F5" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 5%-";
          "${mod}+F6" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 5%+";
          "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 5%+";
          "XF86MonBrightnessDown" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 5%-";

          "${mod}+F1" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
          "${mod}+F3" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
          "${mod}+F2" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
          "XF86AudioMute" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
          "XF86AudioRaiseVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
          "XF86AudioLowerVolume" = "exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";

          "${mod}+Left" = "focus left";
          "${mod}+Down" = "focus down";
          "${mod}+Up" = "focus up";
          "${mod}+Right" = "focus right";

          "${mod}+Shift+Left" = "move left";
          "${mod}+Shift+Down" = "move down";
          "${mod}+Shift+Up" = "move up";
          "${mod}+Shift+Right" = "move right";

          "${mod}+1" = "workspace ${ws1}";
          "${mod}+2" = "workspace ${ws2}";
          "${mod}+3" = "workspace ${ws3}";
          "${mod}+4" = "workspace ${ws4}";
          "${mod}+5" = "workspace ${ws5}";
          "${mod}+6" = "workspace ${ws6}";
          "${mod}+7" = "workspace ${ws7}";
          "${mod}+8" = "workspace ${ws8}";
          "${mod}+9" = "workspace ${ws9}";
          "${mod}+0" = "workspace ${ws10}";

          "${mod}+Tab" = "workspace next";
          "${mod}+Shift+Tab" = "workspace prev";

          "${mod}+Shift+1" = "move container to workspace ${ws1}";
          "${mod}+Shift+2" = "move container to workspace ${ws2}";
          "${mod}+Shift+3" = "move container to workspace ${ws3}";
          "${mod}+Shift+4" = "move container to workspace ${ws4}";
          "${mod}+Shift+5" = "move container to workspace ${ws5}";
          "${mod}+Shift+6" = "move container to workspace ${ws6}";
          "${mod}+Shift+7" = "move container to workspace ${ws7}";
          "${mod}+Shift+8" = "move container to workspace ${ws8}";
          "${mod}+Shift+9" = "move container to workspace ${ws9}";
          "${mod}+Shift+0" = "move container to workspace ${ws10}";

          "${mod}+r" = "mode \"resize\"";
          "${mod}+h" = "split h";
          "${mod}+v" = "split v";
          "${mod}+f" = "fullscreen toggle";
          "${mod}+s" = "layout stacking";
          "${mod}+w" = "layout tabbed";
          "${mod}+e" = "layout toggle split";
          "${mod}+Shift+space" = "floating toggle";
          "${mod}+space" = "focus mode_toggle";
          "${mod}+a" = "focus parent";

          "${mod}+Shift+s" = ''exec ${pkgs.writeShellScript "clipSelection" ''
            ${pkgs.maim}/bin/maim -s -c 0.8,0.6,1,0.5 \
              | ${pkgs.xclip}/bin/xclip -selection clipboard -t image/png
          ''}'';
          "Print" = ''exec ${pkgs.writeShellScript "printEntireScreen" 
            "exec ${pkgs.maim}/bin/maim ${config.home.homeDirectory}/Pictures/$(${pkgs.coreutils}/bin/date +%Y-%m-%d_%H-%M-%S).png"
          }'';
          "Shift+Print" = ''exec ${pkgs.writeShellScript "clipScreen"
            "exec ${pkgs.maim}/bin/maim -i $(${pkgs.xdotool}/bin/xdotool getactivewindow) | ${pkgs.xclip}/bin/xclip -selection clipboard -t image/png"
          }'';
          "Control+Print" = ''exec ${pkgs.writeShellScript "printScreen"
            "exec ${pkgs.maim}/bin/maim -i $(${pkgs.xdotool}/bin/xdotool getactivewindow) ${config.home.homeDirectory}/Pictures/$(${pkgs.coreutils}/bin/date +%Y-%m-%d_%H-%M-%S).png"
          }'';
        };

      modes.resize = {
        "j" = "resize shrink width 10 px or 10 ppt";
        "k" = "resize grow width 10 px or 10 ppt";
        "l" = "resize shrink height 10 px or 10 ppt";
        "semicolon" = "resize grow height 10 px or 10 ppt";
        "Left" = "resize shrink width 10 px or 10 ppt";
        "Right" = "resize grow width 10 px or 10 ppt";
        "Down" = "resize shrink height 10 px or 10 ppt";
        "Up" = "resize grow height 10 px or 10 ppt";

        "Return" = "mode \"default\"";
        "Escape" = "mode \"default\"";
      };
    };
  };

  services.betterlockscreen = {
    enable = true;
    inactiveInterval = 15;
    arguments = [ "dim" ];
  };

  systemd.user.services.betterlockscreen-cache = {
    Unit = {
      Description = "Cache betterlockscreen wallpaper";
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.betterlockscreen}/bin/betterlockscreen -u ${config.home.homeDirectory}/nixos-tuna/assets/wallpapers/sample2.jpg";
      RemainAfterExit = true;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  services.polybar = {
    enable = true;
    package = pkgs.polybar.override {
      i3Support = true;
      alsaSupport = true;
      pulseSupport = true;
    };

    script = ''
      for m in $(${pkgs.xrandr}/bin/xrandr --query | ${pkgs.gnugrep}/bin/grep " connected" | ${pkgs.coreutils}/bin/cut -d" " -f1); do
        MONITOR=$m polybar main &
      done
    '';

    config = {
      "colors" = {
        background = "#1E1E2E";
        background-alt = "#313244";
        foreground = "#CDD6F4";
        primary = "#F9E2AF";
        secondary = "#89B4FA";
        alert = "#F38BA8";
        disabled = "#7F849C";
      };

      "bar/main" = {
        monitor = "\${env:MONITOR:}";

        border-top = 20;
        border-bottom = 0;
        border-left = 20;
        border-right = 20;
        border-color = "#00000000";

        height = "42pt";
        radius = 10;
        spacing = 1;
        padding-left = 0;
        padding-right = 1;
        module-margin = 1;
        line-size = "3pt";
        separator = "|";
        separator-foreground = "\${colors.disabled}";
        cursor-click = "pointer";
        cursor-scroll = "ns-resize";
        enable-ipc = true;

        background = "\${colors.background}";
        foreground = "\${colors.foreground}";

        modules-left = "systray xworkspaces xwindow";
        modules-right = "pulseaudio backlight filesystem memory cpu wlan battery date";

        font-0 = "JetBrainsMono Nerd Font:size=20;4";
      };

      "module/systray" = {
        type = "internal/tray";
        format-margin = "8pt";
        tray-spacing = "16pt";
      };

      "module/xworkspaces" = {
        type = "internal/xworkspaces";

        label-active = "%name%";
        label-active-background = "\${colors.background-alt}";
        label-active-underline = "\${colors.primary}";
        label-active-padding = 1;

        label-occupied = "%name%";
        label-occupied-padding = 1;

        label-urgent = "%name%";
        label-urgent-background = "\${colors.alert}";
        label-urgent-padding = 1;

        label-empty = "%name%";
        label-empty-foreground = "\${colors.disabled}";
        label-empty-padding = 1;
      };

      "module/xwindow" = {
        type = "internal/xwindow";
        label = "%title:0:60:...%";
        label-maxlen = 42;
      };

      "module/pulseaudio" = {
        type = "internal/pulseaudio";
        format-volume-prefix = "VOL ";
        format-volume-prefix-foreground = "\${colors.primary}";
        format-volume = "<label-volume>";

        label-volume = "%percentage%%";
        label-muted = "muted";
        label-muted-foreground = "\${colors.disabled}";
      };

      "module/backlight" = {
        type = "internal/backlight";
        card = "nvidia_0";
        format = "%{F#F9E2AF}BRI%{F-} <label>";
        label = "%percentage%%";
      };

      "module/xkeyboard" = {
        type = "internal/xkeyboard";
        blacklist-0 = "num lock";

        label-layout = "%layout%";
        label-layout-foreground = "\${colors.primary}";

        label-indicator-padding = 2;
        label-indicator-margin = 1;
        label-indicator-foreground = "\${colors.background}";
        label-indicator-background = "\${colors.secondary}";
      };

      "module/filesystem" = {
        type = "internal/fs";
        interval = 25;

        mount-0 = "/";
        label-mounted = "%{F#F9E2AF}%mountpoint%%{F-} %percentage_used%%";
        label-unmounted = "%mountpoint% not mounted";
        label-unmounted-forground = "\${colors.disabled}";
      };

      "module/memory" = {
        type = "internal/memory";
        interval = 2;
        format-prefix = "RAM ";
        format-prefix-foreground = "\${colors.primary}";
        label = "%percentage_used:2%%";
      };

      "module/cpu" = {
        type = "internal/cpu";
        interval = 2;
        format-prefix = "CPU ";
        format-prefix-foreground = "\${colors.primary}";
        label = "%percentage:2%%";
      };

      "module/battery" = {
        type = "internal/battery";
        battery = "BAT0";
        adapter = "AAC";
        full-at = 98;
        format-charging = "<label-charging>";
        format-discharging = "<label-discharging>";
      };

      "module/wlan" = {
        type = "internal/network";
        interval = 2;
        interface-type = "wireless";
        format-connected = "<label-connected>";
        format-disconnected = "<label-disconnected>";
        label-connected = "%essid%";
        label-disconnected = "disconnected";
        # label-connected = "%{F#F9E2AF}%ifname%%{F-} %essid% %local_ip%";
        # label-disconnected = "%{F#F9E2AF}%ifname%%{F#7F849C} disconnected";
      };

      "module/date" = {
        type = "internal/date";
        interval = 1;
        date = "%H:%M";
        date-alt = "%Y-%m-%d %H:%M:%S";
        label = "%date%";
        lavel-foreground = "\${colors.primary}";
      };

      "settings" = {
        screenchange-reload = true;
        psuedo-transparency = true;
      };
    };
  };

  services.picom = {
    enable = true;
    backend = "glx";
    vSync = true;

    settings = {
      corner-radius = 16;
      rounded-corners-exclude = [
        "window_type = 'dock'"
        "window_type = 'desktop'"
      ];

      shadow = true;
      shadow-radius = 16;
      shadow-opacity = 0.2;
      shadow-exclude = [
        "class_g = 'Polybar'"
        "class_g = 'Rofi'"
      ];

      opacity-rule = [
        "95:class_g = 'Polybar'"
        "95:class_g = 'Rofi'"
      ];
    };
  };

  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "lavender";
    fcitx5.enable = true;
    fcitx5.apply = true;
    # vscode.profiles.default.enable = false;
  };

  programs.kitty = {
    enable = true;

    settings = {
      font_family = "JetBrainsMono Nerd Font";
      font_size = "12.0";
      window_padding_width = 10;
      background_opacity = "0.95";
      confirm_os_window_close = 0;
    };
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting ""
    '';
  };

  programs.git = {
    package = pkgs.git;
    enable = true;
    lfs.enable = true;

    signing = {
      key = "658DA341744E3719";
      format = "openpgp";
      signByDefault = true;
    };

    settings = {
      user.name = "thewaxmango";
      user.email = "thewaxmango@gmail.com";
      github.user = "thewaxmango";

      init.defaultBranch = "main";
      pull.rebase = true;

      alias = {
        s = "status";
        d = "diff";
        co = "checkout";
        c = "commit";
        r = "rebase";
        p = "push";
        l = "log";
        ll = "log --oneline --graph --decorate";
      };

      url = {
        "git@github.com:" = {
          insteadOf = [
            "gh:"
            "github:"
          ];
        };
        "https://gitlab.com/" = {
          insteadOf = [
            "gl:"
            "gitlab:"
          ];
        };
      };
    };
  };

  programs.lazyvim = {
    enable = true;
    installCoreDependencies = true;

    extras = {
      lang = {
        nix.enable = true;
      };
    };

    extraPackages = with pkgs; [
      nixd
      statix
      nil
      alejandra
    ];
  };
  
  programs.rofi = let 
    colors = {
      bg = "#1E1E2E";
      fg = "#CDD6F4";
      accent = "#F9E2AF";
      surface = "#313244";
    };
  in {
    enable = true;
    package = pkgs.rofi;
    font = "JetBrainsMono Nerd Font 20";
    theme = let
      inherit (config.lib.formats.rasi) mkLiteral;
    in {
      "*" = {
        background-color = mkLiteral "transparent";
        text-color = mkLiteral colors.fg;
        margin = 0;
        padding = 0;
        spacing = 0;
      };

      "window" = {
        location = mkLiteral "north";
        width = mkLiteral "100%";
        height = mkLiteral "76px";
        margin = mkLiteral "20px 20px 0px 20px";
        background-color = mkLiteral colors.bg;
        border = mkLiteral "0px";
        border-radius = mkLiteral "10px";
        children = mkLiteral "[ mainbox ]";
      };

      "mainbox" = {
        orientation = mkLiteral "horizontal";
        children = mkLiteral "[ prompt, entry, listview ]";
      };

      "prompt" = {
        background-color = mkLiteral colors.accent;
        text-color = mkLiteral colors.bg;
        margin = mkLiteral "0px 7px 0px 0px";
        padding = mkLiteral "5px 5px";
        border-radius = mkLiteral "6px";
        vertical-align = mkLiteral "0.5";
      };

      "entry" = {
        placeholder = "Search...";
        width = mkLiteral "15%";
        padding = mkLiteral "0px 5px";
        vertical-align = mkLiteral "0.5";
        expand = false;
      };

      "listview" = {
        layout = mkLiteral "horizontal";
        spacing = mkLiteral "7px";
        padding = mkLiteral "5px";
        border = mkLiteral "0px";
        vertical-align = mkLiteral "0.5";
        lines = 100;
        fixed-height = true;
      };

      "element" = {
        padding = mkLiteral "0px 5px";
        vertical-align = mkLiteral "0.5";
        background-color = mkLiteral "transparent";
      };

      "element-text" = {
        text-color = mkLiteral "inherit";
      };

      "element selected" = {
        background-color = mkLiteral colors.accent;
        text-color = mkLiteral colors.bg;
        border-radius = mkLiteral "6px";
      };
    };
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        ms-python.python
        ms-python.debugpy
        ms-pyright.pyright
        james-yu.latex-workshop
        # vscodevim.vim
        myriad-dreamin.tinymist
        # dafny-lang.ide-vscode
        haskell.haskell
        justusadam.language-haskell
      ];
      userSettings = {
        "editor.fontFamily" = "'JetBrainsMono Nerd Font', 'monospace', monospace";
        "editor.fontLigatures" = false;
        "editor.fontSize" = 14;
        "editor.minimap.enabled" = false;
        "terminal.integrated.fontFamily" = "JetBrainsMono Nerd Font";

        "python.analysis.typeCheckingMode" = "strict";

        # "vim.useSystemClipboard" = true;
        # "vim.hlsearch" = true;
        # "vim.easymotion" = true;
        # "vim.incsearch" = true;
        # "vim.cursorStylePerMode.insert" = "line";
        # "vim.cursorStylePerMode.normal" = "block";
        # "vim.leader" = "<space>";

        "workbench.colorTheme" = "Catppuccin Mocha";
        "workbench.iconTheme" = "catppuccin-mocha";
        "catppuccin.accentColor" = "lavender";

        "tinymist.formatterMode" = "typstyle";
        "[typst]" = {
          "editor.defaultFormatter" = "myriad-dreamin.tinymist";
          "editor.formatOnSave" = true;
        };

        "latex-workshop.latex.outDir" = "%DIR%/.temp";
        "latex-workshop.latex.clean.subFolder.enabled" = true;
        "latex-workshop.view.pdf.viewer" = "tab";

        "dafny.dafnyPath" = "/run/current-system/sw/bin/dafny";
      };
    };
  };
}
