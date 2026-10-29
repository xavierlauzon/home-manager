{ config, lib, ... }:
let
  displayServer = config.host.home.feature.gui.displayServer ;
  windowManager = config.host.home.feature.gui.windowManager ;
  lua = lib.generators.mkLuaInline;
in
with lib;
{
  config = mkIf (config.host.home.feature.gui.enable && displayServer == "wayland" && windowManager == "hyprland") {
    wayland.windowManager.hyprland = {
      settings = {
        ## See more in modules/applications/* and modules/desktop/utils/*
        bind = [
          { _args = [ "SUPER + F" (lua "hl.dsp.window.fullscreen({ action = \"toggle\" })") (lua "{ description = \"Fullscreen\" }") ]; }
          # Pin dispatcher, make window appear above everything else on all windows
          { _args = [ "SUPER + P" (lua "hl.dsp.window.pin({ action = \"toggle\" })") (lua "{ description = \"Pin Window\" }") ]; }
          { _args = [ "SUPER + RETURN" (lua "hl.dsp.exec_cmd(\"kitty\")") (lua "{ description = \"Open Terminal\" }") ]; }
          { _args = [ "SUPER + V" (lua "hl.dsp.window.float({ action = \"toggle\" })") (lua "{ description = \"Float Window\" }") ]; }
          # Middle Mouse
          { _args = [ "SUPER + mouse:274" (lua "hl.dsp.window.close()") (lua "{ description = \"Close Window (Middle Click)\" }") ]; }
          { _args = [ "SUPER + SPACE" (lua "hl.dsp.layout(\"swapwithmaster\")") (lua "{ description = \"Swap Master\" }") ]; }
          # MB5
          { _args = [ "SUPER + mouse:276" (lua "hl.dsp.layout(\"addmaster\")") (lua "{ description = \"Add Master (Mouse)\" }") ]; }
          # MB4
          { _args = [ "SUPER + mouse:275" (lua "hl.dsp.layout(\"removemaster\")") (lua "{ description = \"Remove Master (Mouse)\" }") ]; }

          { _args = [ "SUPER + SHIFT + Q" (lua "hl.dsp.window.close()") (lua "{ description = \"Close Window\" }") ]; }
          { _args = [ "ALT + TAB" (lua "hl.dsp.window.bring_to_top()") (lua "{ description = \"Bring Window to Top\" }") ]; }
          { _args = [ "ALT + TAB" (lua "hl.dsp.window.cycle_next({ next = true })") (lua "{ description = \"Cycle Windows\" }") ]; }

          # Move focus with mainMod + arrow keys
          { _args = [ "SUPER + left" (lua "hl.dsp.focus({ direction = \"left\" })") (lua "{ description = \"Focus Left\" }") ]; }
          { _args = [ "SUPER + right" (lua "hl.dsp.focus({ direction = \"right\" })") (lua "{ description = \"Focus Right\" }") ]; }
          { _args = [ "SUPER + up" (lua "hl.dsp.focus({ direction = \"up\" })") (lua "{ description = \"Focus Up\" }") ]; }
          { _args = [ "SUPER + down" (lua "hl.dsp.focus({ direction = \"down\" })") (lua "{ description = \"Focus Down\" }") ]; }

          # Switch/move workspaces are handled per-monitor by split-monitor-workspaces
          # (see ./split-workspaces.nix) -- they are NOT global IDs anymore.
          { _args = [ "SUPER + SHIFT + left" (lua "hl.dsp.window.move({ direction = \"left\" })") (lua "{ description = \"Move Window Left\" }") ]; }
          { _args = [ "SUPER + SHIFT + right" (lua "hl.dsp.window.move({ direction = \"right\" })") (lua "{ description = \"Move Window Right\" }") ]; }
          { _args = [ "SUPER + SHIFT + up" (lua "hl.dsp.window.move({ direction = \"up\" })") (lua "{ description = \"Move Window Up\" }") ]; }
          { _args = [ "SUPER + SHIFT + down" (lua "hl.dsp.window.move({ direction = \"down\" })") (lua "{ description = \"Move Window Down\" }") ]; }

          # (workspace cycling via scroll is handled in ./split-workspaces.nix)

          # Repeating resize (binde)
          { _args = [ "SUPER + CTRL + left" (lua "hl.dsp.window.resize({ x = -20, y = 0 })") (lua "{ repeating = true, description = \"Resize Left\" }") ]; }
          { _args = [ "SUPER + CTRL + right" (lua "hl.dsp.window.resize({ x = 20, y = 0 })") (lua "{ repeating = true, description = \"Resize Right\" }") ]; }
          { _args = [ "SUPER + CTRL + up" (lua "hl.dsp.window.resize({ x = 0, y = -20 })") (lua "{ repeating = true, description = \"Resize Up\" }") ]; }
          { _args = [ "SUPER + CTRL + down" (lua "hl.dsp.window.resize({ x = 0, y = 20 })") (lua "{ repeating = true, description = \"Resize Down\" }") ]; }

          # Move/resize windows with mainMod + LMB/RMB and dragging (bindm)
          { _args = [ "SUPER + mouse:272" (lua "hl.dsp.window.drag()") (lua "{ mouse = true, description = \"Drag Window\" }") ]; }
          { _args = [ "SUPER + mouse:273" (lua "hl.dsp.window.resize()") (lua "{ mouse = true, description = \"Resize Window (Mouse)\" }") ]; }
        ];
      };
    };
  };
}
