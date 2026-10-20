{config, inputs, lib, pkgs, ...}:

let
  cfg = config.host.home.applications.opencode;
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

      model = mkOption {
        default = "ai-lauzon-xyz/deepseek-v4-flash";
        type = types.str;
        description = "Default model for OpenCode.";
      };

      # MCP servers that are self-contained/portable (no machine-specific
      # paths). Each can be toggled on/off per user so hosts can pick and
      # choose. Machine-specific servers (e.g. a locally-built Komodo) should
      # live in the host/user config that owns them instead of here.
      mcp = {
        firecrawl = {
          enable = mkOption {
            default = true;
            type = types.bool;
            description = "Enable the Firecrawl MCP server.";
          };
        };
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode-desktop
    ];

    # OpenCode v2 layers OPENCODE_CLI_CONFIG_CONTENT over the global cli.json on
    # every read and re-applies it after every write, so tabs stay enabled even
    # when herdr or OpenCode itself rewrites cli.json. ("auto" is hard-coded to
    # hide tabs when HERDR_ENV=1, i.e. inside herdr.)
    home.sessionVariables.OPENCODE_CLI_CONFIG_CONTENT = builtins.toJSON {
      tabs = {
        scope = "global";
        mode = "on";
      };
    };

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
        model = cfg.model;
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
        # OpenCode 2.x form for package plugins (the legacy `plugin` key is
        # deprecated). Persistent cross-session memory via opencode-codex-memory:
        # uses the models configured below (Lauzon AI gateway), no extra API keys.
        plugins = [
          {
            package = "opencode-codex-memory@0.9.11";
          }
        ];
        # Provider/model catalog for the Lauzon AI gateway. Capabilities gate
        # what media types each model may receive: qwen3.8-flash-next and
        # deepseek-v4-flash are both multimodal (text + image).
        provider = {
          "ai-lauzon-xyz" = {
            name = "Lauzon AI";
            npm = "@ai-sdk/openai-compatible";
            options = {
              baseURL = "https://ai.lauzon.xyz/api";
              timeout = 12000000;
            };
            models = {
              "deepseek-v4-flash" = {
                name = "Deepseek V4 Flash Local";
                capabilities = {
                  tools = true;
                  input = [ "text" "image" ];
                  output = [ "text" ];
                };
                limit = {
                  context = 1000000;
                  output = 384000;
                };
              };
              "qwen3.6-27b" = {
                name = "Qwen 3.6 27B";
              };
              "qwen3.6-35b" = {
                name = "Qwen 3.6 35B";
              };
              "qwen3.8-flash-next" = {
                name = "Qwen 3.8 Flash Next";
                capabilities = {
                  tools = true;
                  input = [ "text" "image" ];
                  output = [ "text" ];
                };
                limit = {
                  context = 1000000;
                  output = 384000;
                };
              };
            };
          };
        };
      };
    };

    programs.mcp = {
      enable = true;
      servers = {}
        // optionalAttrs cfg.mcp.firecrawl.enable {
          firecrawl = {
            command = "${pkgs.firecrawl-mcp}/bin/firecrawl-mcp";
            env = {
              FIRECRAWL_API_URL = "https://crawl.lauzon.xyz";
              FIRECRAWL_NO_SEARCH_FEEDBACK = "1";
              FIRECRAWL_NO_ENDPOINT_FEEDBACK = "1";
            };
          };
        }
        # Hermes messaging bridge (list/read/send conversations across Hermes'
        # connected platforms). Only wired when Hermes Agent is enabled; the
        # hermes-mcp wrapper loads the mcp-version shim for the Nix build.
        // optionalAttrs config.host.home.applications.hermes-agent.enable {
          hermes = {
            command = "${config.home.profileDirectory}/bin/hermes-mcp";
          };
        }
        # Shared cross-tool knowledge-graph memory (entity/relation store in a
        # JSONL file). Same MEMORY_FILE_PATH as Hermes so both agents share one KB.
        // {
          memory = {
            command = "${pkgs.mcp-server-memory}/bin/mcp-server-memory";
            env = {
              MEMORY_FILE_PATH = "${config.home.homeDirectory}/.local/share/mcp-memory/memory.jsonl";
            };
          };
          # Real NixOS / Home Manager / nix docs lookup via search.nixos.org, so
          # agents stop hallucinating option/package names.
          nixos = {
            command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
          };
        };
    };

    home.activation.createMCPMemoryDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p "$HOME/.local/share/mcp-memory"
    '';

    xdg.configFile = {
      # oh-my-opencode-slim preset config (brings the context7 + gh_grep MCPs)
      "opencode/oh-my-opencode-slim.json".source = ./opencode/oh-my-opencode-slim.json;
    };
  };
}
