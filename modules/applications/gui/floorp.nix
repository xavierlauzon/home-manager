{ config, lib, pkgs, specialArgs, ... }:

let
  inherit (specialArgs) username;
  cfg = config.host.home.applications.floorp;
in with lib; {
  options = {
    host.home.applications.floorp = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Web Browser";
      };
      service.enable = mkOption {
        default = true;
        type = with types; bool;
        description = "Auto start on user session start";
      };
      defaultApplication = {
        enable = mkOption {
          description = "MIME default application configuration";
          type = with types; bool;
          default = false;
        };
        mimeTypes = mkOption {
          description = "MIME types to be the default application for";
          type = types.listOf types.str;
          default = [
            "application/x-extension-htm"
            "application/x-extension-html"
            "application/x-extension-shtml"
            "application/x-extension-xht"
            "application/x-extension-xhtml"
            "application/xhtml+xml"
            "text/html"
            "x-scheme-handler/about"
            "x-scheme-handler/chrome"
            "x-scheme-handler/http"
            "x-scheme-handler/https"
            "x-scheme-handler/unknown"
          ];
        };
      };
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs;
        [
          stable.floorp-bin
        ];
    };

    systemd.user.services.floorp = mkIf cfg.service.enable {
      Unit = {
        Description = "Floorp web browser";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
        ConditionEnvironment = [ "WAYLAND_DISPLAY" ];
      };

      Service = {
        Type = "exec";
        ExecStart = "${pkgs.stable.floorp-bin}/bin/floorp";
        Restart = "on-failure";
        Slice = "app-graphical.slice";
        # Firefox dlopens libEGL.so.1 (libglvnd dispatcher) and needs Mesa's EGL
        # vendor registered to reach the DRI driver. NixOS's /run/opengl-driver
        # has libEGL_mesa + the vendor json but NOT the libglvnd dispatcher, so
        # either (a) the dispatcher is found via libglvnd's own lib dir, and
        # (b) EGL_VENDOR_DIR points at the vendor json. Without these, WebGL
        # fails with FEATURE_FAILURE_NO_DISPLAY / "Failed to create EGL library
        # display". (2026-11-18 lightning/floorp; see floorp-webgl-broken skill.)
        Environment =
          [
            "EGL_VENDOR_DIR=/run/opengl-driver/share/glvnd/egl_vendor.d"
            "LIBGL_DRIVERS_PATH=/run/opengl-driver/lib/dri"
            "LD_LIBRARY_PATH=${pkgs.libglvnd}/lib:/run/opengl-driver/lib"
            "MOZ_ENABLE_WAYLAND=1"
          ];
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    xdg.mimeApps.defaultApplications = mkIf cfg.defaultApplication.enable (
      lib.genAttrs cfg.defaultApplication.mimeTypes (_: "floorp.desktop")
    );
  };
}
