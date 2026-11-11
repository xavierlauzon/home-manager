{
  config,
  lib,
  pkgs,
  specialArgs,
  ...
}: let
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

  # Wrapper that injects the sops-decrypted Plane MCP credentials from
  # ~/.config/plane/mcp.env (PLANE_API_KEY / PLANE_WORKSPACE_SLUG /
  # PLANE_BASE_URL) into the process env, then launches the official
  # plane-mcp-server in stdio mode via uvx. uvx is invoked by absolute store
  # path (Hermes filters the MCP subprocess env to a safe baseline, so relying
  # on PATH would break). On hosts without the secret the server still starts
  # (creds simply stay unset).
  planeMcpWrapper = pkgs.writeShellScriptBin "plane-mcp" ''
    if [ -f "$HOME/.config/plane/mcp.env" ]; then
      set -a
      . "$HOME/.config/plane/mcp.env"
      set +a
    fi
    exec ${pkgs.uv}/bin/uvx plane-mcp-server stdio
  '';

  # Super Productivity MCP (npm-installed at ~/.npm-global, same as playwright).
  # SP 19.x's local REST API requires a Bearer token; SP writes it to a 0600 file
  # under userData when the API is enabled (Settings -> Misc -> Enable local REST
  # API). This wrapper reads that token at runtime and passes it as SP_API_TOKEN,
  # so the credential never appears in config. If the API is off (no token file)
  # the server still starts; check_connection reports the missing credential.
  spMcpWrapper = pkgs.writeShellScriptBin "sp-mcp" ''
    SP_TOKEN_FILE="$HOME/.config/superProductivity/local-rest-api-token"
    if [ -f "$SP_TOKEN_FILE" ]; then
      export SP_API_TOKEN="$(cat "$SP_TOKEN_FILE")"
    fi
    exec ${pkgs.nodejs_22}/bin/node \
      /home/sam/.npm-global/lib/node_modules/super-productivity-mcp-server/dist/index.js "$@"
  '';
in
  with lib; {
    host = {
      home = {
        applications = {
          # Personal theme control panel (lives in ~/src/desktop-theme-panel).
          # Enabled on sam's workstation hosts (blackhawk, lightning).
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
              plane = {
                mcpEnv.enable = true;
              };
              proton = {
                enable = true;
              };
              git = {
                token.enable = true;
              };
              github = {
                token.enable = true;
              };
              superproductivity = {
                captureToken.enable = true;
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
              # deepseek-v4-flash on this gateway accepts image_url parts
              # (verified against /v1/chat/completions). Declaring supports_vision
              # makes Hermes attach user images natively AND lets the auxiliary
              # vision task (vision_analyze) use the main provider. Without it the
              # vision auto-chain has no backend and image recognition silently fails.
              deepseek-v4-flash:
                context_length: 1000000
                supports_vision: true
              # qwen3.8-flash-next is NOT vision-capable here: it rejects image
              # parts with HTTP 400 "decoding failed". Leave supports_vision unset.
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
          # Plane project management (self-hosted on the lumae Komodo host).
          # Credentials (PLANE_API_KEY / PLANE_WORKSPACE_SLUG / PLANE_BASE_URL)
          # come from the sops-decrypted ~/.config/plane/mcp.env via the
          # planeMcpWrapper; the server runs in stdio mode through uvx.
          plane:
            command: "${planeMcpWrapper}/bin/plane-mcp"
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
            args:
              - "/home/sam/.npm-global/lib/node_modules/@playwright/mcp/cli.js"
              - "--config"
              - "/home/sam/.config/opencode/playwright-mcp.json"
          # Super Productivity day-planning (local REST API on 127.0.0.1:3876).
          # spMcpWrapper reads the SP access token from the 0600 token file SP
          # writes when its local REST API is enabled (Settings -> Misc -> Enable
          # local REST API). Until that toggle is on, the server loads but
          # check_connection reports the missing credential.
          super-productivity:
            command: "${spMcpWrapper}/bin/sp-mcp"
            env:
              SP_API_URL: "http://127.0.0.1:3876"
            timeout: 60
          # SuperSync remote task capture MCP (sp-sync.lauzon.xyz/mcp). Adds
          # tasks to the Inbox via the sync server from any host; it can only
          # create tasks, not read or edit them. The capture token (sp_cap_...)
          # is kept in ~/.hermes/.env as MCP_SUPERPRODUCTIVITY_SYNC_API_KEY and
          # referenced via env interpolation so it never appears in the store.
          super-productivity-sync:
            url: "https://sp-sync.lauzon.xyz/mcp"
            headers:
              Authorization: "Bearer ''${MCP_SUPERPRODUCTIVITY_SYNC_API_KEY}"
      '';
    };

    # Sam's opinionated OpenCode MCP servers. These are scoped to sam's
    # workstation hosts: komodo is built from a local source path that only
    # exists on this machine, and playwright lives under sam's home. They only
    # apply when OpenCode is enabled (the universal module owns the portable MCP
    # servers).
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
        # Super Productivity day-planning (local REST API). spMcpWrapper reads
        # the SP access token from the 0600 token file at runtime.
        super-productivity = {
          command = "${spMcpWrapper}/bin/sp-mcp";
          env = {
            SP_API_URL = "http://127.0.0.1:3876";
          };
        };
      };
    };

    # SuperSync remote task capture MCP for OpenCode (declared here rather than
    # in programs.mcp because it needs oauth:false, which the opencode module's
    # transform drops for remote servers). Adds tasks to the Inbox via the sync
    # server from any host; it can only create tasks, not read or edit them.
    # The capture token is read from the sops-decrypted file at runtime via
    # {file:...}, so it never appears in the nix store or git.
    programs.opencode.settings.mcp.super-productivity-sync = {
      type = "remote";
      url = "https://sp-sync.lauzon.xyz/mcp";
      oauth = false;
      headers = {
        Authorization = "Bearer {file:/home/sam/.config/superproductivity/capture-token}";
      };
    };
  }
