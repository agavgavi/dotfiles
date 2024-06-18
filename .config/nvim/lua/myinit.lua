vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    pattern = {"*"},
    callback = function()
      local save_cursor = vim.fn.getpos(".")
      pcall(function() vim.cmd [[%s/\s\+$//e]] end)
      vim.fn.setpos(".", save_cursor)
    end,
})

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = {"gitcommit"},
  callback = function ()
    vim.opt.spelllang = 'en_us'
    vim.opt.spell = true
  end
})
