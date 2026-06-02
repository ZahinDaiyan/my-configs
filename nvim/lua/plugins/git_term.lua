-- =============================================================================
-- lua/plugins/git_term.lua
-- Git Integration (Gitsigns) and Terminal Management (Toggleterm)
-- =============================================================================

local map = vim.keymap.set

return {

  -- Fugitive: Git commands and repository browsing from within Neovim
  {
    "tpope/vim-fugitive",
    event = "VeryLazy",
  },

  -- Gitsigns: Shows git diff indicators in the gutter and provides hunk actions
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitsigns").setup({
        signs = {
          add          = { text = "┃" },
          change       = { text = "┃" },
          delete       = { text = "_" },
          topdelete    = { text = "‾" },
          changedelete = { text = "~" },
          untracked    = { text = "┆" },
        },
        signcolumn = true,
        numhl      = false,
        linehl     = false,
        word_diff  = false,
        watch_gitdir = {
          follow_files = true,
        },
        auto_attach = true,
        attach_to_untracked = false,
        current_line_blame = false, -- Toggle dynamically with <leader>gb
      })

      -- Git keymaps registered with appropriate labels
      map("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", { desc = "Git: Preview current hunk" })
      map("n", "<leader>gs", ":Gitsigns stage_hunk<CR>",   { desc = "Git: Stage current hunk" })
      map("n", "<leader>gr", ":Gitsigns reset_hunk<CR>",   { desc = "Git: Reset current hunk" })
      map("n", "<leader>gb", ":Gitsigns toggle_current_line_blame<CR>", { desc = "Git: Toggle inline blame" })
    end,
  },

  -- Toggleterm: Seamlessly manage and toggle multiple terminal terminals
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("toggleterm").setup({
        -- Default to pwsh for modern terminal experience on Windows
        shell = vim.fn.executable("pwsh") == 1 and "pwsh" or "powershell",
        size  = function(term)
          if term.direction == "horizontal" then
            return 15
          elseif term.direction == "vertical" then
            return math.floor(vim.o.columns * 0.4)
          end
        end,
        open_mapping = [[<c-\>]], -- Default global mapping to toggle
        hide_numbers = true,
        shade_terminals = true,
        start_in_insert = true,
        insert_mappings = true,
        terminal_mappings = true,
        persist_size = true,
        persist_mode = true,
        direction = "float",
        close_on_exit = true,
        float_opts = {
          border = "curved",
          width  = math.floor(vim.o.columns * 0.85),
          height = math.floor(vim.o.lines   * 0.80),
          winblend = 0,
        },
      })

      -- Keybinding to toggle floating terminal
      map("n", "<leader>t", function()
        require("toggleterm").toggle(2, nil, nil, "float")
      end, { desc = "Terminal: Toggle Floating terminal" })

      -- Keymaps inside terminal buffers
      vim.api.nvim_create_autocmd("TermOpen", {
        pattern = "term://*",
        callback = function()
          local opts = { buffer = 0 }
          -- In term buffers, double-escape lets us easily escape toggleterm
          map("t", "<Esc><Esc>", "<C-\\><C-n>", opts)
        end,
      })
    end,
  },
}
