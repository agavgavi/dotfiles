local path = "/home/andg/.pyenv/shims/python3"
require("dap-python").setup(path, { include_configs = false })

local dap = require("dap")
dap.providers.configs['dap.launch.json'] = function ()
  return {}
end

local py_configs = dap.configurations.python or {}
dap.configurations.python = py_configs
local xml_configs = dap.configurations.xml or {}
dap.configurations.xml = xml_configs
local js_configs = dap.configurations.javascript or {}
dap.configurations.javascript = js_configs

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
  local filter = string.format("-does_%s", name);
  return {filter}
  -- return {filter, '--log-sql'};
end;

local function get_args_bin(postfix)
  postfix = postfix or ""
  local prompt = string.format("Select a Database%s",postfix)
  return coroutine.create(function(dap_run_co)
    local items = get_database_tables()
    if items == nil then
      coroutine.close(dap_run_co)
    elseif #items == 1 then
      coroutine.resume(dap_run_co, get_name(items[1]))
    else
      vim.ui.select(items, { prompt = prompt, label = 'Select Database: ' }, function(choice)
        if choice == nil then
          coroutine.resume(dap_run_co, dap.ABORT)
        else
          coroutine.resume(dap_run_co, get_name(choice));
        end
      end)
    end
  end)
end;

local function get_args_iap()
  return coroutine.create(function(dap_run_co)
    local intermediate_co = coroutine.create(function(args)
      if args == dap.ABORT then
        coroutine.resume(dap_run_co, dap.ABORT)
      else
        coroutine.resume(dap_run_co, {args[1], '-c/home/andg/.odoorc-iap'})
      end
    end)

    local bin_co = get_args_bin(" (IAP)")
    coroutine.resume(bin_co, intermediate_co)
  end)
end;

local odoo_config = {
  type = 'python',
  justmycode = false,
  request = 'launch',
  name = 'Launch Odoo Bin',
  args = get_args_bin,
  program = '/home/andg/Dev/src/odoo/odoo-bin',
  pythonPath = path,
  console = 'integratedTerminal'
};

local iap_config = {
  type = 'python',
  justmycode = false,
  request = 'launch',
  name = 'Launch Odoo IAP',
  args = get_args_iap,
  program = '/home/andg/Dev/src/iap/odoo-18.0/odoo-bin',
  pythonPath = path,
  console = 'integratedTerminal'
};

local workspace_config = odoo_config
if vim.fn.getcwd():match("iap") then
  workspace_config = iap_config
end

for _, value in ipairs({py_configs, xml_configs, js_configs}) do
  table.insert(value, workspace_config)
end
