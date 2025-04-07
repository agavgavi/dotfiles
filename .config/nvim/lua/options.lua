require "nvchad.options"

-- add yours here!

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!


-- FOLD INFORMATION
vim.o.foldenable = true
vim.o.foldlevelstart=99
vim.o.foldlevel = 99
vim.o.foldmethod = 'manual' -- 'indent'

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
         local client = vim.lsp.get_client_by_id(args.data.client_id)
         if client and client:supports_method('textDocument/foldingRange') then
             local win = vim.api.nvim_get_current_win()
             vim.wo[win][0].foldmethod = 'expr'
            vim.wo[win][0].foldexpr = 'v:lua.vim.lsp.foldexpr()'
        end
    end,
 })
-- CSV Info
vim.g.disable_rainbow_hover = 1
vim.g.disable_rainbow_statusline = 1

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
