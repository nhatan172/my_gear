-- if not vim.fn.has "wsl" then
--  return
-- end

-- set a global value to indicate that we are in WSL
-- vim.g.is_wsl = false

-- local copy = vim.fn.expand "~" .. "/bin/win32yank.exe -i --crlf"
-- local paste = vim.fn.expand "~" .. "/bin/win32yank.exe -o --lf"
-- vim.g.clipboard = {
--  name = "wslclipboard",
--  copy = { ["+"] = copy, ["*"] = copy },
--  paste = { ["+"] = paste, ["*"] = paste },
-- }
--  cache_enabled = 1,
