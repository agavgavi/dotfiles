require "nvchad.mappings"
local map = vim.keymap.set
local nomap = vim.keymap.del

local lga_shortcuts = require("telescope-live-grep-args.shortcuts")
local snacks = require('snacks')
-- tabs
map("n","<leader>tb", "<cmd> tabnew <CR>", { desc = "buffer new tab"})

-- snacks
map("n", "<leader>e", function()
  if snacks.picker.get({ source = "explorer" })[1] == nil then
    snacks.picker.explorer()
  elseif snacks.picker.get({ source = "explorer" })[1]:is_focused() == true then
    snacks.picker.explorer()
  elseif snacks.picker.get({ source = "explorer" })[1]:is_focused() == false then
    snacks.picker.get({ source = "explorer" })[1]:focus()
  end
end,
  { desc = 'snacks explorer focus toggle '}
)
nomap("n", "<C-n>")

-- dap
map("n", "<F17>", "<cmd> DapTerminate <CR>", { desc = "dap stop debugging" })
map("n", "<F5>", "<cmd> DapContinue <CR>", { desc = "dap start debugging" })
map("n", "<F10>", "<cmd> DapStepOver <CR>", { desc = "dap step over" })
map("n", "<F11>", "<cmd> DapStepInto <CR>", { desc = "dap step into" })
map("n", "<F23>", "<cmd> DapStepOut <CR>", { desc = "dap step out" })
map("n", "<F9>", function() require('persistent-breakpoints.api').toggle_breakpoint() end, { desc = "dap toggle breakpoint" })
map("n", "<F8>", function() require('persistent-breakpoints.api').set_conditional_breakpoint() end, { desc = "dap toggle conditional breakpoint" })
map('n', '<A-o>', "<cmd> DapViewToggle <CR>", { desc = 'dap toggle UI' })
-- cmp
map("n", "<leader>tt", function()
  vim.b.toggle_cmp = not vim.b.toggle_cmp
  require('cmp').setup.buffer { enabled = not vim.b.toggle_cmp }
end, { desc = "cmp toggle autocompletion" })

-- telescope
map("n", "<leader>fe", "<cmd> Telescope file_browser path=%:p:h select_buffer=true <CR>", { desc = "telescope file browser" })
map("n", "<leader>fs", lga_shortcuts.grep_word_under_cursor, { desc = "telescope find under cursor" })
map("v", "<leader>fs", lga_shortcuts.grep_visual_selection, { desc = "telescope find under cursor" })

map("n", "<leader>fI", function() lga_shortcuts.grep_word_under_cursor({postfix = ' -F --no-ignore'}) end,
  { desc = "telescope find all under cursor" })
map("n", "<leader>fi", function() require("telescope.builtin").live_grep({prompt_title = 'Live Grep (All Files)', additional_args = {'--no-ignore'}}) end,
  { desc = "telescope find all" })

map("n", "<leader>fm", "<cmd>Telescope live_grep default_text=^\\s+(_name|_inherit).+=.+ <CR>", { desc = "telescope find models" })
map("n", "<leader>fM", "<cmd>Telescope live_grep default_text=^\\s+_name.+=.+ <CR>", { desc = "telescope find models" })
map("n", "<leader>fv", "<cmd>Telescope live_grep default_text=name=.model.> <CR>", { desc = "telescope find view by model" })
map("n", "<leader>fd", "<cmd>Telescope lsp_document_symbols <CR>", { desc = "telescope find methods" })
map("n", "<leader>cm", "<cmd>Telescope git_commits use_file_path=true <CR>", { desc = "telescope git commits" })
map("n", "<leader>gt", "<cmd> Telescope git_status use_file_path=true <CR>", { desc = "telescope git status" })
map("n", "<leader>fr", "<cmd> Telescope lsp_references <CR>", { desc = "telescope list references" })
map("n", "<leader>f<CR>", "<cmd> Telescope resume <CR>", { desc = 'telescope resume previous '})

-- gitsigns
map("n", "<leader>rh", "<cmd> Gitsigns reset_hunk <CR>", { desc = "git reset hunk"})
map("n", "<leader>ph", "<cmd> Gitsigns preview_hunk <CR>", { desc = "git preview hunk"})
map("n", "<leader>gb", "<cmd> Gitsigns blame_line <CR>", { desc = "git blame line"})


map("n", "<leader>go", function()
  local file_path = vim.fn.expand("%:p")
  local line_num, col_num = unpack(vim.api.nvim_win_get_cursor(0))
  if file_path == "" then
    print("No file is currently open")
    return
  end

  -- Get the file's directory
  local file_dir = vim.fn.fnamemodify(file_path, ":h")

  -- Save current working directory to restore later
  local original_cwd = vim.fn.getcwd()

  -- Change to the file's directory before running git commands
  vim.fn.chdir(file_dir)

  -- Get the root directory of the git repository from the file's location
  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if not git_root or git_root == "" then
    print("Could not determine the root directory for the GitHub repository")
    vim.fn.chdir(original_cwd) -- Restore original directory
    return
  end

  -- Get the current branch name
  local branch_name = vim.fn.systemlist("git rev-parse --abbrev-ref HEAD")[1]
  if not branch_name or branch_name == "" then
    print("Could not determine the current branch name")
    vim.fn.chdir(original_cwd) -- Restore original directory
    return
  end

  local first_remote = ""
  local second_remote = ""
  if string.find(branch_name, '-andg') then
    first_remote = "dev"
    second_remote = "origin"
  else
    first_remote = "origin"
    second_remote = "dev"
  end
  -- Try dev remote first, then fall back to origin
  local remote_url = string.format("git config --get remote.%s.url", first_remote)
  local origin_url = vim.fn.systemlist(remote_url)[1]
  local remote_name = first_remote
  -- If dev remote doesn't exist or doesn't have a URL, try origin
  if not origin_url or origin_url == "" then
    remote_url = string.format("git config --get remote.%s.url", second_remote)
    origin_url = vim.fn.systemlist(remote_url)[1]
    remote_name = second_remote
    if not origin_url or origin_url == "" then
      print("Could not find URL for either dev or origin remote")
      vim.fn.chdir(original_cwd) -- Restore original directory
      return
    end
  end

  -- Convert the origin URL to a GitHub URL
  local repo_url = origin_url:gsub("git@github.com[^:]*:", "https://github.com/"):gsub("%.git$", "")

  -- Extract the relative path from the file path
  local relative_path = file_path:sub(#git_root + 2)

  local github_url = repo_url .. "/blob/" .. branch_name .. "/" .. relative_path .. "#L" .. line_num
  local command = "open " .. vim.fn.shellescape(github_url)

  -- Run the open command
  vim.fn.system(command)

  -- Restore the original working directory
  vim.fn.chdir(original_cwd)

  print("Opened GitHub link for remote '" .. remote_name .. "': " .. github_url)
end, { desc = "git open in GitHub"})

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
