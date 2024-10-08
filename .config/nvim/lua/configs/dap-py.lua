local path = "~/.local/share/nvim/mason/packages/debugpy/venv/bin/python"
require("dap-python").setup(path, { include_configs = false })

local dap = require("dap")
local configs = dap.configurations.python or {}
dap.configurations.python = configs


local function get_database_tables()
  local handle = io.popen("python3 ~/Dev/odoo/support/scripts/configs/getDBS.py")
  if handle == nil then return end

  local result = handle:read("*a")
  local lines = {}

  for s in result:gmatch("[^\r\n]+") do
    table.insert(lines, s)
  end

  handle:close()
  return lines
end;

local function get_args_bin()
  return coroutine.create(function(dap_run_co)
    local items = get_database_tables()
    if items == nil then
      coroutine.close(dap_run_co)
    elseif #items == 1 then
      local filter = string.format("--db-filter=^oes_%s$", items[1]);
      coroutine.resume(dap_run_co, { filter, '--dev=reload,xml' })
    else
      vim.ui.select(items, { prompt = "Select a Database:", label = 'Select Datatabse: ' }, function(choice)
        if choice == false then
          coroutine.close(dap_run_co)
        end
        local filter = string.format("--db-filter=^oes_%s$", choice);
        coroutine.resume(dap_run_co, { filter, '--dev=reload,xml' })
      end)
    end
  end)
end;

local function get_args_oe()
  return coroutine.create(function(dap_run_co)
    local items = get_database_tables()
    if items == nil then
      coroutine.close(dap_run_co)
    elseif #items == 1 then
      coroutine.resume(dap_run_co, { 'start', items[1], '--vscode', '--dev=xml' })
    else
      vim.ui.select(items, { prompt = "Select a Database:", label = 'Select Datatabse: ' }, function(choice)
        if choice == false then
          coroutine.close(dap_run_co)
        end
        coroutine.resume(dap_run_co, { 'start', choice, '--vscode', '--dev=xml' })
      end)
    end
  end)
end;

table.insert(configs, {
  type = 'python',
  justmycode = false,
  request = 'launch',
  name = 'Launch Odoo Bin',
  args = get_args_bin,
  program = '/home/andg/Dev/odoo/src/odoo/odoo-bin',
  pythonPath = '/home/andg/.pyenv/shims/python3',
  console = 'integratedTerminal'
})

-- table.insert(configs, {
--   type = 'python',
--   justmycode = false,
--   request = 'launch',
--   name = 'Launch OE-Support',
--   args = get_args_oe,
--   program = '/home/andg/Dev/odoo/support/support-tools/oe-support.py',
--   pythonPath = '/home/andg/.pyenv/shims/python3',
--   console = 'integratedTerminal'
-- })
local xml_configs = dap.configurations.xml or {}
dap.configurations.xml = xml_configs
table.insert(xml_configs, {
  type = 'python',
  request = 'launch',
  name = 'Launch OE-Support',
  args = get_args,
  program = '/home/andg/Dev/odoo/support/support-tools/oe-support.py',
  pythonPath = '/home/andg/.pyenv/shims/python3',
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
