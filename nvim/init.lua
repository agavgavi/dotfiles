local opt = vim.opt
local g = vim.g

vim.wo.wrap = false
vim.o.timeout = true
vim.o.timeoutlen = 0

vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    pattern = {"*"},
    callback = function()
      local save_cursor = vim.fn.getpos(".")
      pcall(function() vim.cmd [[%s/\s\+$//e]] end)
      vim.fn.setpos(".", save_cursor)
    end,
})
