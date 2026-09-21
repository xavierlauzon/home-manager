{config, lib, pkgs, ...}:

let
  cfg = config.host.home.applications.satty;
  lua = lib.generators.mkLuaInline;
in
  with lib;
{
  options = {
    host.home.applications.satty = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Screenshot annotizer";
      };
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs;
        [
          unstable.satty
        ];
    };

    wayland.windowManager.hyprland = mkIf (config.host.home.feature.gui.displayServer == "wayland" && config.host.home.feature.gui.windowManager == "hyprland" && config.host.home.feature.gui.enable) {
      settings = {
        bind = [
          { _args = [ "SUPER + Print" (lua "hl.dsp.exec_cmd(\"pkill satty || grim -g \\\"$(${pkgs.slurp}/bin/slurp)\\\" - | satty --disable-notifications -f -\")") ]; }
        ];
        window_rule = [
          { match = { class = "^(com.gabm.satty)$"; }; float = true; }
          { match = { class = "^(com.gabm.satty)$"; }; pin = true; }
        ];
      };
    };


      #actions-on-enter = [ "save-to-clipboard" "save-to-file" ]

    xdg.configFile."satty/config.toml".text = ''
      [general]
      fullscreen = false
      early-exit = true
      initial-tool = "blur" # [pointer, crop, line, arrow, rectangle, text, marker, blur, brush]
      copy-command = "wl-copy"
      output-filename = "${config.home.homeDirectory}/Nextcloud/screenshots/screenshot-%Y-%m-%d_%H:%M:%S.png"
      save-after-copy = true
      actions-on-enter = [ "save-to-file","save-to-clipboard" ]

      [font]
      family = "Roboto"
      style = "Bold"

      #[color-palette]
      #first= "#00ffff"
      #second= "#a52a2a"
      #third= "#dc143c"
      #fourth= "#ff1493"
      #fifth= "#ffd700"
      #custom= "#008000"
    '';
  };
}