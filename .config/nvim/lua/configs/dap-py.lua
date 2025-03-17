local path = "~/.local/share/nvim/mason/packages/debugpy/venv/bin/python"
require("dap-python").setup(path, { include_configs = false })

local dap = require("dap")
local py_configs = dap.configurations.python or {}
dap.configurations.python = py_configs
local xml_configs = dap.configurations.xml or {}
dap.configurations.xml = xml_configs
local js_configs = dap.configurations.js or {}
dap.configurations.js = js_configs
local tree_configs = dap.configurations.NvimTree or {}
dap.configurations.NvimTree = tree_configs

local function get_database_tables()
  local handle = io.popen("python3 ~/Dev/support/scripts/configs/getDBS.py")
  if handle == nil then return end

  local result = handle:read("*a")
  local lines = {}

  for s in result:gmatch("[^\r\n]+") do
    table.insert(lines, s)
  end

  handle:close()
  return lines
end;

local function get_name(database)
  local name, _ = database:match"^(.+) (.+)";
  local filter = string.format("--db-filter=^oes_%s$", name);
  return {filter, "--dev=reload,xml"};
end;

local function get_args_bin()
  return coroutine.create(function(dap_run_co)
    local items = get_database_tables()
    if items == nil then
      coroutine.close(dap_run_co)
    elseif #items == 1 then
      coroutine.resume(dap_run_co, get_name(items[1]))
    else
      vim.ui.select(items, { prompt = "Select a Database:", label = 'Select Datatabse: ' }, function(choice)
        if choice == nil then
          coroutine.resume(dap_run_co, dap.ABORT)
        else
          coroutine.resume(dap_run_co, get_name(choice));
        end
      end)
    end
  end)
end;

local odoo_config = {
  type = 'python',
  justmycode = false,
  request = 'launch',
  name = 'Launch Odoo Bin',
  args = get_args_bin,
  program = '/home/andg/Dev/src/odoo/odoo-bin',
  pythonPath = '/home/andg/.pyenv/shims/python3',
  console = 'integratedTerminal'
};

table.insert(py_configs, odoo_config)
table.insert(xml_configs, odoo_config)
table.insert(js_configs, odoo_config)
table.insert(tree_configs, odoo_config)
