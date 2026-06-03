local M = {}

-- Recursive dump helper
function M.dump(o)
  if type(o) == "table" then
    local left = "{ "
    for k, v in pairs(o) do
      if type(k) ~= "number" then
        k = '"' .. k .. '"'
      end
      left = left .. "[" .. k .. "] = " .. M.dump(v) .. ","
    end
    return left .. "} "
  else
    return tostring(o)
  end
end

-- Open current file/line in GitHub
function M.open_in_github(blame)
  blame = blame or false
  local file_path = vim.fn.expand "%:p"
  local line_num = vim.api.nvim_win_get_cursor(0)[1]

  if file_path == "" then
    print "No file is currently open"
    return
  end

  local file_dir = vim.fn.fnamemodify(file_path, ":h")
  local original_cwd = vim.uv.cwd()
  vim.fn.chdir(file_dir)

  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if not git_root or git_root == "" then
    print "Not a git repository"
    vim.fn.chdir(original_cwd)
    return
  end

  local branch_name = vim.fn.systemlist("git rev-parse --abbrev-ref HEAD")[1]
  local first_remote = branch_name:find "-andg" and "dev" or "origin"
  local second_remote = first_remote == "dev" and "origin" or "dev"

  local origin_url = vim.fn.systemlist("git config --get remote." .. first_remote .. ".url")[1]
  if not origin_url or origin_url == "" then
    origin_url = vim.fn.systemlist("git config --get remote." .. second_remote .. ".url")[1]
  end

  if not origin_url or origin_url == "" then
    print "No remote found"
    vim.fn.chdir(original_cwd)
    return
  end

  local repo_url = origin_url:gsub("git@github.com[^:]*:", "https://github.com/"):gsub("%.git$", "")
  local relative_path = file_path:sub(#git_root + 2)
  local url_page = blame and "/blame/" or "/blob/"
  local github_url = string.format("%s%s%s/%s#L%d", repo_url, url_page, branch_name, relative_path, line_num)

  vim.fn.system("open " .. vim.fn.shellescape(github_url))
  vim.fn.chdir(original_cwd)
  print("Opened GitHub: " .. github_url)
end

-- Generate DnD Session String
function M.generate_dnd_string()
  local template = "----------------Session X: Y----------------"
  local lip = require "LIP"
  local ini_path = vim.fn.expand "~" .. "/Dev/test.ini"

  -- Ensure directory exists for the ini file
  vim.fn.mkdir(vim.fn.fnamemodify(ini_path, ":h"), "p")

  local ini_data = {}
  if vim.uv.fs_stat(ini_path) then
    ini_data = lip.load(ini_path)
  end

  ini_data.SessionInfo = ini_data.SessionInfo or {}
  local filename = vim.fn.expand "%:t:r"
  local number = ini_data.SessionInfo[filename] or 0

  ini_data.SessionInfo[filename] = number + 1
  lip.save(ini_path, ini_data)

  local res = template:gsub("Y", os.date "%Y-%m-%d"):gsub("X", number)
  local row = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_buf_set_lines(0, row, row, true, { res, "" })
end

return M
