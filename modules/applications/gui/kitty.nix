{config, lib, nix-colours, pkgs, ...}:

let
  cfg = config.host.home.applications.kitty;
in
  with lib;
{
  options = {
    host.home.applications.kitty = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Terminal Emulator";
      };
    };
  };

  config = mkIf cfg.enable {
    programs = {
      kitty = {
        enable = true;
        package = pkgs.unstable.kitty;
        keybindings = {
          "ctrl+shift+c" = "copy_and_clear_or_interrupt";
          "ctrl+alt+enter" = "launch --location=neighbour";
          "f1" = "launch --cwd=current --type=tab";
          "f2" = "launch --cwd=current";
        };
        settings = {
          # Font
          bold_font = "auto";
          italic_font = "auto";
          bold_italic_font = "auto";
          ## Cursor
          cursor_shape = "block";
          cursor_blink_interval = -1 ;
          ## Scrollback
          scrollback_lines = 10000;
          # Auto Select from Mouse Clipboard;
          copy_on_select = "clipboard";
          strip_trailing_spaces = "smart"; # Strip Trailing spaces from Clipboard
          focus_follows_mouse = "yes";
          ## Bell;
          enable_audio_bell = "no";
          visual_bell_duration = "0.2";
          bell_on_tab  = "'🔔 '";
          # Tab;
          tab_activity_symbol = "'⚡ '";
          tab_bar_style = "powerline";
          tab_powerline_style = "round";
          tab_bar_min_tabs = 1;
          active_tab_font_style = "bold-italic";
          inactive_tab_font_style = "normal";
          confirm_os_window_close = 0;
          update_check_interval = 0 ; # Disable Updates checking
          # Performance
          repaint_delay = 9;
          input_delay = 2;
          select_by_word_characters = ":@-./_~?&=%+#" ; # Characters considered a word when double clicking
        };
        shellIntegration.enableBashIntegration = true;
      };

      bash = {
        initExtra = ''
          clone() {
              case "$1" in
                  tab)
                      clone_arg="--type tab"
                  ;;
                  title)
                      clone_arg="--title '$2'"
                  ;;
                  *)
                      clone_arg=$@
                  ;;
              esac

              clone-in-kitty $clone_arg
          }

          edit() {
              case "$2" in
                  tab)
                      edit_arg="--type tab"

                  ;;
                  title)
                      edit_arg="--title '$3'"
                  ;;
                  *)
                      edit_arg="$${@}"
                  ;;
              esac

              edit-in-kitty $edit_arg
          }

          if [ -n "$KITTY_WINDOW_ID" ]; then
              alias sssh="kitty +kitten ssh"
              alias ssh="/run/current-system/sw/bin/ssh"
          fi
        ''; # Temporarily changed shell integration as it's been fucky
      };
    };
  };
}
