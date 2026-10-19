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

          # Switch workspaces with mainMod + [0-9]
          { _args = [ "SUPER + 1" (lua "hl.dsp.focus({ workspace = 1 })") (lua "{ description = \"Focus Workspace 1\" }") ]; }
          { _args = [ "SUPER + 2" (lua "hl.dsp.focus({ workspace = 2 })") (lua "{ description = \"Focus Workspace 2\" }") ]; }
          { _args = [ "SUPER + 3" (lua "hl.dsp.focus({ workspace = 3 })") (lua "{ description = \"Focus Workspace 3\" }") ]; }
          { _args = [ "SUPER + 4" (lua "hl.dsp.focus({ workspace = 4 })") (lua "{ description = \"Focus Workspace 4\" }") ]; }
          { _args = [ "SUPER + 5" (lua "hl.dsp.focus({ workspace = 5 })") (lua "{ description = \"Focus Workspace 5\" }") ]; }
          { _args = [ "SUPER + 6" (lua "hl.dsp.focus({ workspace = 6 })") (lua "{ description = \"Focus Workspace 6\" }") ]; }
          { _args = [ "SUPER + 7" (lua "hl.dsp.focus({ workspace = 7 })") (lua "{ description = \"Focus Workspace 7\" }") ]; }
          { _args = [ "SUPER + 8" (lua "hl.dsp.focus({ workspace = 8 })") (lua "{ description = \"Focus Workspace 8\" }") ]; }
          { _args = [ "SUPER + 9" (lua "hl.dsp.focus({ workspace = 9 })") (lua "{ description = \"Focus Workspace 9\" }") ]; }
          { _args = [ "SUPER + 0" (lua "hl.dsp.focus({ workspace = 10 })") (lua "{ description = \"Focus Workspace 10\" }") ]; }

          # Move active window to a workspace with mainMod + SHIFT + [0-9]
          { _args = [ "SUPER + SHIFT + 1" (lua "hl.dsp.window.move({ workspace = 1 })") (lua "{ description = \"Move Window to Workspace 1\" }") ]; }
          { _args = [ "SUPER + SHIFT + 2" (lua "hl.dsp.window.move({ workspace = 2 })") (lua "{ description = \"Move Window to Workspace 2\" }") ]; }
          { _args = [ "SUPER + SHIFT + 3" (lua "hl.dsp.window.move({ workspace = 3 })") (lua "{ description = \"Move Window to Workspace 3\" }") ]; }
          { _args = [ "SUPER + SHIFT + 4" (lua "hl.dsp.window.move({ workspace = 4 })") (lua "{ description = \"Move Window to Workspace 4\" }") ]; }
          { _args = [ "SUPER + SHIFT + 5" (lua "hl.dsp.window.move({ workspace = 5 })") (lua "{ description = \"Move Window to Workspace 5\" }") ]; }
          { _args = [ "SUPER + SHIFT + 6" (lua "hl.dsp.window.move({ workspace = 6 })") (lua "{ description = \"Move Window to Workspace 6\" }") ]; }
          { _args = [ "SUPER + SHIFT + 7" (lua "hl.dsp.window.move({ workspace = 7 })") (lua "{ description = \"Move Window to Workspace 7\" }") ]; }
          { _args = [ "SUPER + SHIFT + 8" (lua "hl.dsp.window.move({ workspace = 8 })") (lua "{ description = \"Move Window to Workspace 8\" }") ]; }
          { _args = [ "SUPER + SHIFT + 9" (lua "hl.dsp.window.move({ workspace = 9 })") (lua "{ description = \"Move Window to Workspace 9\" }") ]; }
          { _args = [ "SUPER + SHIFT + 0" (lua "hl.dsp.window.move({ workspace = 10 })") (lua "{ description = \"Move Window to Workspace 10\" }") ]; }

          # moving windows to other workspaces (silent)
          { _args = [ "SUPER + ALT + 1" (lua "hl.dsp.window.move({ workspace = 1, follow = false })") (lua "{ description = \"Send Window to Workspace 1 (Silent)\" }") ]; }
          { _args = [ "SUPER + ALT + 2" (lua "hl.dsp.window.move({ workspace = 2, follow = false })") (lua "{ description = \"Send Window to Workspace 2 (Silent)\" }") ]; }
          { _args = [ "SUPER + ALT + 3" (lua "hl.dsp.window.move({ workspace = 3, follow = false })") (lua "{ description = \"Send Window to Workspace 3 (Silent)\" }") ]; }
          { _args = [ "SUPER + ALT + 4" (lua "hl.dsp.window.move({ workspace = 4, follow = false })") (lua "{ description = \"Send Window to Workspace 4 (Silent)\" }") ]; }
          { _args = [ "SUPER + ALT + 5" (lua "hl.dsp.window.move({ workspace = 5, follow = false })") (lua "{ description = \"Send Window to Workspace 5 (Silent)\" }") ]; }
          { _args = [ "SUPER + ALT + 6" (lua "hl.dsp.window.move({ workspace = 6, follow = false })") (lua "{ description = \"Send Window to Workspace 6 (Silent)\" }") ]; }
          { _args = [ "SUPER + ALT + 7" (lua "hl.dsp.window.move({ workspace = 7, follow = false })") (lua "{ description = \"Send Window to Workspace 7 (Silent)\" }") ]; }
          { _args = [ "SUPER + ALT + 8" (lua "hl.dsp.window.move({ workspace = 8, follow = false })") (lua "{ description = \"Send Window to Workspace 8 (Silent)\" }") ]; }
          { _args = [ "SUPER + ALT + 9" (lua "hl.dsp.window.move({ workspace = 9, follow = false })") (lua "{ description = \"Send Window to Workspace 9 (Silent)\" }") ]; }
          { _args = [ "SUPER + ALT + 0" (lua "hl.dsp.window.move({ workspace = 10, follow = false })") (lua "{ description = \"Send Window to Workspace 10 (Silent)\" }") ]; }

          # moving windows around
          { _args = [ "SUPER + SHIFT + left" (lua "hl.dsp.window.move({ direction = \"left\" })") (lua "{ description = \"Move Window Left\" }") ]; }
          { _args = [ "SUPER + SHIFT + right" (lua "hl.dsp.window.move({ direction = \"right\" })") (lua "{ description = \"Move Window Right\" }") ]; }
          { _args = [ "SUPER + SHIFT + up" (lua "hl.dsp.window.move({ direction = \"up\" })") (lua "{ description = \"Move Window Up\" }") ]; }
          { _args = [ "SUPER + SHIFT + down" (lua "hl.dsp.window.move({ direction = \"down\" })") (lua "{ description = \"Move Window Down\" }") ]; }

          # Scroll through existing workspaces with mainMod + scroll
          { _args = [ "SUPER + mouse_down" (lua "hl.dsp.focus({ workspace = \"e+1\" })") (lua "{ description = \"Next Workspace\" }") ]; }
          { _args = [ "SUPER + mouse_up" (lua "hl.dsp.focus({ workspace = \"e-1\" })") (lua "{ description = \"Previous Workspace\" }") ]; }

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
