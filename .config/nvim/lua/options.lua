require "nvchad.options"

-- add yours here!

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!
-- TREESITTER Indenting
--
-- Visible whitespace
vim.o.list = true
vim.opt.listchars = {
  tab = '» ',
  trail = '·',
  nbsp = '␣',
  extends = '→',
  precedes = '←',
}

-- FOLD INFORMATION
vim.o.foldenable = false
-- CSV Info
vim.g.disable_rainbow_hover = 1
vim.g.disable_rainbow_statusline = 1

vim.o.autoread = true
vim.o.updatetime = 250
-- No wrap and color column
vim.o.wrap = false
vim.o.timeout = true
vim.o.timeoutlen = 300 -- which-key delay=0 keeps the popup instant
vim.o.colorcolumn = "100"

-- CONFLICT HIGHLIGHTER SETTINGS
vim.g.conflict_marker_highlight_group = ''
vim.g.conflict_marker_begin = '^<<<<<<<\\+ .*$'
vim.g.conflict_marker_common_ancestors = '^|||||||\\+ .*$'
vim.g.conflict_marker_end   = '^>>>>>>>\\+ .*$'
-- highlight groups live in chadrc.lua (base46 hl_add) so they survive theme reloads
