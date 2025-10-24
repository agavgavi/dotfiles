vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  pattern = { "*" },
  callback = function()
    local save_cursor = vim.fn.getpos(".")
    pcall(function() vim.cmd [[%s/\s\+$//e]] end)
    vim.fn.setpos(".", save_cursor)
  end,
})

vim.api.nvim_create_autocmd ("TermOpen",  {
      callback = function(args)
           if(vim.bo[args.buf].buftype == "terminal") then
              vim.bo[args.buf].buflisted = false
          end
      end
})

function dump(o)
   if type(o) == 'table' then
      local left = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         left = left .. '['..k..'] = ' .. dump(v) .. ','
      end
      return left .. '} '
   else
      return tostring(o)
   end
end

vim.o.updatetime = 250

for _, v in ipairs(vim.fn.readdir(vim.g.base46_cache)) do
   dofile(vim.g.base46_cache .. v)
 end

