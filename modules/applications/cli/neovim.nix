{config, inputs, lib, pkgs, ...}:

let
  cfg = config.host.home.applications.neovim;
in
  with lib;
{
  imports = [ inputs.nixvim.homeManagerModules.nixvim ];

  options = {
    host.home.applications.neovim = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Text editor";
      };
    };
  };

  config = mkIf cfg.enable {
    programs = {
      nixvim = {
        enable = true;
        package = pkgs.neovim-unwrapped;
        vimAlias = true;

        opts = {
        };
        plugins = {
          toggleterm.enable = true;
          auto-save.enable = true;
          oil.enable = true;
          gitsigns.enable = true;
          markdown-preview.enable = true;
          nvim-autopairs.enable = true;
          friendly-snippets.enable = true;
          hmts.enable = true;
          cmp_luasnip.enable = true;
          popupmenu.enabled = false;
          lualine.enable = true;
          ressing.enable = true;
          comment = {
            enable = true;
            settings.toggler.line = "<leader>/";
          };
          yanky = {
            enable = true;
            settings.highlight.timer = 100;
          };
          auto-session = {
            enable = true;
            bypassSessionSaveFileTypes = [ "neo-tree" ];
          };
          luasnip = {
            enable = true;
            fromVscode = [ { } ];
          };
          lspkind = {
            enable = true;
            mode = "symbol";
          };
          neo-tree = {
            enable = true;
            filesystem.filteredItems.visible = true;
          };
          noice = {
            enable = true;
            popupmenu.enabled = false;
            presets = {
            bottom_search = true;
            command_palette = true;
            long_message_to_split = true;
            inc_rename = false;
            lsp_doc_border = false;
            };
          };
          treesitter = {
            enable = true;
            settings.highlight.enable = true;
            settings.incremental_selection = {
              enable = true;
              highlight.enable = true;
              keymaps.init_selection = "<A-h>";
              keymaps.node_decremental = "<A-l>";
              keymaps.node_incremental = "<A-h>";
            };
          };
          none-ls = {
            enable = true;
            sources.formatting.prettier.enable = true;
            sources.formatting.prettier.disableTsServerFormatter = true;
            # sources.formatting.rustfmt.enable = true;
            sources.formatting.black.enable = true;
            sources.formatting.nixfmt.enable = true;
            # sources.formatting.beautysh.enable = true;
          };
          telescope = {
            enable = true;
            keymaps = {
              "<leader>fr" = { action = "registers"; };
              "<leader>fw" = { action = "live_grep"; };
              "<leader>ff" = { action = "find_files"; };
              "<leader>f<CR>" = { action = "resume"; };
            };

            settings.defaults.sorting_strategy = "ascending";
            settings.defaults.layout_config = {
              horizontal = {
                prompt_position = "top";
                preview_width = 0.55;
              };
              vertical = { mirror = false; };
              width = 0.87;
              height = 0.8;
              preview_cutoff = 120;
            };
          };
          cmp = {
            enable = true;
            settings = {
              mapping = {
                "<CR>" = "cmp.mapping.confirm({ select = false })";
                "<C-u>" = ''cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" })'';
                "<C-d>" = ''cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" })'';
                "<C-Space>" = "cmp.mapping.complete()";
                "<S-Tab>" = ''
                  function(fallback)
                    local luasnip=require("luasnip")
                    if cmp.visible() then
                      cmp.select_prev_item()
                    elseif luasnip.jumpable(-1) then
                      luasnip.jump(-1)
                    else
                      fallback()
                    end
                  end
                '';
                "<Tab>" = ''
                  function(fallback)
                      local luasnip=require("luasnip")
                      if cmp.visible() then
                        cmp.select_next_item()
                      elseif luasnip.expandable() then
                        luasnip.expand()
                      elseif luasnip.expand_or_jumpable() then
                        luasnip.expand_or_jump()
                      else
                        fallback()
                      end
                    end
                '';
              };
              snippet.expand =
                "function(args) require('luasnip').lsp_expand(args.body) end";
              sources = [
                {
                  name = "nvim_lsp";
                  priority = 1000;
                }
                {
                  name = "luasnip";
                  priority = 750;
                }
                {
                  name = "buffer";
                  priority = 500;
                  option.get_bufnrs.__raw = "vim.api.nvim_list_bufs";
                }
                {
                  name = "path";
                  priority = 250;
                }
              ];
              window = {
                completion = {
                  border = "rounded";
                  winhighlight =
                    "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None";
                  scrolloff = 0;
                  colOffset = 0;
                  sidePadding = 1;
                  scrollbar = true;
                };
                documentation = {
                  maxHeight = "math.floor(40 * (40 / vim.o.lines))";
                  maxWidth =
                    "math.floor((40 * 2) * (vim.o.columns / (40 * 2 * 16 / 9)))";
                  border = "rounded";
                  winhighlight =
                    "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None";
                };
              };
            };
        };
        keymaps = [
          {
            key = "<leader>/";
            action =
              "<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<cr>";
            options.desc = "Comment visual text";
            mode = "v";
          }
          {
            key = "<leader>/";
            action.__raw = ''
            function() require("Comment.api").toggle.linewise.count(vim.v.count > 0 and vim.v.count or 1) end'';
            options.desc = "Comment line";
            mode = "n";
          }
          {
            key = "]g";
            action = "<cmd>Gitsigns prev_hunk<cr>";
            mode = "n";
          }
          {
            key = "[g";
            action = "<cmd>Gitsigns next_hunk<cr>";
            mode = "n";
          }
          {
            key = "<leader>gd";
            action = "<cmd>Gitsigns diffthis<cr>";
            mode = "n";
          }
          {
            key = "<leader>la";
            action.__raw = "function() vim.lsp.buf.code_action() end";
            options.desc = "Code action";
            mode = "v";
          }
          {
            key = "<leader>la";
            action.__raw = "function() vim.lsp.buf.code_action() end";
            options.desc = "Code action";
            mode = "n";
          }
          {
            key = "gd";
            action.__raw =
              ''function() require("telescope.builtin").lsp_definitions() end'';
            options.desc = "Go to definition";
            mode = "n";
          }
          {
            key = "gr";
            action.__raw = ''function() require("telescope.builtin").lsp_references() end'';
            options.desc = "References of current symbol";
            mode = "n";
          }
          {
            key = "<leader>lR";
            action.__raw = ''function() require("telescope.builtin").lsp_references() end'';
            options.desc = "Search references";
            mode = "n";
          }
          {
            key = "<leader>lr";
            action.__raw = "function() vim.lsp.buf.rename() end";
            options.desc = "Rename current symbol";
            mode = "n";
          }
          {
            key = "<leader>lh";
            action.__raw = "function() vim.lsp.buf.signature_help() end";
            options.desc = "Signature help";
            mode = "n";
          }
          {
            key = "gy";
            action.__raw =
              ''function() require("telescope.builtin").lsp_type_definitions() end'';
            options.desc = "Definition of current type";
            mode = "n";
          }
          {
            key = "<leader>lG";
            action.__raw = ''
              function()
                vim.ui.input({ prompt = "Symbol Query:" }, function(query)
                  if query then
                    -- word under cursor if given query is empty
                    if query == "" then query = vim.fn.expand "<cword>" end
                    require("telescope.builtin").lsp_workspace_symbols {
                      query = query,
                      prompt_title = ("Find word (%s)"):format(query),
                    }
                  end
                end)
              end
            '';
            options.desc = "Search workspace symbols";
            mode = "n";
          }
          {
            key = "K";
            action.__raw = "function () vim.lsp.buf.hover() end";
            options.desc = "Hover symbol details";
            mode = "n";
          }
          {
            key = "<leader>lr";
            action.__raw = "function () vim.lsp.buf.rename() end";
            options.desc = "Rename using lsp";
            mode = "n";
          }
          {
            key = "<leader>ld";
            action.__raw = "function() vim.diagnostic.open_float() end";
            options.desc = "Hover diagnostics";
            mode = "n";
          }
          {
            key = "[d";
            action.__raw = "function() vim.diagnostic.goto_prev() end";
            options.desc = "Previous diagnostic";
            mode = "n";
          }
          {
            key = "]d";
            action.__raw = "function() vim.diagnostic.goto_next() end";
            options.desc = "Next diagnostic";
            mode = "n";
          }
          {
            key = "gl";
            action.__raw = "function() vim.diagnostic.open_float() end";
            options.desc = "Hover diagnostics";
            mode = "n";
          }
          {
            key = "<leader>lf";
            action.__raw = "function () vim.lsp.buf.format() end";
            options.desc = "Format using lsp";
            mode = "n";
          }
          {
            # Default mode is "" which means normal-visual-op
            key = "<leader>e";
            action = "<Cmd>Neotree toggle reveal<CR>";
            options.desc = "Explorer";
          }
          {
            key = "<leader>q";
            action = "<Cmd>confirm q<Cr>";
            options.desc = "Quit";
          }
          {
            key = "<leader>C";
            action = "<Cmd>%bd<Cr>";
            options.desc = "exit all buffer";
          }
          {
            key = "<leader>c";
            action = "<Cmd>bdelete<Cr>";
            options.desc = "exit buffer";
          }
          {
            key = "H";
            action = "<Cmd>bprevious<Cr>";
            mode = "n";
          }
          {
            key = "L";
            action = "<Cmd>bnext<Cr>";
            mode = "n";
          }
          {
            key = "<C-h>";
            action.__raw =
              "function () require('smart-splits').move_cursor_left() end";
            mode = "n";
          }
          {
            key = "<C-j>";
            action.__raw =
              "function () require('smart-splits').move_cursor_down() end";
            mode = "n";
          }
          {
            key = "<C-k>";
            action.__raw = "function () require('smart-splits').move_cursor_up() end";
            mode = "n";
          }
          {
            key = "<C-l>";
            action.__raw =
              "function () require('smart-splits').move_cursor_right() end";
            mode = "n";
          }
          {
            key = "<C-Up>";
            action.__raw = "function () require('smart-splits').resize_up() end";
            mode = "n";
          }
          {
            key = "<C-Down>";
            action.__raw = "function () require('smart-splits').resize_down() end";
            mode = "n";
          }
          {
            key = "<C-Left>";
            action.__raw = "function () require('smart-splits').resize_left() end";
            mode = "n";
          }
          {
            key = "<C-Right>";
            action.__raw = "function () require('smart-splits').resize_right() end";
            mode = "n";
          }
          {
            key = "<leader>tf";
            action = "<Cmd>ToggleTerm direction=float<CR>";
            mode = "n";
          }
          {
            key = "<leader>th";
            action = "<Cmd>ToggleTerm size=10 direction=horizontal<CR>";
            mode = "n";
          }

          {
            key = "<leader>tv";
            action = "<Cmd>ToggleTerm size=80 direction=vertical<CR>";
            mode = "n";
          }

          {
            key = "<F7>";
            action = "<Cmd>ToggleTerm<CR>";
            mode = "n";
          }

          {
            key = "<F7>";
            action = "<Cmd>ToggleTerm<CR>";
            mode = "t";
          }

          {
            key = "<C-'>";
            action = "<Cmd>ToggleTerm<CR>";
            mode = "n";
          }

          {
            key = "<C-'>";
            action = "<Cmd>ToggleTerm<CR>";
            mode = "t";
          }
        ];
        extraConfigVim = ''
          let g:auto_session_pre_save_cmds = ["Neotree close"]
        '';
        extraConfigLua = ''
          local cmp=require('cmp')
          cmp.event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done { tex = false })
        '';
        cmp-nvim-lsp.enable = true;
        lsp = {
          enable = true;
          servers.eslint.enable = true;
          servers.graphql.enable = true;
          servers.dockerls.enable = true;
          servers.docker-compose-language-service.enable = true;
          servers.denols = {
            enable = true;
            rootDir =
              ''require('lspconfig').util.root_pattern("deno.json", "deno.jsonc")'';
          };
          servers.tsserver = {
            enable = true;
            extraOptions = { single_file_support = false; };
            rootDir = ''require('lspconfig').util.root_pattern("package.json")'';
          };
          servers.cssls.enable = true;
          servers.prismals.enable = true;
          servers.bashls.enable = true;
          servers.rust-analyzer = {
            enable = true;
            cargoPackage = fenix.stable.cargo;
            rustcPackage = fenix.stable.rustc;
            installCargo = false;
            installRustc = false;
          };
          servers.html.enable = true;
          servers.tailwindcss.enable = true;
          servers.svelte.enable = true;
          servers.emmet-ls.enable = true;
          servers.pyright.enable = true;
          servers.ccls.enable = true;
          servers.nixd.enable = true;
        };
    };
   };
  };
 };
}
