require "nvchad.options"

-- add yours here!

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!
local g = vim.g
g.disable_rainbow_hover = 1
g.disable_rainbow_statusline = 1
local o = vim.o
vim.wo.wrap = false
o.timeout = true
o.timeoutlen = 0
o.colorcolumn = "100"
