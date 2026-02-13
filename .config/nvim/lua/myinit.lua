-- Automatically remove newlines at the end of the file.
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  pattern = { "*" },
  callback = function()
    local save_cursor = vim.fn.getpos(".")
    pcall(function() vim.cmd [[%s/\s\+$//e]] end)
    vim.fn.setpos(".", save_cursor)
  end,
})


vim.api.nvim_create_autocmd({"FileType"}, {
  pattern = {"python", "xml", "javascript"},
  callback = function()
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})


-- Automatically add new python files to models or controllers folder __init__.py
vim.api.nvim_create_autocmd({ "BufReadPost", "BufWinEnter" }, {
  pattern = "*.py",
  callback = function()
    if vim.fn.line("$") == 1 and vim.fn.getline(1) == "" then
      local file = vim.fn.expand("%:t:r")
      local folder = vim.fn.expand("%:p:h:t")
      local allowed_folders = {
        ["models"] = true,
        ["controllers"] = true,
      }
      if file ~= "__init__" and allowed_folders[folder] then
        local init_py = vim.fn.expand("%:p:h") .. "/__init__.py"
        local line = "from . import " .. file
        local do_write = true
        if vim.fn.filereadable(init_py) then
          local lines = vim.fn.readfile(init_py)
          do_write = not vim.tbl_contains(lines, line)
        end
        if do_write then
          vim.fn.writefile({line}, init_py, "a")
        end
      end
    end
  end,
})

-- Unlist terminals from buffers to fix nvim-dap-view
vim.api.nvim_create_autocmd ("TermOpen",  {
      callback = function(args)
           if(vim.bo[args.buf].buftype == "terminal") then
              vim.bo[args.buf].buflisted = false
          end
      end
})

-- Recursive dump file
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

