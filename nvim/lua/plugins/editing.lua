-- =============================================================================
-- lua/plugins/editing.lua
-- Text Editing, Auto-Pairs, Smart Comments, and Fast Motions
-- =============================================================================

return {

  -- Surround: change/delete/add surroundings (e.g. cs"', ysiw(, ds{)
  {
    "kylechui/nvim-surround",
    version = "*",
    event   = "VeryLazy",
    config  = function()
      require("nvim-surround").setup()
    end,
  },

  -- Autopairs: auto-closes bracket pairs (), {}, [], "", '', etc.
  {
    "windwp/nvim-autopairs",
    event  = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup()
    end,
  },

  -- Autotag: auto-closes and auto-renames HTML/JSX tags (smart TS integration)
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },

  -- VimTeX: LaTeX editing, compilation, and preview support
  {
    "lervag/vimtex",
    ft = { "tex", "bib" },
    config = function()
      if vim.fn.has("win32") == 1 then
        vim.g.vimtex_view_method = "SumatraPDF"
      else
        vim.g.vimtex_view_method = "zathura"
      end
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_quickfix_mode = 0
    end,
  },

  -- Jupyter-vim: notebook-style Python cell execution and Jupyter interaction
  {
    "jupyter-vim/jupyter-vim",
    ft = { "python", "jupyter" },
  },

  -- Comment.nvim: smart commenting
  -- Use `gcc` to toggle line comments, and `gc` in visual mode to comment blocks
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("Comment").setup()
    end,
  },

  -- Flash.nvim: Blazing-fast jump motions and text selection jumping
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end,       desc = "Flash Search Jump" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter Scope Selection" },
      { "r", mode = "o",               function() require("flash").remote() end,     desc = "Flash Remote Operator Motion" },
      { "R", mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search Select" },
    },
  },
}
