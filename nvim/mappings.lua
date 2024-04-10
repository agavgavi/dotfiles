local M = {}
-- vim.keymap.set('n', '<F5>', require 'dap'.continue)
-- vim.keymap.set('n', '<F10>', require 'dap'.step_over)
-- vim.keymap.set('n', '<F11>', require 'dap'.step_into)
-- vim.keymap.set('n', '<F12>', require 'dap'.step_out)
-- vim.keymap.set('n', '<leader>b', require 'dap'.toggle_breakpoint)
-- vim.keymap.set('n', '<leader>B', function()
--   require 'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))
-- end)
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
M.telescope = {
  plugin = true,
  n = {
    ["<leader>fe"] = { "<cmd> Telescope file_browser <CR>", "File Browser" },
    ["<leader>fc"] = {function() require("telescope-live-grep-args.shortcuts").grep_word_under_cursor() end, "Find Under Cursor"}
  }
}

return M
