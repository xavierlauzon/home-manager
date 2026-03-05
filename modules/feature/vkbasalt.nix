{config, lib, pkgs, ...}:

let
  cfg = config.host.home.feature.vkbasalt;
in
  with lib;
{
  options = {
    host.home.feature.vkbasalt = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enable vulkan post prorcessing layer";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      vkbasalt
    ];

    xdg.configFile."vkBasalt/vkBasalt.conf".text = let
      shaderPath = "${config.home.homeDirectory}/.local/share/reshade/SweetFX/Shaders/SweetFX";
      texturePath = "${config.home.homeDirectory}/.local/share/reshade/SweetFX/Textures/SweetFX";
    in ''
      # ============================================
      # vkBasalt - Arc Raiders - Phase 1
      # ============================================
      # Lift shadows, add bright-window bloom, sharpen

      toggleKey = Home
      enableOnLaunch = True

      # Effects applied left to right
      effects = liftgammagain:fakehdr:cas

      # --- Contrast Adaptive Sharpening (built-in) ---
      # Lower = sharper. 0.4 is moderate, fights any softness from FakeHDR.
      casSharpness = 0.4

      # --- ReShade FX Paths ---
      reshadeTexturePath = ${texturePath}
      reshadeIncludePath = ${shaderPath}

      # --- Shader Aliases ---
      liftgammagain = ${shaderPath}/LiftGammaGain.fx
      fakehdr = ${shaderPath}/FakeHDR.fx

      # --- Include ---
      reshadeIncludePath = ${config.home.homeDirectory}/.local/share/reshade/reshade-shaders/Shaders
    '';
  };
}
