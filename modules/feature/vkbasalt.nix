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
      # vkBasalt - Arc Raiders - Phase 2
      # ============================================
      # Lift shadows, add bright-window bloom, sharpen

      toggleKey = Home
      enableOnLaunch = True

      # Effects applied in order
      effects = liftgammagain:levels:fakehdr:curves:tonemap:vibrance:cas:lumasharpen

      # --- Built-in Effects ---
      casSharpness = 0.5

      # --- ReShade FX Paths ---
      reshadeTexturePath = ${texturePath}
      reshadeIncludePath = ${shaderPath}

      # --- Shader Aliases ---
      liftgammagain = ${shaderPath}/LiftGammaGain.fx
      levels = ${shaderPath}/Levels.fx
      fakehdr = ${shaderPath}/FakeHDR.fx
      curves = ${shaderPath}/Curves.fx
      tonemap = ${shaderPath}/Tonemap.fx
      vibrance = ${shaderPath}/Vibrance.fx
      lumasharpen = ${shaderPath}/LumaSharpen.fx

      # --- Include ---
      reshadeIncludePath = ${config.home.homeDirectory}/.local/share/reshade/reshade-shaders/Shaders
    '';
  };
}
