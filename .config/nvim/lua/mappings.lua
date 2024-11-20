require "nvchad.mappings"
local map = vim.keymap.set

-- tabs
map("n","<leader>tb", "<cmd> tabnew <CR>", { desc = "buffer new tab"})


-- dap
map("n", "<F5>", function() require('dap').continue() end, { desc = "dap start debugging" })
map("n", "<F10>", function() require('dap').step_over() end, { desc = "dap step over" })
map("n", "<F11>", function() require('dap').step_into() end, { desc = "dap step into" })
map("n", "<S-F11>", function() require('dap').step_out() end, { desc = "dap step out" })
map("n", "<F9>", function() require('persistent-breakpoints.api').toggle_breakpoint() end, { desc = "dap toggle breakpoint" })
map("n", "<F8>", function() require('persistent-breakpoints.api').set_conditional_breakpoint() end, { desc = "dap toggle conditional breakpoint" })
map('n', '<A-u>', function() require('dapui').float_element('repl') end, { desc = 'dap toggle REPL' })
map('n', '<A-o>', function () require('nvim-tree.api').tree.toggle();require("dapui").toggle(); end, { desc = 'dap toggle UI' })
-- cmp
map("n", "<leader>tt", function()
  vim.b.toggle_cmp = not vim.b.toggle_cmp
  require('cmp').setup.buffer { enabled = not vim.b.toggle_cmp }
end, { desc = "cmp toggle autocompletion" })

-- telescope
map("n", "<leader>fe", "<cmd> Telescope file_browser path=%:p:h select_buffer=true <CR>",
  { desc = "telescope file browser" })
map("n", "<leader>fs", function() require("telescope-live-grep-args.shortcuts").grep_word_under_cursor() end,
  { desc = "telescope find under cursor" })
map("n", "<leader>fi", function() require("telescope-live-grep-args.shortcuts").grep_word_under_cursor({postfix = ' -F --no-ignore'}) end,
  { desc = "telescope find all under cursor" })
map("n", "<leader>fm", function() require("telescope.builtin").live_grep({default_text = "^\\s+(_name|_inherit).+=.+"}) end,
  { desc = "telescope find models" })
map("n", "<leader>cm", "<cmd>Telescope git_commits use_file_path=true <CR>", { desc = "telescope git commits" })
map("n", "<leader>gt", "<cmd> Telescope git_status use_file_path=true <CR>", { desc = "telescope git status" })
map("v", "<leader>fs", function() require("telescope-live-grep-args.shortcuts").grep_visual_selection() end,
  { desc = "telescope find under cursor" })
map("n", "<leader>fr", "<cmd> Telescope lsp_references <CR>", { desc = "telescope list references" })
map("n", "<leader>f<CR>", "<cmd> Telescope resume <CR>", { desc = 'telescope resume previous '})
-- gitsigns
map("n", "<leader>rh", "<cmd> Gitsigns reset_hunk <CR>", { desc = "git reset hunk"})
map("n", "<leader>ph", "<cmd> Gitsigns preview_hunk <CR>", { desc = "git preview hunk"})
map("n", "<leader>gb", "<cmd> Gitsigns blame_line <CR>", { desc = "git blame line"})


-- menu
map({'n', 'v'}, "<RightMouse>", function ()
  vim.cmd.exec '"normal! \\<RightMouse>"'
  local options = vim.bo.ft == "NvimTree" and "nvimtree" or "default"
  require("menu").open(options, { mouse = true, border = true })
end
)

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

map('n', '<A-j>', generate_dnd_string, { noremap = true, silent = true, desc = 'general Insert DnD String to file' })

map('n', '<S-ScrollWheelDown>', 'z5l', { desc = 'move Horizontal Scroll Right' })
map('n', '<S-ScrollWheelUp>', 'z5h', { desc = 'move Horizontal Scroll Left' })
