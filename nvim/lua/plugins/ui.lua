-- =============================================================================
-- lua/plugins/ui.lua
-- UI, Theme, Statusline, and Tabs
-- =============================================================================

local map = vim.keymap.set

return {

  -- File icons across all UI components
  {
    "nvim-tree/nvim-web-devicons",
    lazy = false,
  },

  -- Theme: Catppuccin Mocha flavor as default
  {
    "catppuccin/nvim",
    name     = "catppuccin",
    priority = 1000, -- Load first
    config   = function()
      require("catppuccin").setup({
        flavour = "mocha", -- Set flavor explicitly to Mocha
        transparent_background = false, -- transparent.nvim will handle dynamic toggling
        integrations = {
          bufferline = true,
          cmp = true,
          gitsigns = true,
          indent_blankline = {
            enabled = true,
            scope_color = "lavender",
          },
          markdown = true,
          mason = true,
          noice = true,
          notify = true,
          nvimtree = true,
          telescope = {
            enabled = true,
          },
          treesitter = true,
          which_key = true,
        },
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- Additional Popular Themes (Lazy loaded)
  {
    "folke/tokyonight.nvim",
    lazy = false,
    opts = { style = "moon" },
  },

  {
    "rebelot/kanagawa.nvim",
    lazy = false,
  },

  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
  },

  {
    "navarasu/onedark.nvim",
    lazy = false,
    config = function()
      require("onedark").setup({ style = "darker" })
    end,
  },

  {
    "sainnhe/gruvbox-material",
    lazy = false,
  },

  {
    "sainnhe/everforest",
    lazy = false,
  },

  {
    "AlexvZyl/nordic.nvim",
    lazy = false,
  },

  {
    "EdenEast/nightfox.nvim",
    lazy = false,
  },

  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
  },

  {
    "nyoom-engineering/oxocarbon.nvim",
    lazy = false,
  },

  {
    "Yazeed1s/minimal.nvim",
    lazy = false,
  },

  {
    "mcchrish/zenbones.nvim",
    lazy = false,
  },

  {
    "Mofiqul/dracula.nvim",
    lazy = false,
  },

  {
    "craftzdog/solarized-osaka.nvim",
    lazy = false,
  },

  {
    "projekt0n/github-nvim-theme",
    lazy = false,
  },

  {
    "savq/melange-nvim",
    lazy = false,
  },

  {
    "loctvl842/monokai-pro.nvim",
    lazy = false,
  },

  {
    "marko-cerovac/material.nvim",
    lazy = false,
  },

  {
    "sainnhe/sonokai",
    lazy = false,
  },

  {
    "sainnhe/edge",
    lazy = false,
  },

  {
    "Shatur/neovim-ayu",
    lazy = false,
  },

  {
    "olivercederborg/poimandres.nvim",
    lazy = false,
  },

  {
    "maxmx03/fluoromachine.nvim",
    lazy = false,
  },

  {
    "bluz71/vim-moonfly-colors",
    lazy = false,
  },

  {
    "bluz71/vim-nightfly-colors",
    lazy = false,
  },

  {
    "rafamadriz/neon",
    lazy = false,
  },

  {
    "slugbyte/lackluster.nvim",
    lazy = false,
  },

  {
    "RRethy/base16-nvim",
    lazy = false,
  },

  {
    "vague2k/vague.nvim",
    lazy = false,
  },

  -- Transparent Background: dynamic transparency toggling via <leader>bg
  {
    "xiyaowong/transparent.nvim",
    lazy   = false,
    config = function()
      require("transparent").setup({
        extra_groups = {
          "NormalFloat",
          "NvimTreeNormal",
          "NvimTreeNormalNC",
          "TelescopeNormal",
          "TelescopeBorder",
          "lualine_c_normal",
          "BufferLineFill",
          "BufferLineBackground",
          "BufferLineSeparator",
        },
        exclude_groups = {},
      })
      vim.cmd("TransparentEnable") -- Enable transparency on startup

      local transparent_on = true
      map("n", "<leader>bg", function()
        transparent_on = not transparent_on
        if transparent_on then
          vim.cmd("TransparentEnable")
          vim.notify("Background: transparent", vim.log.levels.INFO)
        else
          vim.cmd("TransparentDisable")
          vim.notify("Background: solid", vim.log.levels.INFO)
        end
      end, { desc = "Toggle transparent background" })
    end,
  },

  -- Lualine: Premium statusline showing mode, git branch, diagnostics, and file name
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config       = function()
      require("lualine").setup({
        options  = {
          theme = "catppuccin",
          component_separators = { left = "│", right = "│" },
          section_separators   = { left = "", right = "" },
        },
        sections = {
          lualine_a = { { "mode", separator = { left = "", right = "" } } },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { { "location", separator = { left = "", right = "" } } },
        },
      })
    end,
  },

  -- Bufferline: Premium top bar displaying open buffers as tabs
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config       = function()
      require("bufferline").setup({
        options = {
          mode = "buffers",
          style_preset = require("bufferline").style_preset.default,
          themable = true,
          numbers = "none",
          close_command = "bdelete! %d",
          right_mouse_command = "bdelete! %d",
          left_mouse_command = "buffer %d",
          indicator = {
            style = "icon",
            icon = "┃",
          },
          buffer_close_icon = "󰅖",
          modified_icon = "●",
          close_icon = "",
          left_trunc_marker = "",
          right_trunc_marker = "",
          max_name_length = 18,
          max_prefix_length = 15,
          tab_size = 18,
          diagnostics = "nvim_lsp",
          diagnostics_update_in_insert = false,
          offsets = {
            {
              filetype = "NvimTree",
              text = "File Explorer",
              text_align = "left",
              separator = true,
            }
          },
          show_buffer_icons = true,
          show_buffer_close_icons = true,
          show_close_icon = false,
          show_tab_indicators = true,
          persist_buffer_sort = true,
          separator_style = "thin",
          enforce_regular_tabs = false,
          always_show_bufferline = true,
        },
      })

      -- Buffer switching keymaps
      map("n", "<Tab>", "<cmd>BufferLineCycleNext<cr>", { desc = "Buffer: Go to next tab" })
      map("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Buffer: Go to previous tab" })
      map("n", "<leader>x", "<cmd>bdelete<cr>", { desc = "Buffer: Close current buffer" })
    end,
  },
}
