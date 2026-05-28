-- ======================
-- lua/plugins/cp.lua
-- Competitive Programming tools
-- ======================

local M = {}

-- Config
local cfg = {
  compiler    = "g++",
  std         = "c++17",
  optim       = "-O2",
  extra_flags = "-Wall -Wextra -DLOCAL",
  input_file  = "input.txt",
  output_file = "output.txt",
}

-- Build the compile + run powershell command
local function build_cmd(file, exe)
  local flags = table.concat({
    "-std=" .. cfg.std,
    cfg.optim,
    cfg.extra_flags,
  }, " ")

  local compile = string.format("%s %s '%s' -o '%s'", cfg.compiler, flags, file, exe)

  local dir       = vim.fn.fnamemodify(file, ":h")
  local input     = dir .. "\\" .. cfg.input_file
  local run

  if vim.fn.filereadable(input) == 1 then
    run = string.format("& '%s' < '%s'", exe, input)
  else
    run = string.format("& '%s'", exe)
  end

  return compile .. "; if ($?) { " .. run .. " }"
end

-- Close any open terminal window
local function close_terminal()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].buftype == "terminal" then
      vim.api.nvim_win_close(win, true)
      break
    end
  end
end

-- Compile & run with <F5>
function M.compile_run()
  if vim.fn.expand("%:e") ~= "cpp" then
    vim.notify("Not a C++ file!", vim.log.levels.WARN)
    return
  end

  vim.cmd("write")

  local file = vim.fn.expand("%:p")
  local exe  = vim.fn.expand("%:p:r") .. ".exe"
  local cmd  = build_cmd(file, exe)

  close_terminal()
  vim.cmd('botright 15split | terminal powershell -NoExit -Command "' .. cmd .. '"')
  vim.cmd("wincmd p")
end

-- Compile only with <F6> (check for errors without running)
function M.compile_only()
  if vim.fn.expand("%:e") ~= "cpp" then
    vim.notify("Not a C++ file!", vim.log.levels.WARN)
    return
  end

  vim.cmd("write")

  local file    = vim.fn.expand("%:p")
  local exe     = vim.fn.expand("%:p:r") .. ".exe"
  local flags   = table.concat({ "-std=" .. cfg.std, cfg.optim, cfg.extra_flags }, " ")
  local compile = string.format("%s %s '%s' -o '%s'", cfg.compiler, flags, file, exe)
  local cmd     = compile .. "; if ($?) { Write-Host 'Compiled OK' -ForegroundColor Green }"

  vim.cmd('botright 15split | terminal powershell -NoExit -Command "' .. cmd .. '"')
  vim.cmd("wincmd p")
end

-- Create input.txt next to current file with <F9>
function M.open_input()
  local dir   = vim.fn.expand("%:p:h")
  local input = dir .. "/" .. cfg.input_file
  if vim.fn.filereadable(input) == 0 then
    vim.fn.writefile({}, input)
  end
  vim.cmd("vsplit " .. input)
end

-- Keymaps
vim.keymap.set("n", "<F5>", M.compile_run,  { noremap = true, silent = true, desc = "C++: Compile & Run" })
vim.keymap.set("n", "<F6>", M.compile_only, { noremap = true, silent = true, desc = "C++: Compile Only" })
vim.keymap.set("n", "<F9>", M.open_input,   { noremap = true, silent = true, desc = "C++: Open input.txt" })

-- Auto-insert template on new .cpp file
vim.api.nvim_create_autocmd("BufNewFile", {
  pattern  = "*.cpp",
  callback = function()
    local template = vim.fn.stdpath("config") .. "/templates/cp.cpp"
    if vim.fn.filereadable(template) == 1 then
      vim.cmd("0r " .. template)
      vim.cmd("normal! G")
    end
  end,
})

return {}

