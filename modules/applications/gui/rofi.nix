{config, lib, pkgs, ...}:
  with lib;
let
  cfg = config.host.home.applications.rofi;
  displayServer = config.host.home.feature.gui.displayServer ;
in
{
  options = {
    host.home.applications.rofi = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Launcher";
      };
    };
  };

  config = mkIf cfg.enable {
    programs.rofi = {
      enable = true;
      plugins = with pkgs; [
        rofi-emoji
        rofi-calc
      ];
      terminal = "${pkgs.kitty}/bin/kitty";
#      extraConfig = {
#        combi-modi = "run,drun";
#        cycle = true;
#        disable-history = false;
#        display-Network = " 󰤨  Network";
#        display-drun = "   Apps ";
#        display-run = "   Run ";
#        display-window = " 﩯  window";
#        drun-display-format = "{icon} {name}";
#        font = "Noto Sans 12";
#        hide-scrollbar = true;
#        icon-theme = "Papirus";
#        lines = 6;
#        modi = "window,drun,run,combi";
#        show-icons = true;
#        sidebar-mode = true;
#        sort = true;
#        ssh-client =  "ssh";
#      };
      theme = "~/.config/rofi/theme.rasi";
    };

    wayland.windowManager.hyprland = mkIf (config.host.home.feature.gui.displayServer == "wayland" && config.host.home.feature.gui.windowManager == "hyprland" && config.host.home.feature.gui.enable) {
      settings = {
        bind = [
          "SUPER, R, exec, pkill rofi || ${config.programs.rofi.package}/bin/rofi -show run -config '~/.config/rofi/styles/style.rasi' -run-shell-command '${pkgs.kitty}/bin/kitty' "
          "SUPER, D, exec, pkill rofi || ${config.programs.rofi.package}/bin/rofi -show drun -config '~/.config/rofi/styles/style.rasi'"
          #"SUPER, D, exec, pkill rofi || ${config.programs.rofi.package}/bin/rofi -combi-modi window,drun,ssh,run -show combi -show-icons"
          "SUPER_SHIFT, V, exec, ${pkgs.cliphist}'/bin/cliphist list | ${config.programs.rofi.package}/bin/rofi -dmenu | ${pkgs.cliphist}'/bin/cliphist decode | wl-copy"
        ];
        windowrulev2 = [
          #"stayfocused,class:(Rofi)"
          #"forceinput,class:(Rofi)"
        ];
      };
    };
    xdg.configFile."rofi/theme.rasi".text = ''
          * {
              main-bg:            #11111be6;
              main-fg:            #cdd6f4ff;
              main-br:            #cba6f7ff;
              main-ex:            #f5e0dcff;
              select-bg:          #b4befeff;
              select-fg:          #11111bff;
              separatorcolor:     transparent;
              border-color:       transparent;
          }
        '';

    xdg.configFile."rofi/styles/style.rasi".text = ''
      // Config //
      configuration {
          modi:                        "drun,filebrowser,window,run";
          show-icons:                  true;
          display-drun:                " ";
          display-run:                 " ";
          display-filebrowser:         " ";
          display-window:              " ";
          drun-display-format:         "{name}";
          window-format:               "{w}{t}";
          font:                        "JetBrainsMono Nerd Font 10";
          icon-theme:                  "Tela-circle-dracula";
      }

      @theme "~/.config/rofi/theme.rasi"

      // Main //
      window {
          height:                      30em;
          width:                       37em;
          transparency:                "real";
          fullscreen:                  false;
          enabled:                     true;
          cursor:                      "default";
          spacing:                     0em;
          padding:                     0em;
          border-color:                @main-br;
          background-color:            @main-bg;
      }
      mainbox {
          enabled:                     true;
          spacing:                     0em;
          padding:                     0em;
          orientation:                 vertical;
          children:                    [ "inputbar" , "dummybox" ];
          background-color:            transparent;
      }
      dummybox {
          padding:                     0.5em;
          spacing:                     0em;
          orientation:                 horizontal;
          children:                    [ "mode-switcher" , "listbox" ];
          background-color:            transparent;
          background-image:            transparent;
      }


      // Inputs //
      inputbar {
          enabled:                     false;
      }


      // Lists //
      listbox {
          padding:                     0em;
          spacing:                     0em;
          children:                    [ "dummy" , "listview" , "dummy" ];
          background-color:            transparent;
          background-image:            transparent;
      }
      listview {
          padding:                     1em;
          spacing:                     0em;
          enabled:                     true;
          columns:                     1;
          lines:                       7;
          cycle:                       true;
          dynamic:                     true;
          scrollbar:                   false;
          layout:                      vertical;
          reverse:                     false;
          expand:                      false;
          fixed-height:                true;
          fixed-columns:               true;
          cursor:                      "default";
          background-color:            @main-bg;
          text-color:                  @main-fg;
          border-radius:               1.5em;
      }
      dummy {
          background-color:            transparent;
      }


      // Modes //
      mode-switcher {
          orientation:                 vertical;
          width:                       6.8em;
          enabled:                     true;
          padding:                     3.2em 1em 3.2em 1em;
          spacing:                     1em;
          background-color:            transparent;
      }
      button {
          cursor:                      pointer;
          border-radius:               3em;
          background-color:            @main-bg;
          text-color:                  @main-fg;
      }
      button selected {
          background-color:            @main-fg;
          text-color:                  @main-bg;
      }


      // Elements //
      element {
          enabled:                     true;
          spacing:                     1em;
          padding:                     0.4em;
          cursor:                      pointer;
          background-color:            transparent;
          text-color:                  @main-fg;
      }
      element selected.normal {
          background-color:            @select-bg;
          text-color:                  @select-fg;
      }
      element-icon {
          size:                        3em;
          cursor:                      inherit;
          background-color:            transparent;
          text-color:                  inherit;
      }
      element-text {
          vertical-align:              0.5;
          horizontal-align:            0.0;
          cursor:                      inherit;
          background-color:            transparent;
          text-color:                  inherit;
      }

      // Error message //
      error-message {
          text-color:                  @main-fg;
          background-color:            @main-bg;
          text-transform:              capitalize;
          children:                    [ "textbox" ];
      }

      textbox {
          text-color:                  inherit;
          background-color:            inherit;
          vertical-align:              0.5;
          horizontal-align:            0.5;
      }
    '';

    xdg.configFile."rofi/quickapps.rasi".text = ''
      // Config //
      configuration {
          modi:                        "drun";
          show-icons:                  true;
      }

      @theme "~/.config/rofi/theme.rasi"


      // Main //
      window {
          transparency:                "real";
          fullscreen:                  false;
          enabled:                     true;
          cursor:                      "default";
          spacing:                     0em;
          padding:                     0em;
          background-color:            @main-bg;
      }
      mainbox {
          enabled:                     true;
          spacing:                     0em;
          padding:                     0em;
          orientation:                 horizontal;
          children:                    [ "listbox" ];
          background-color:            transparent;
      }


      // Lists //
      listbox {
          padding:                     0em;
          spacing:                     0em;
          orientation:                 horizontal;
          children:                    [ "listview" ];
          background-color:            transparent;
      }
      listview {
          padding:                     2px;
          spacing:                     0em;
          enabled:                     true;
          columns:                     1;
          cycle:                       true;
          dynamic:                     true;
          scrollbar:                   false;
          flow:                        horizontal;
          reverse:                     false;
          fixed-height:                false;
          fixed-columns:               false;
          cursor:                      "default";
          background-color:            transparent;
      }


      // Elements //
      element {
          orientation:                 vertical;
          enabled:                     true;
          spacing:                     0em;
          padding:                     0em;
          cursor:                      pointer;
          background-color:            transparent;
      }
      element selected.normal {
          background-color:            @main-fg;
      }
      element-icon {
          cursor:                      inherit;
          background-color:            transparent;
      }
      element-text {
          enabled:                     false;
      }
    '';

    xdg.configFile."rofi/clipboard.rasi".text = ''
          // Config //
          configuration {
              modi:                        "drun";
              show-icons:                  false;
          }

          @theme "~/.config/rofi/theme.rasi"


          // Main //
          window {
              width:                       23em;
              height:                      30em;
              transparency:                "real";
              fullscreen:                  false;
              enabled:                     true;
              cursor:                      "default";
              spacing:                     0em;
              padding:                     0em;
              border-color:                @main-br;
              background-color:            @main-bg;
          }
          mainbox {
              enabled:                     true;
              spacing:                     0em;
              padding:                     0.5em;
              orientation:                 vertical;
              children:                    [ "wallbox" , "listbox" ];
              background-color:            transparent;
          }
          wallbox {
              spacing:                     0em;
              padding:                     0em;
              expand:                      false;
              orientation:                 horizontal;
              background-color:            transparent;
              children:                    [ "wallframe" , "inputbar" ];
          }
          wallframe {
              width:                       5em;
              spacing:                     0em;
              padding:                     0em;
              expand:                      false;
              background-color:            @main-bg;
              background-image:            url("~/.cache/hyde/wall.quad", width);
          }


          // Inputs //
          inputbar {
              enabled:                     true;
              padding:                     0em;
              children:                    [ "entry" ];
              background-color:            @main-bg;
              expand:                      true;
          }
          entry {
              enabled:                     true;
              padding:                     1.8em;
              text-color:                  @main-fg;
              background-color:            transparent;
          }


          // Lists //
          listbox {
              spacing:                     0em;
              padding:                     0em;
              orientation:                 vertical;
              children:                    [ "dummy" , "listview" , "dummy" ];
              background-color:            transparent;
          }
          listview {
              enabled:                     true;
              padding:                     0.5em;
              columns:                     1;
              lines:                       11;
              cycle:                       true;
              fixed-height:                true;
              fixed-columns:               false;
              expand:                      false;
              cursor:                      "default";
              background-color:            transparent;
              text-color:                  @main-fg;
          }
          dummy {
              spacing:                     0em;
              padding:                     0em;
              background-color:            transparent;
          }


          // Elements //
          element {
              enabled:                     true;
              padding:                     0.5em;
              cursor:                      pointer;
              background-color:            transparent;
              text-color:                  @main-fg;
          }
          element selected.normal {
              background-color:            @select-bg;
              text-color:                  @select-fg;
          }
          element-text {
              vertical-align:              0.0;
              horizontal-align:            0.0;
              cursor:                      inherit;
              background-color:            transparent;
              text-color:                  inherit;
          }
      '';

  };
}
