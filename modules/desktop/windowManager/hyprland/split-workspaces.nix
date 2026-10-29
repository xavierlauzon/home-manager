{ config, inputs, lib, specialArgs, ... }:
let
  inherit (specialArgs) hostname;
  displayServer = config.host.home.feature.gui.displayServer;
  windowManager = config.host.home.feature.gui.windowManager;

  # Each monitor gets its own independent workspace track (awesome-style).
  # The plugin maps internal workspace IDs so SUPER+<N> always switches the Nth
  # workspace on the monitor under the cursor, without disturbing the other monitor.
  # First entry in monitor_priority gets the lowest workspace IDs (track 1).
  monitorPriority = {
    blackhawk = [ "HDMI-A-1" "STREAM" ];
    # xavierdesktop = [ "<primary>" "<secondary>" ];
  };

  # Only emit a monitor_priority line for hosts where we know the monitor order;
  # otherwise the plugin assigns tracks in the order Hyprland reports monitors.
  priorityLine = if builtins.hasAttr hostname monitorPriority then
    "monitor_priority = { ${lib.concatStringsSep ", " (map (m: "\"${m}\"") (builtins.getAttr hostname monitorPriority))} },"
  else
    "";
in
with lib;
{
  config = mkIf (config.host.home.feature.gui.enable && displayServer == "wayland" && windowManager == "hyprland") {
    # Ship the plugin's Lua library into the Hypr config dir so it can be require()'d.
    # The flake input is flake=false, so this is the pinned v0.56.2 source tree.
    xdg.configFile."hypr/plugins/split-monitor-workspaces/lua" = {
      source = "${inputs.split-monitor-workspaces}/lua";
      recursive = true;
    };

    wayland.windowManager.hyprland.extraConfig = ''
      -- ===== per-monitor independent workspace tracks (split-monitor-workspaces) =====
      package.path = package.path .. ";${config.home.homeDirectory}/.config/hypr/plugins/split-monitor-workspaces/lua/?.lua"
      local smw = require("split-monitor-workspaces")
      smw.setup({
        workspace_count = 10,
        ${priorityLine}
        keep_focused = true,
      })
      -- Switch to the Nth workspace on the currently focused monitor.
      -- Move active window to the Nth workspace (follow) / silently (no focus change).
      local mainMod = "SUPER"
      for i = 1, smw.get_amount_of_workspaces() do
        local n = tostring(i)
        if n == "10" then n = "0" end
        hl.bind(mainMod .. " + " .. n, smw.workspace(n), { description = "Focus Workspace " .. n })
        hl.bind(mainMod .. " + SHIFT + " .. n, smw.move_to_workspace(n), { description = "Move Window to Workspace " .. n })
        hl.bind(mainMod .. " + ALT + " .. n, smw.move_to_workspace_silent(n), { description = "Send Window to Workspace " .. n })
      end
      -- Cycle through workspaces on the current monitor with mainMod + scroll.
      hl.bind(mainMod .. " + mouse_down", smw.cycle_workspaces("next"), { description = "Next Workspace" })
      hl.bind(mainMod .. " + mouse_up", smw.cycle_workspaces("prev"), { description = "Previous Workspace" })
    '';
  };
}
