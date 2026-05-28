-- =============================================================================
-- lua/plugins/syntax.lua
-- Code Parsing, AST Building, and Syntax Highlighting (Treesitter)
-- =============================================================================

return {

  -- Treesitter: highly-optimized code syntax parser
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    -- By supplying ONLY the opts table and omitting the custom config hook,
    -- lazy.nvim will automatically load treesitter safely and run the setup
    -- with runtime paths fully resolved.
    opts = {
      ensure_installed = {
        "lua",
        "vim",
        "vimdoc",
        "javascript",
        "typescript",
        "tsx",
        "html",
        "css",
        "json",
        "markdown",
        "markdown_inline",
        "cpp",
        "c",
        "python",
      },
      highlight = {
        enable = true,
      },
      indent = {
        enable = true,
      },
    },
  },
}
