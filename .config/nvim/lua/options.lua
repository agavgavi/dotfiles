require "nvchad.options"

-- add yours here!

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!
-- TREESITTER Indenting

-- FOLD INFORMATION
vim.o.foldenable = false
-- CSV Info
vim.g.disable_rainbow_hover = 1
vim.g.disable_rainbow_statusline = 1

vim.o.autoread = true
-- No wrap and color column
vim.wo.wrap = false
vim.o.timeout = true
vim.o.timeoutlen = 0
vim.o.colorcolumn = "100"

-- CONFLICT HIGHLIGHTER SETTINGS
vim.g.conflict_marker_highlight_group = ''
vim.g.conflict_marker_begin = '^<<<<<<<\\+ .*$'
vim.g.conflict_marker_common_ancestors = '^|||||||\\+ .*$'
vim.g.conflict_marker_end   = '^>>>>>>>\\+ .*$'

vim.api.nvim_set_hl(0, 'ConflictMarkerBegin', { bg = '#2f7366' })
vim.api.nvim_set_hl(0, 'ConflictMarkerOurs', { bg = '#2e5049' })
vim.api.nvim_set_hl(0, 'ConflictMarkerTheirs', { bg = '#344f69' })
vim.api.nvim_set_hl(0, 'ConflictMarkerEnd', { bg = '#2f628e' })
vim.api.nvim_set_hl(0, 'ConflictMarkerCommonAncestorsHunk', { bg = '#754a81' })
