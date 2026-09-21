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
          { _args = [ "SUPER + F" (lua "hl.dsp.window.fullscreen({ action = \"toggle\" })") ]; }
          # Pin dispatcher, make window appear above everything else on all windows
          { _args = [ "SUPER + P" (lua "hl.dsp.window.pin({ action = \"toggle\" })") ]; }
          { _args = [ "SUPER + RETURN" (lua "hl.dsp.exec_cmd(\"kitty\")") ]; }
          { _args = [ "SUPER + V" (lua "hl.dsp.window.float({ action = \"toggle\" })") ]; }
          # Middle Mouse
          { _args = [ "SUPER + mouse:274" (lua "hl.dsp.window.close()") ]; }
          { _args = [ "SUPER + SPACE" (lua "hl.dsp.layout(\"swapwithmaster\")") ]; }
          # MB5
          { _args = [ "SUPER + mouse:276" (lua "hl.dsp.layout(\"addmaster\")") ]; }
          # MB4
          { _args = [ "SUPER + mouse:275" (lua "hl.dsp.layout(\"removemaster\")") ]; }

          { _args = [ "SUPER + SHIFT + Q" (lua "hl.dsp.window.close()") ]; }
          { _args = [ "ALT + TAB" (lua "hl.dsp.window.bring_to_top()") ]; }
          { _args = [ "ALT + TAB" (lua "hl.dsp.window.cycle_next({ next = true })") ]; }

          # Move focus with mainMod + arrow keys
          { _args = [ "SUPER + left" (lua "hl.dsp.focus({ direction = \"left\" })") ]; }
          { _args = [ "SUPER + right" (lua "hl.dsp.focus({ direction = \"right\" })") ]; }
          { _args = [ "SUPER + up" (lua "hl.dsp.focus({ direction = \"up\" })") ]; }
          { _args = [ "SUPER + down" (lua "hl.dsp.focus({ direction = \"down\" })") ]; }

          # Switch workspaces with mainMod + [0-9]
          { _args = [ "SUPER + 1" (lua "hl.dsp.focus({ workspace = 1 })") ]; }
          { _args = [ "SUPER + 2" (lua "hl.dsp.focus({ workspace = 2 })") ]; }
          { _args = [ "SUPER + 3" (lua "hl.dsp.focus({ workspace = 3 })") ]; }
          { _args = [ "SUPER + 4" (lua "hl.dsp.focus({ workspace = 4 })") ]; }
          { _args = [ "SUPER + 5" (lua "hl.dsp.focus({ workspace = 5 })") ]; }
          { _args = [ "SUPER + 6" (lua "hl.dsp.focus({ workspace = 6 })") ]; }
          { _args = [ "SUPER + 7" (lua "hl.dsp.focus({ workspace = 7 })") ]; }
          { _args = [ "SUPER + 8" (lua "hl.dsp.focus({ workspace = 8 })") ]; }
          { _args = [ "SUPER + 9" (lua "hl.dsp.focus({ workspace = 9 })") ]; }
          { _args = [ "SUPER + 0" (lua "hl.dsp.focus({ workspace = 10 })") ]; }

          # Move active window to a workspace with mainMod + SHIFT + [0-9]
          { _args = [ "SUPER + SHIFT + 1" (lua "hl.dsp.window.move({ workspace = 1 })") ]; }
          { _args = [ "SUPER + SHIFT + 2" (lua "hl.dsp.window.move({ workspace = 2 })") ]; }
          { _args = [ "SUPER + SHIFT + 3" (lua "hl.dsp.window.move({ workspace = 3 })") ]; }
          { _args = [ "SUPER + SHIFT + 4" (lua "hl.dsp.window.move({ workspace = 4 })") ]; }
          { _args = [ "SUPER + SHIFT + 5" (lua "hl.dsp.window.move({ workspace = 5 })") ]; }
          { _args = [ "SUPER + SHIFT + 6" (lua "hl.dsp.window.move({ workspace = 6 })") ]; }
          { _args = [ "SUPER + SHIFT + 7" (lua "hl.dsp.window.move({ workspace = 7 })") ]; }
          { _args = [ "SUPER + SHIFT + 8" (lua "hl.dsp.window.move({ workspace = 8 })") ]; }
          { _args = [ "SUPER + SHIFT + 9" (lua "hl.dsp.window.move({ workspace = 9 })") ]; }
          { _args = [ "SUPER + SHIFT + 0" (lua "hl.dsp.window.move({ workspace = 10 })") ]; }

          # moving windows to other workspaces (silent)
          { _args = [ "SUPER + ALT + 1" (lua "hl.dsp.window.move({ workspace = 1, follow = false })") ]; }
          { _args = [ "SUPER + ALT + 2" (lua "hl.dsp.window.move({ workspace = 2, follow = false })") ]; }
          { _args = [ "SUPER + ALT + 3" (lua "hl.dsp.window.move({ workspace = 3, follow = false })") ]; }
          { _args = [ "SUPER + ALT + 4" (lua "hl.dsp.window.move({ workspace = 4, follow = false })") ]; }
          { _args = [ "SUPER + ALT + 5" (lua "hl.dsp.window.move({ workspace = 5, follow = false })") ]; }
          { _args = [ "SUPER + ALT + 6" (lua "hl.dsp.window.move({ workspace = 6, follow = false })") ]; }
          { _args = [ "SUPER + ALT + 7" (lua "hl.dsp.window.move({ workspace = 7, follow = false })") ]; }
          { _args = [ "SUPER + ALT + 8" (lua "hl.dsp.window.move({ workspace = 8, follow = false })") ]; }
          { _args = [ "SUPER + ALT + 9" (lua "hl.dsp.window.move({ workspace = 9, follow = false })") ]; }
          { _args = [ "SUPER + ALT + 0" (lua "hl.dsp.window.move({ workspace = 10, follow = false })") ]; }

          # moving windows around
          { _args = [ "SUPER + SHIFT + left" (lua "hl.dsp.window.move({ direction = \"left\" })") ]; }
          { _args = [ "SUPER + SHIFT + right" (lua "hl.dsp.window.move({ direction = \"right\" })") ]; }
          { _args = [ "SUPER + SHIFT + up" (lua "hl.dsp.window.move({ direction = \"up\" })") ]; }
          { _args = [ "SUPER + SHIFT + down" (lua "hl.dsp.window.move({ direction = \"down\" })") ]; }

          # Scroll through existing workspaces with mainMod + scroll
          { _args = [ "SUPER + mouse_down" (lua "hl.dsp.focus({ workspace = \"e+1\" })") ]; }
          { _args = [ "SUPER + mouse_up" (lua "hl.dsp.focus({ workspace = \"e-1\" })") ]; }

          # PTT
          #{ _args = [ "F24" (lua "hl.dsp.pass({ window = \"class:^(com\\\\.github\\\\.Vencord\\\\.Vesktop)$\" })") ]; }
          #{ _args = [ "F24" (lua "hl.dsp.pass({ window = \"class:^Vesktop\" })") ]; }
          { _args = [ "F24" (lua "hl.dsp.send_shortcut({ key = \"F24\", window = \"class:^vesktop\" })") ]; }

          # Repeating resize (binde)
          { _args = [ "SUPER + CTRL + left" (lua "hl.dsp.window.resize({ x = -20, y = 0 })") { repeating = true; } ]; }
          { _args = [ "SUPER + CTRL + right" (lua "hl.dsp.window.resize({ x = 20, y = 0 })") { repeating = true; } ]; }
          { _args = [ "SUPER + CTRL + up" (lua "hl.dsp.window.resize({ x = 0, y = -20 })") { repeating = true; } ]; }
          { _args = [ "SUPER + CTRL + down" (lua "hl.dsp.window.resize({ x = 0, y = 20 })") { repeating = true; } ]; }

          # Move/resize windows with mainMod + LMB/RMB and dragging (bindm)
          { _args = [ "SUPER + mouse:272" (lua "hl.dsp.window.drag()") { mouse = true; } ]; }
          { _args = [ "SUPER + mouse:273" (lua "hl.dsp.window.resize()") { mouse = true; } ]; }
        ];
      };
    };
  };
}
