---@type NvPluginSpec

return {
  "neovim/nvim-lspconfig",
  config = function()
    dofile(vim.g.base46_cache .. "lsp")

    local lspconfig = require "lspconfig"
    local lsp = require "gale.lsp"

    local servers = {
      astro = {},
      bashls = {
        on_attach = function(client, bufnr)
          local filename = vim.api.nvim_buf_get_name(bufnr)
          if filename:match "%.env$" then
            vim.lsp.stop_client(client.id)
          end
        end,
      },
      clangd = {},
      css_variables = {},
      cssls = {},
      html = {},
      hls = {},
      gopls = {},
      jsonls = {},
      lua_ls = {
        settings = {
          Lua = {
            hint = { enable = true },
            telemetry = { enable = false },
            diagnostics = { globals = { "bit", "vim", "it", "describe", "before_each", "after_each" } },
          },
        },
      },
      marksman = {},
      ocamllsp = {},
      pyright = {},
      ts_ls = {},
      ruff_lsp = {
        on_attach = function(client, _)
          -- prefer pyright's hover provider
          client.server_capabilities.hoverProvider = false
        end,
      },
      somesass_ls = {},
      taplo = {},
      vtsls = {
        settings = {
          javascript = {
            inlayHints = lsp.inlay_hints_settings,
            updateImportsOnFileMove = 'always',
          },
          typescript = {
            inlayHints = lsp.inlay_hints_settings,
            updateImportsOnFileMove = 'always',
          },
          vtsls = {
            tsserver = {
              globalPlugins = {
                "@styled/typescript-styled-plugin",
              },
            },
            experimental = {
              completion = {
                enableServerSideFuzzyMatch = true,
              },
            },
          },
        },
      },
      yamlls = {},
      zls = {},
      intelephense = {
        settings = {
          intelephense = {
            environment = {
              phpVersion = "8.1", -- Update according to your PHP version
            },
            files = {
              maxSize = 5000000, -- Increase if necessary for large Laravel projects
            },
          },
        },
      },

      solidity = {
        cmd = { "solidity-ls", "--stdio" }, -- Ensure solidity-ls is installed globally
        filetypes = { "solidity" },
        root_dir = lspconfig.util.find_git_ancestor, -- Finds the nearest git project root
        settings = {
          solidity = {
            includePath = "", -- Adjust if you have custom libraries
            remapping = {},   -- Optional remapping configuration for Solidity
          },
        },
        on_attach = function(client, bufnr)
          -- Additional logic during attachment (if needed)
          print("Solidity LSP attached!")
        end,
      },
    }

    for name, opts in pairs(servers) do
      opts.on_init = lsp.on_init
      opts.on_attach = lsp.create_on_attach(opts.on_attach)
      opts.capabilities = lsp.capabilities
      lspconfig[name].setup(opts)
    end

    -- LSP UI
    local border = "rounded"
    local x = vim.diagnostic.severity
    vim.diagnostic.config {
      virtual_text = false,
      signs = { text = { [x.ERROR] = "", [x.WARN] = "", [x.INFO] = "", [x.HINT] = "󰌵" } },
      float = { border = border },
      underline = true,
    }

    -- Gutter
    vim.fn.sign_define("CodeActionSign", { text = "󰉁", texthl = "CodeActionSignHl" })
  end,
}
