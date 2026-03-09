-- ======================
-- lua/plugins/web.lua
-- Web development plugins & LSP
-- ======================

local map = vim.keymap.set

return {

  -- Theme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("catppuccin")
    end
  },

  -- Transparent background (inherits terminal opacity/wallpaper)
  {
    "xiyaowong/transparent.nvim",
    lazy = false,
    config = function()
      require("transparent").setup({
        extra_groups = {
          "NormalFloat",
          "NvimTreeNormal",
          "NvimTreeNormalNC",
          "TelescopeNormal",
          "TelescopeBorder",
          "lualine_c_normal",
        },
        exclude_groups = {},
      })
      -- Auto-enable transparency on start
      vim.cmd("TransparentEnable")
    end
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = { theme = "catppuccin" },
        sections = {
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 1 } },
        }
      })
    end
  },

  -- Snippets
  { "L3MON4D3/LuaSnip" },
  { "saadparwaiz1/cmp_luasnip" },

  -- Emmet
  { "olrtg/emmet-language-server" },

  -- Autopairs: auto-close {}, (), [], "", ''
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup()
    end
  },

  -- File Tree
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup()
      map("n", "<leader>e", ":NvimTreeToggle<CR>")
    end
  },

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require("telescope.builtin")
      map("n", "<C-p>",      builtin.find_files)
      map("n", "<leader>fg", builtin.live_grep)
      map("n", "<leader>fb", builtin.buffers)
      map("n", "<leader>fh", builtin.help_tags)
    end
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = {
        "lua", "javascript", "typescript",
        "tsx", "html", "css", "json", "markdown"
      },
      highlight = { enable = true },
      indent    = { enable = true },
    },
  },

  -- Auto-close HTML/JSX tags
  {
    "windwp/nvim-ts-autotag",
    config = function()
      require("nvim-ts-autotag").setup()
    end
  },

  -- Formatter (Prettier)
  {
    "stevearc/conform.nvim",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          javascript      = { "prettier" },
          typescript      = { "prettier" },
          javascriptreact = { "prettier" },
          typescriptreact = { "prettier" },
          html            = { "prettier" },
          css             = { "prettier" },
          json            = { "prettier" },
          markdown        = { "prettier" },
        },
        format_on_save = {
          timeout_ms   = 500,
          lsp_fallback = true,
        },
      })
      map("n", "<leader>ff", function()
        require("conform").format({ async = true, lsp_fallback = true })
      end)
    end
  },

  -- Git signs in gutter
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
      map("n", "<leader>gp", ":Gitsigns preview_hunk<CR>")
      map("n", "<leader>gs", ":Gitsigns stage_hunk<CR>")
      map("n", "<leader>gr", ":Gitsigns reset_hunk<CR>")
      map("n", "<leader>gb", ":Gitsigns toggle_current_line_blame<CR>")
    end
  },

  -- Terminal
  -- <leader>t  → full-page terminal (PowerShell 7)
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        shell = "pwsh",   -- PowerShell 7 (make sure pwsh is in your PATH)
        size = function(term)
          if term.direction == "horizontal" then
            return 15
          elseif term.direction == "vertical" then
            return vim.o.columns * 0.4
          end
        end,
        float_opts = {
          border = "curved",
          width  = math.floor(vim.o.columns * 0.85),
          height = math.floor(vim.o.lines * 0.80),
        },
      })

      -- <leader-t> → floating terminal
      map("n", "<leader>t", function()
        require("toggleterm").toggle(2, nil, nil, "float")
      end, { desc = "Terminal: floating" })

      -- Easy escape back to normal mode inside terminal
      map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Terminal: exit insert mode" })
    end
  },

  -- Autocomplete
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp     = require("cmp")
      local luasnip = require("luasnip")

      -- Make autopairs play nice with cmp
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

      cmp.setup({
        mapping = {
          ["<CR>"] = cmp.mapping.confirm({ select = true }),

          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),

          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),

          ["<C-Space>"] = cmp.mapping.complete(),
        },

        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },

        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }
      })
    end
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Emmet (HTML/CSS/JSX/TSX)
      vim.lsp.config("emmet_language_server", {
        filetypes = { "html", "css", "javascriptreact", "typescriptreact" },
        capabilities = capabilities,
      })
      vim.lsp.enable("emmet_language_server")

      -- TypeScript / JavaScript
      vim.lsp.config("ts_ls", { capabilities = capabilities })
      vim.lsp.enable("ts_ls")

      -- HTML
      vim.lsp.config("html", { capabilities = capabilities })
      vim.lsp.enable("html")

      -- CSS
      vim.lsp.config("cssls", { capabilities = capabilities })
      vim.lsp.enable("cssls")

      -- JSON
      vim.lsp.config("jsonls", { capabilities = capabilities })
      vim.lsp.enable("jsonls")
    end
  },
}
