{config, lib, pkgs, specialArgs, ...}:

let
  # Wrapper that injects the sops-decrypted Komodo MCP credentials from
  # ~/.config/komodo/mcp.env into the process environment before launching
  # the Komodo MCP server. On hosts without the secret the server still
  # starts (credentials simply stay unset).
  komodoMcpWrapper = pkgs.writeShellScriptBin "komodo-mcp-server" ''
    if [ -f "$HOME/.config/komodo/mcp.env" ]; then
      set -a
      . "$HOME/.config/komodo/mcp.env"
      set +a
    fi
    exec ${pkgs.komodo-mcp-server}/bin/komodo-mcp-server "$@"
  '';
in
with lib;
{
  host = {
    home = {
      applications = {
        # Personal theme control panel (lives in ~/src/desktop-theme-panel).
        # Scoped to sam@blackhawk so it doesn't enable on other hosts/users.
        theme-panel.enable = true;
        # Nous Research Hermes Agent. Auth/config is done at runtime with
        # `hermes setup` (writes ~/.hermes); the package comes from the
        # numtide llm-agents flake input.
        hermes-agent.enable = true;
      };
      user = {
        sam = {
          secrets = {
            hermes = {
              env.enable = true;
            };
            komodo = {
              mcpEnv.enable = true;
            };
            ssh = {
              xl.enable = true;
              sampc.enable = true;
              lumae.enable = true;
            };
          };
        };
      };
    };
  };

  # Hermes Agent points at the Lauzon AI OpenAI-compatible gateway
  # (https://ai.lauzon.xyz/api/v1). The API key stays in the sops-encrypted
  # ~/.hermes/.env (AI_LAUZON_API_KEY); config.yaml only names the env var.
  # Context length is pinned because our model aliases aren't in models.dev.
  home.file.".hermes/config.yaml" = {
    text = ''
      providers:
        lauzon:
          api: https://ai.lauzon.xyz/api/v1
          key_env: AI_LAUZON_API_KEY
          transport: chat_completions
          default_model: deepseek-v4-flash
          models:
            deepseek-v4-flash:
              context_length: 1000000
            qwen3.8-flash-next:
              context_length: 1000000
      model:
        provider: custom:lauzon
        default: deepseek-v4-flash
      mcp_servers:
        # Shared knowledge-graph memory (same JSONL file as OpenCode).
        memory:
          command: "${pkgs.mcp-server-memory}/bin/mcp-server-memory"
          env:
            MEMORY_FILE_PATH: "${config.home.homeDirectory}/.local/share/mcp-memory/memory.jsonl"
        # Real NixOS / Home Manager / nix docs lookup.
        nixos:
          command: "${pkgs.mcp-nixos}/bin/mcp-nixos"
    '';
  };

  # Sam's opinionated OpenCode MCP servers. These are scoped to sam@blackhawk:
  # komodo is built from a local source path that only exists on this machine,
  # and playwright lives under sam's home. They only apply when OpenCode is
  # enabled (the universal module owns the portable MCP servers).
  home.packages = mkIf config.host.home.applications.opencode.enable [
    komodoMcpWrapper
  ];

  programs.mcp = mkIf config.host.home.applications.opencode.enable {
    servers = {
      komodo = {
        command = "${komodoMcpWrapper}/bin/komodo-mcp-server";
        env = {
          MCP_TRANSPORT = "stdio";
          KOMODO_URL = "https://k.lauzon.xyz";
        };
      };
      # Playwright browser automation (headless Chromium, system binary).
      # Browser options live in ~/.config/opencode/playwright-mcp.json.
      playwright = {
        command = "${pkgs.nodejs_22}/bin/node";
        args = [
          "/home/sam/.npm-global/lib/node_modules/@playwright/mcp/cli.js"
          "--config"
          "/home/sam/.config/opencode/playwright-mcp.json"
        ];
      };
    };
  };
}
