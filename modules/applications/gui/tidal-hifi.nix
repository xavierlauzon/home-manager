{config, lib, pkgs, ...}:

let
  cfg = config.host.home.applications.tidal-hifi;
  pkg = pkgs.unstable.tidal-hifi;

  # tidal-hifi <= 8.1.3 appends `no-sandbox`/`disable-seccomp-filter-sandbox`
  # from config.json at runtime, AFTER Electron has started its Linux zygote.
  # Child processes then inherit a broken sandbox state and the renderer
  # FATAL-crashes trying to allocate shared memory in /dev/shm (ESRCH),
  # leaving a blank window that never renders. Passing the flag on the real
  # command line avoids the sandboxed zygote entirely.
  # See https://github.com/Mastermindzh/tidal-hifi/pull/1007
  tidalExec = "${pkg}/bin/tidal-hifi --no-sandbox";
in
  with lib;
{
  options = {
    host.home.applications.tidal-hifi = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "HiFi music streaming service";
      };
      service.enable = mkOption {
        default = true;
        type = with types; bool;
        description = "Auto start on user session start";
      };
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs;
        [
          unstable.tidal-hifi
        ];
    };

    systemd.user.services.tidal-hifi = mkIf cfg.service.enable {
      Unit = {
        Description = "Tidal HiFi player";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
        ConditionEnvironment = [ "WAYLAND_DISPLAY" ];
      };

      Service = {
        Type = "exec";
        ExecStart = "${pkgs.unstable.tidal-hifi}/bin/tidal-hifi";
        Restart = "on-failure";
        Slice = "app-graphical.slice";
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
