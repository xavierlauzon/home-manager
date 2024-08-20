{config, lib, pkgs, ...}:

let
  cfg = config.host.home.applications.fastfetch;
in
  with lib;
{
  options = {
    host.home.applications.fastfetch = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "System Information Tool";
      };
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs;
        [
          fastfetch
        ];
    };
    programs.fastfetch = {
     enable = true;
     settings = {
        "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";
        logo = {
            source = "nixos";
        };
        display = {
            separator = ": ";
        };
        modules = [
          {
            type = "custom";
            format = "┌──────────────────────────────────────────┐";
          }
          {
            type = "os";
            key = "  OS"; # TODO find nixos icon
            keyColor = "red";
          }
          {
            type = "kernel";
            key = "   Kernel";
            keyColor = "red";
          }
          {
            type = "packages";
            key = "   Packages";
            keyColor = "green";
          }
          {
            type = "display";
            key = "   Display";
            keyColor = "green";
          }
          {
            type = "wm";
            key = "   WM";
            keyColor = "yellow";
          }
          {
            type = "terminal";
            key = "   Terminal";
            keyColor = "yellow";
          }
          {
            type = "custom";
            format = "└──────────────────────────────────────────┘";
          }
          "break"
          {
            type = "title";
            key = "  ";
          }
          {
            type = "custom";
            format = "┌──────────────────────────────────────────┐";
          }
          {
            type = "cpu";
            format = "{1}";
            key = "   CPU";
            keyColor = "blue";
          }
          {
            type = "gpu";
            format = "{2}";
            key = "   GPU";
            keyColor = "blue";
          }
          {
            type = "gpu";
            format = "{3}";
            key = "   GPU Driver";
            keyColor = "magenta";
          }
          {
            type = "memory";
            key = "  ﬙ Memory";
            keyColor = "magenta";
          }
          {
            type = "command";
            key = "  󱦟 OS Age ";
            keyColor = "31";
            text = "birth_install=$(stat -c %W /); current=$(date +%s); time_progression=$((current - birth_install)); days_difference=$((time_progression / 86400)); echo $days_difference days";
          }
          {
            type = "uptime";
            key = "  󱫐 Uptime ";
            keyColor = "red";
          }
          {
            type = "custom";
            format = "└──────────────────────────────────────────┘";
          }
          {
            type = "colors";
            padding = {
              left = 2;
            };
            symbol = "circle";
          }
          "break"
        ];
      };
    };
  };
}
