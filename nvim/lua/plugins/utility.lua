-- =============================================================================
-- lua/plugins/utility.lua
-- Premium Developer Utilities: Session Saving, UI Dressings, and TODO Searching
-- =============================================================================

return {

  -- 1. Todo Comments: beautiful, high-contrast comments highlighter & finder
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
    keys = {
      { "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "Find: TODO / FIXME comments" },
    },
  },

  -- 2. Dressing: premium UI overlays for select / input prompts
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    opts = {
      input = {
        border = "rounded",
        win_options = { winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder" },
      },
      select = {
        backend = { "telescope", "builtin" },
      },
    },
  },

  -- 3. Persistence: automatic session save & restore
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
    keys = {
      { "<leader>qs", function() require("persistence").load() end,                desc = "Session: Restore current directory" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Session: Restore last session" },
    },
  },
}
