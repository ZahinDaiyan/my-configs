-- =============================================================================
-- lua/plugins/ui_helpers.lua
-- UI Helpers: Keymap Discovery, Indentation Guides, Modern Commands & Notifications
-- =============================================================================

return {

  -- Which-key: displays helpful keybinding popups on pressing leader key
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")
      wk.setup({
        preset = "modern",
      })

      -- Register interactive category groups
      wk.add({
        { "<leader>f",  group = "Find (Telescope)" },
        { "<leader>g",  group = "Git" },
        { "<leader>r",  group = "Refactor / Rename" },
        { "<leader>c",  group = "Code / Comment" },
        { "<leader>x",  desc = "Close Buffer" },
        { "<leader>bg", desc = "Toggle Transparent Background" },
        { "<leader>e",  desc = "Toggle File Explorer" },
        { "<leader>t",  desc = "Toggle Floating Terminal" },
      })
    end,
  },

  -- Indent Blankline (ibl): subtle vertical indentation guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main  = "ibl",
    event = "BufReadPost",
    config = function()
      local hooks = require("ibl.hooks")
      -- Set subtle Catppuccin Mocha colors for guide lines
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, "IblIndent", { fg = "#313244" }) -- Surface1
        vim.api.nvim_set_hl(0, "IblScope",  { fg = "#585b70" }) -- Overlay0
      end)

      require("ibl").setup({
        indent = {
          char      = "│",
          highlight = "IblIndent",
        },
        scope = {
          enabled    = true,
          highlight  = "IblScope",
          show_start = true,
          show_end   = false,
        },
      })
    end,
  },

  -- Modern UI Overlays: Noice replaces cmdline, messages, and popups
  {
    "folke/noice.nvim",
    event        = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    config = function()
      require("noice").setup({
        cmdline = {
          enabled = true,
          view    = "cmdline_popup", -- Floating modern popup cmdline
        },
        messages = {
          enabled = false, -- Disable message clutter
        },
        popupmenu = {
          enabled = true, -- Modern popup suggestion list
        },
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
          progress = { enabled = false },
          hover    = { enabled = false },
          signature = { enabled = false },
          message  = { enabled = false },
        },
        routes = {
          {
            filter = { event = "notify" },
            opts   = { skip = true }, -- Keep noise to a minimum
          },
        },
      })
    end,
  },
}
