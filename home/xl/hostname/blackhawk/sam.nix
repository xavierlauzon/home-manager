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
            proton = {
              enable = true;
            };
            git = {
              token.enable = true;
            };
            ssh = {
              xl.enable = true;
              sampc.enable = true;
              lumae.enable = true;
            };
          };
        };
      };
      service = {
        # Proton Mail Bridge: headless IMAP/SMTP sidecar so Hermes can reach
        # the Proton mailbox (Proton has no third-party API; Bridge decrypts
        # locally). The MCP server below talks IMAP/SMTP to it.
        protonmail-bridge.enable = true;
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
      # The Lauzon gateway models are pinned at a 1M context window, so the
      # default 0.50 compaction threshold (compact at 500k) is far too eager.
      # Raise it to 0.90 so we compact at 900k, leaving a safety margin for
      # tokenizer drift between the client and provider.
      compression:
        enabled: true
        threshold: 0.90
        target_ratio: 0.20
      mcp_servers:
        # Shared knowledge-graph memory (same JSONL file as OpenCode, git-versioned).
        memory:
          command: "${pkgs.mcp-server-memory}/bin/mcp-server-memory"
          env:
            MEMORY_FILE_PATH: "${config.home.homeDirectory}/src/kb/memory.jsonl"
        # Real NixOS / Home Manager / nix docs lookup.
        nixos:
          command: "${pkgs.mcp-nixos}/bin/mcp-nixos"
          # Proton Mail via Proton Bridge (read/search/send). Credentials come
          # from sops-decrypted files; the Bridge password is NOT the Proton
          # account password. PROTONMAIL_MODE=assisted keeps the send gate on;
          # tighten to "drafts" to make the agent prepare drafts only.
          proton:
            command: "${pkgs.proton-mail-bridge-client}/bin/proton-mail-bridge-mcp"
            env:
              PROTONMAIL_USERNAME_FILE: "${config.home.homeDirectory}/.config/proton/username"
              PROTONMAIL_PASSWORD_FILE: "${config.home.homeDirectory}/.config/proton/password"
              PROTONMAIL_IMAP_HOST: "127.0.0.1"
              PROTONMAIL_IMAP_PORT: "1143"
              PROTONMAIL_IMAP_SECURE: "false"
              PROTONMAIL_SMTP_HOST: "127.0.0.1"
              PROTONMAIL_SMTP_PORT: "1025"
              PROTONMAIL_SMTP_SECURE: "false"
              # Bridge's cert is self-signed by its own CA; skip verification on
              # loopback rather than trust it.
              PROTONMAIL_TLS_INSECURE_HOSTS: "127.0.0.1"
              PROTONMAIL_MODE: "assisted"
              PROTONMAIL_TOOL_TIER: "core"
            timeout: 180
          # Komodo container/deploy MCP (same local server + sops creds as
          # OpenCode). The komodoMcpWrapper injects ~/.config/komodo/mcp.env
          # into the process env before launch (credentials stay unset if the
          # secret isn't present).
          komodo:
            command: "${komodoMcpWrapper}/bin/komodo-mcp-server"
            env:
              MCP_TRANSPORT: "stdio"
              KOMODO_URL: "https://k.lauzon.xyz"
          # Web scraping/search via the Lauzon Firecrawl gateway.
          firecrawl:
            command: "${pkgs.firecrawl-mcp}/bin/firecrawl-mcp"
            env:
              FIRECRAWL_API_URL: "https://crawl.lauzon.xyz"
              FIRECRAWL_NO_ENDPOINT_FEEDBACK: "1"
              FIRECRAWL_NO_SEARCH_FEEDBACK: "1"
          # Playwright browser automation (headless Chromium, system binary).
          # Browser options live in ~/.config/opencode/playwright-mcp.json.
          playwright:
            command: "${pkgs.nodejs_22}/bin/node"
            args: [
              "/home/sam/.npm-global/lib/node_modules/@playwright/mcp/cli.js"
              "--config"
              "/home/sam/.config/opencode/playwright-mcp.json"
            ]
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

  # Sam's DMS (dank-material-shell) settings, nix-managed so they survive clean
  # rebuilds. Snapshot of ~/.config/DankMaterialShell/settings.json. NOTE:
  # nix-managing this makes the file read-only, so DMS UI setting changes won't
  # persist — edit ./dms-settings.json and rebuild instead. `osdMediaVolumeEnabled
  # = false` suppresses the volume OSD that tidal-hifi re-emits on every track
  # change. Scoped to sam@blackhawk (xavier shares the host but keeps his own
  # DMS config).
  programs.dank-material-shell.settings = builtins.fromJSON (builtins.readFile ./dms-settings.json);
  # The runtime file exists as a plain file (from DMS's own runtime writes); nix
  # now manages it, so force the read-only store symlink to take over. Content is
  # identical to ./dms-settings.json (verified), so nothing is lost.
  xdg.configFile."DankMaterialShell/settings.json".force = true;
}
