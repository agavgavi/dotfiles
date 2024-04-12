local M = {}

M.dap = {
  plugin = true,
  n = {
    ["<F5>"] = {function() require('dap').continue() end, "Start Debugging"},
    ["<F10>"] = {function() require('dap').step_over() end, "Step Over"},
    ["<F11>"] = {function() require('dap').step_into() end, "Step Into"},
    ["<S-F11>"] = {function() require('dap').step_out() end, "Step Out"},
    ["<F9>"] = {function() require('persistent-breakpoints.api').toggle_breakpoint() end, "Toggle Breakpoint"},
    ["<F8>"] = {function() require('persistent-breakpoints.api').set_conditional_breakpoint() end, "Create Conditional Breakpoint"}
  }
}

M.telescope ={
  plugin = true,
  n = {
    ["<leader>fe"] = { "<cmd> Telescope file_browser path=%:p:h select_buffer=true <CR>", "File Browser" },
    ["<leader>fs"] = {function() require("telescope-live-grep-args.shortcuts").grep_word_under_cursor() end, "Find Under Cursor"},
    ["<leader>gt"] = { "<cmd> Telescope git_status use_file_path=true <CR>", "Git Status" }
  },
  v = {
    ["<leader>fs"] = {function() require("telescope-live-grep-args.shortcuts").grep_visual_selection() end, "Find Under Cursor"}

  }
}

vim.keymap.set('n', '<S-ScrollWheelDown>', 'z5l', { desc = 'Horizontal Scroll Right' })
vim.keymap.set('n', '<S-ScrollWheelUp>', 'z5h', { desc = 'Horizontal Scroll Left' })

return M
