{config, inputs, lib, pkgs, ...}:

let
  cfg = config.host.home.applications.opencode;

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
  options = {
    host.home.applications.opencode = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = "AI coding agent";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode-desktop
      komodoMcpWrapper
    ];

    programs.opencode = {
      enable = true;
      package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode2;
      enableMcpIntegration = true;
      # bun is used by OpenCode to auto-install npm plugins (oh-my-opencode-slim);
      # node is available for any JS MCP servers that need it at runtime.
      extraPackages = with pkgs; [
        bun
        nodejs_22
      ];
      settings = {
        model = "ai-lauzon-xyz/deepseek-v4-flash";
        tools = {
          websearch = false;
          webfetch = false;
          firecrawl_firecrawl_agent = false;
          firecrawl_firecrawl_agent_status = false;
          firecrawl_firecrawl_extract = false;
        };
        plugin = [
          "oh-my-opencode-slim"
        ];
      };
    };

    programs.mcp = {
      enable = true;
      servers = {
        firecrawl = {
          command = "${pkgs.firecrawl-mcp}/bin/firecrawl-mcp";
          env = {
            FIRECRAWL_API_URL = "https://crawl.lauzon.xyz";
            FIRECRAWL_NO_SEARCH_FEEDBACK = "1";
            FIRECRAWL_NO_ENDPOINT_FEEDBACK = "1";
          };
        };
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

    xdg.configFile = {
      # oh-my-opencode-slim preset config (brings the context7 + gh_grep MCPs)
      "opencode/oh-my-opencode-slim.json".source = ./opencode/oh-my-opencode-slim.json;
    };
  };
}
