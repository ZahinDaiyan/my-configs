-- =============================================================================
-- lua/plugins/lsp.lua
-- Language Server Protocol (LSP) Config, Mason Package Manager
-- =============================================================================

return {

  -- Mason: internal manager for third-party LSPs, formatters, and linters
  {
    "williamboman/mason.nvim",
    build  = ":MasonUpdate",
    config = function()
      require("mason").setup({
        ui = {
          border = "rounded",
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
          }
        }
      })
    end,
  },

  -- Mason-lspconfig: Bridges the gap between Mason and lspconfig
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      require("mason-lspconfig").setup({
        -- Ensure required language servers are pre-installed
        ensure_installed = {
          "ts_ls",
          "html",
          "cssls",
          "jsonls",
          "emmet_language_server",
          "lua_ls",
        },
        automatic_installation = true,
      })
    end,
  },

  -- Nvim-Lspconfig: handles LSP startup, capabilities, and configuration
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local lspconfig = require("lspconfig")

      -- Dynamic fallback helper for maximum robustness across Neovim versions
      local function setup_server(name, config)
        config = config or {}
        config.capabilities = vim.tbl_deep_extend("force", capabilities, config.capabilities or {})
        
        if vim.lsp.config and vim.lsp.enable then
          vim.lsp.config(name, config)
          vim.lsp.enable(name)
        else
          lspconfig[name].setup(config)
        end
      end

      -- Configure Emmet language server for HTML/JSX shorthand expansions
      setup_server("emmet_language_server", {
        filetypes = { "html", "css", "javascriptreact", "typescriptreact", "sass", "scss", "less" },
      })

      -- Configure Javascript / Typescript
      setup_server("ts_ls")

      -- Configure HTML
      setup_server("html")

      -- Configure CSS
      setup_server("cssls")

      -- Configure JSON
      setup_server("jsonls")

      -- Configure Lua Language Server
      setup_server("lua_ls", {
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" }, -- Suppress "undefined global vim" warning
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            telemetry = {
              enable = false,
            },
          },
        },
      })
    end,
  },

  -- Emmet Language Server source specification
  { "olrtg/emmet-language-server" },
}
