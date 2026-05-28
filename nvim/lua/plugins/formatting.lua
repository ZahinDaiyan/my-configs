-- =============================================================================
-- lua/plugins/formatting.lua
-- Code Formatting (Conform.nvim) with Format-On-Save and manual formatting
-- =============================================================================

return {

  -- Conform: lightweight, powerful code formatter runner
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          lua             = { "stylua" },
          javascript      = { "prettier" },
          typescript      = { "prettier" },
          javascriptreact = { "prettier" },
          typescriptreact = { "prettier" },
          html            = { "prettier" },
          css             = { "prettier" },
          json            = { "prettier" },
          markdown        = { "prettier" },
          python          = { "black" },
        },
        -- Format-on-save configuration
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
      })

      -- Keybinding to trigger manual formatting
      vim.keymap.set("n", "<leader>ff", function()
        require("conform").format({ async = true, lsp_fallback = true })
      end, { desc = "Format: file (Prettier/Stylua)" })
    end,
  },
}
