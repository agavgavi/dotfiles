local M = {}

M.dap = {
  plugin = true,
  n = {
    ["<F5>"] = { function() require('dap').continue() end, "Start Debugging" },
    ["<F10>"] = { function() require('dap').step_over() end, "Step Over" },
    ["<F11>"] = { function() require('dap').step_into() end, "Step Into" },
    ["<S-F11>"] = { function() require('dap').step_out() end, "Step Out" },
    ["<F9>"] = { function() require('persistent-breakpoints.api').toggle_breakpoint() end, "Toggle Breakpoint" },
    ["<F8>"] = { function() require('persistent-breakpoints.api').set_conditional_breakpoint() end, "Create Conditional Breakpoint" }
  }
}

M.cmp = {
  plugin = true,
  n = {
    ["<leader>tt"] = {
      function()
        vim.b.toggle_cmp = not vim.b.toggle_cmp
        require('cmp').setup.buffer { enabled = not vim.b.toggle_cmp }
      end,
      "Toggle Autocompletion CMP",
    },

  }
}

M.telescope = {
  plugin = true,
  n = {
    ["<leader>fe"] = { "<cmd> Telescope file_browser path=%:p:h select_buffer=true <CR>", "File Browser" },
    ["<leader>fs"] = { function() require("telescope-live-grep-args.shortcuts").grep_word_under_cursor() end, "Find Under Cursor" },
    ["<leader>gt"] = { "<cmd> Telescope git_status use_file_path=true <CR>", "Git Status" },
    ["<leader>cm"] = { "<cmd> Telescope git_commits use_file_path=true <CR>", "Git commits" }
  },
  v = {
    ["<leader>fs"] = { function() require("telescope-live-grep-args.shortcuts").grep_visual_selection() end, "Find Under Cursor" }

  }
}

local generate_dnd_string = function()
  local template = "----------------Session X: Y----------------"
  package.path = '/home/agavgavi/.config/nvim/lua/custom/?.lua;' .. package.path
  local ini_data = require('LIP').load('/home/agavgavi/Dev/test.ini')
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local filename = vim.fn.expand('%:t:r')
  if (ini_data.SessionInfo[filename] == nil) then
    ini_data.SessionInfo[filename] = 0
  end

  local number = ini_data.SessionInfo[filename]
  ini_data.SessionInfo[filename] = number + 1
  require('LIP').save('/home/agavgavi/Dev/test.ini', ini_data)

  template = template:gsub("Y", os.date('%Y-%m-%d')):gsub("X", number)
  local lines = { template, "" }
  vim.api.nvim_buf_set_lines(0, row, row, true, lines)
end

vim.keymap.set('n', '<A-j>', generate_dnd_string, { noremap = true, silent = true, desc = 'Insert DnD String to file' })

vim.keymap.set('n', '<S-ScrollWheelDown>', 'z5l', { desc = 'Horizontal Scroll Right' })
vim.keymap.set('n', '<S-ScrollWheelUp>', 'z5h', { desc = 'Horizontal Scroll Left' })
vim.keymap.set('n', '<A-u>',
  function()
    require('dapui').float_element('repl')
  end, { desc = 'Toggle REPL' })
return M
