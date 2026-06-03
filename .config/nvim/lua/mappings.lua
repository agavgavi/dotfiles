require "nvchad.mappings"
local map = vim.keymap.set
local nomap = vim.keymap.del


map('n', '<leader>rs', function() require("persistence").load() end, {desc = 'persistance load local session'})
map('n', '<leader>rS', function() require("persistence").select() end, {desc = 'persistance select session'})

-- tabs
map("n","<leader>tb", "<cmd> tabnew <CR>", { desc = "buffer new tab"})

nomap("n", "<leader>e")
nomap("n", "<C-n>")
nomap("n", "<leader>fa")
nomap("n", "<leader>fb")
nomap("n", "<leader>ff")
nomap("n", "<leader>fo")

-- dap
map("n", "<F17>", "<cmd> DapTerminate <CR>", { desc = "dap stop debugging" })
map("n", "<F5>", "<cmd> DapContinue <CR>", { desc = "dap start debugging" })
map("n", "<F10>", "<cmd> DapStepOver <CR>", { desc = "dap step over" })
map("n", "<F11>", "<cmd> DapStepInto <CR>", { desc = "dap step into" })
map("n", "<F23>", "<cmd> DapStepOut <CR>", { desc = "dap step out" })
map("n", "<F9>", function() require('persistent-breakpoints.api').toggle_breakpoint() end, { desc = "dap toggle breakpoint" })
map("n", "<F8>", function() require('persistent-breakpoints.api').set_conditional_breakpoint() end, { desc = "dap toggle conditional breakpoint" })
map('n', '<A-o>', "<cmd> DapViewToggle <CR>", { desc = 'dap toggle UI' })
map("n", "K", function()  vim.lsp.buf.hover { border = "rounded" } end, { desc = "LSP show details", silent = true })

-- picker (snacks)
local Snacks = require('snacks');

map("n", "<leader>f<CR>", Snacks.picker.resume, { desc = 'picker resume previous'})
map("n", "<leader>fd", Snacks.picker.lsp_symbols, { desc = "picker find methods" })
map("n", "<leader>fD", function() Snacks.picker.grep({title="Search Dependencies", glob="**__manifest__.py"}) end, { desc = "picker find dependencies" })
map("n", "<leader>fe", function() Snacks.picker.explorer({layout = {preset = 'default', preview=true}, cwd=vim.fn.expand('%:p:h'), auto_close=true}) end, { desc = "picker file browser" })
map("n", "<leader>fF", function() Snacks.picker.files({ hidden = true, ignored = true }) end, { desc = "picker find files (no ignore)" })
map("n", "<leader>fh", Snacks.picker.help, { desc = "picker help page" })
map("n", "<leader>fi", function() Snacks.picker.grep({title = "Live Grep (All Files)", hidden = true, ignored = true }) end, { desc = "picker grep all" })
map("n", "<leader>fI", function() Snacks.picker.grep_word({title = "Live Grep (All Files)", hidden = true, ignored = true }) end, { desc = "picker grep all under cursor" })
map("n", "<leader>fm", function() Snacks.picker.grep({title="Search Models and Inherited", search="^\\s+(_name|_inherit).+=.+"}) end, { desc = "picker find models" })
map("n", "<leader>fM", function() Snacks.picker.grep({title="Search Base Models", search="^\\s+_name.+=.+"}) end, { desc = "picker find base models" })
map("n", "<leader>fo", Snacks.picker.smart, { desc = "picker smart finder" })
map("n", "<leader>fr", Snacks.picker.lsp_references, { desc = "picker list references" })
map("n", "<leader>fs", Snacks.picker.grep_word, { desc = "picker grep under cursor" })
map("v", "<leader>fs", function() Snacks.picker.grep_word({ mode = "v" }) end, { desc = "picker grep visual selection" })
map("n", "<leader>fv", function() Snacks.picker.grep({title="Search Models in Views", search="name=.model.>"}) end, { desc = "picker find view by model" })
map("n", "<leader>fw", Snacks.picker.grep, { desc = "picker live grep" })
map("n", "<leader>fz", Snacks.picker.lines, { desc = "picker find in current buffer" })
map("n", "<leader>ma", Snacks.picker.marks, { desc = "picker find marks" })

map("n", "<leader>gt", function() Snacks.picker.git_status({layout = {preset = 'default'}, cwd=vim.fn.expand('%:p:h')}) end, { desc = "picker git status" })
map("n", "<leader>gl", function() Snacks.picker.git_log({layout = {preset = 'default'}, cwd=vim.fn.expand('%:p:h')}) end, { desc = "picker git commits" })

-- gitsigns
map("n", "<leader>rh", "<cmd> Gitsigns reset_hunk <CR>", { desc = "git reset hunk"})
map("n", "<leader>ph", "<cmd> Gitsigns preview_hunk <CR>", { desc = "git preview hunk"})
map("n", "<leader>gb", "<cmd> Gitsigns blame_line <CR>", { desc = "git blame line"})
local gitsigns = require('gitsigns');
map('n', ']c', function()
  if vim.wo.diff then
    vim.cmd.normal({']c', bang = true})
  else
    gitsigns.nav_hunk('next')
  end
end, { desc = "git next hunk"})

map('n', '[c', function()
  if vim.wo.diff then
    vim.cmd.normal({'[c', bang = true})
  else
    gitsigns.nav_hunk('prev')
  end
end, { desc = "git previous hunk"})

local utils = require "utils"

map("n", "<leader>go", function() utils.open_in_github(false) end, { desc = "git open in GitHub"})
map("n", "<leader>gO", function() utils.open_in_github(true) end, { desc = "git blame in GitHub"})

map('n', '<A-j>', utils.generate_dnd_string, { noremap = true, silent = true, desc = 'general Insert DnD String to file' })

map('n', '<S-ScrollWheelDown>', 'z5l', { desc = 'move Horizontal Scroll Right' })
map('n', '<S-ScrollWheelUp>', 'z5h', { desc = 'move Horizontal Scroll Left' })
