-- =============================================================================
-- lua/plugins/navigation.lua
-- Navigation, Fuzzy Finder (Telescope), and Sidebar Explorer (Nvim-tree)
-- =============================================================================

local map = vim.keymap.set

return {

  -- Plenary: required utility library for Telescope
  { "nvim-lua/plenary.nvim" },

  -- Telescope: fuzzy finder engine
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config       = function()
      local builtin = require("telescope.builtin")

      -- Register interactive finder keymaps
      map("n", "<C-p>",      builtin.find_files, { desc = "Find: files by name" })
      map("n", "<leader>fg", builtin.live_grep,  { desc = "Find: live grep string search" })
      map("n", "<leader>fb", builtin.buffers,    { desc = "Find: open active buffers" })
      map("n", "<leader>fh", builtin.help_tags,  { desc = "Find: documentation help tags" })
    end,
  },

  -- NvimTree: Sidebar file system explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config       = function()
      require("nvim-tree").setup({
        sort_by = "case_sensitive",
        view = {
          width = 30,
          side = "left",
        },
        renderer = {
          group_empty = true,
        },
        filters = {
          dotfiles = false,
        },
      })

      -- Keybinding to toggle sidebar file explorer
      map("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle File Explorer" })
    end,
  },
}
