local path = "~/.local/share/nvim/mason/packages/debugpy/venv/bin/python"
require("dap-python").setup(path,{include_configs = false})

local dap = require("dap")
local configs = dap.configurations.python or {}
dap.configurations.python = configs


local function get_database_tables()
  local handle = io.popen("python3 ~/Dev/Odoo/support/scripts/configs/getDBS.py")
  if handle == nil then return end

  local result = handle:read("*a")
  local lines = {}

  for s in result:gmatch("[^\r\n]+") do
    table.insert(lines, s)
  end

  handle:close()
  return lines
end;

local function get_args()
    return coroutine.create(function(dap_run_co)
        local items = get_database_tables()
        vim.ui.select(items, { prompt = "Select a Database:"; label = 'Select Datatabse: '}, function(choice)
          coroutine.resume(dap_run_co, {'start', choice, '--vscode'})
          end)
      end)
end;

table.insert(configs, {
  type = 'python';
  request = 'launch';
  name = 'TEST';
  args = get_args;
  program = '/home/andg/Dev/Odoo/support/support-tools/oe-support.py';
  pythonPath = '/home/andg/.pyenv/shims/python3';
  console = 'integratedTerminal'
})

-- table.insert(configs, {
  -- type = 'python';
  -- request = 'attach';
  -- name = 'Attach Odoo';
  -- connect = function()
    -- return { host = '127.0.0.1', port = 5678 }
  -- end;
-- })

-- require('dap.ext.vscode').json_decode = require'json5'.parse
-- require('dap.ext.vscode').load_launchjs(nil, {})
