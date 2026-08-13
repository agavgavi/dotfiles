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


dap.defaults.fallback.exceptions_breakpoints = {}

local LIST_QUERY = "SELECT datname FROM pg_database WHERE datname LIKE 'oes_%' ORDER BY datname"
-- Long bracket: no escape processing, so `\d` reaches postgres intact.
local VERSION_QUERY =
  [[select replace((regexp_matches(latest_version, '^\d+\.\d+|^saas~\d+\.\d+|saas~\d+'))[1], '~', '-') from ir_module_module where name='base']]

--- Lists oes_* databases with versions off the UI thread, calling on_done(items|nil, err).
local function get_database_tables(on_done)
  local function done(items, err)
    -- vim.system callbacks are a fast event context; the API needs the main loop.
    vim.schedule(function() on_done(items, err) end)
  end

  vim.system({ "psql", "-tAqX", "-d", "postgres", "-c", LIST_QUERY }, { text = true }, function(list)
    if list.code ~= 0 then
      return done(nil, list.stderr)
    end

    local dbs = {}
    for db in list.stdout:gmatch("oes_(%S+)") do
      table.insert(dbs, db)
    end
    if #dbs == 0 then
      return done({})
    end

    local script = {}
    for _, db in ipairs(dbs) do
      table.insert(script, string.format("\\c oes_%s\nselect '%s|' || (%s);", db, db, VERSION_QUERY))
    end

    vim.system(
      { "psql", "-tAqX", "-d", "postgres", "-f", "-" },
      { stdin = table.concat(script, "\n"), text = true },
      function(res)
        -- Unreachable db, or no ir_module_module: no row, falls back to N/A.
        local versions = {}
        for db, version in (res.stdout or ""):gmatch("([^|\n]+)|([^\n]+)") do
          versions[db] = version
        end

        local items = {}
        for _, db in ipairs(dbs) do
          local description = string.format("(%s)", versions[db] or "N/A")
          table.insert(items, {
            label = db,
            value = db,
            description = description,
            text = db .. " " .. description,
          })
        end
        done(items)
      end
    )
  end)
end;

local function get_name(item)
  local filter = string.format("-does_%s", item.value);
  return {filter}
  -- return {filter, '--log-sql'};
end;

local function format_db_item(item)
  if item.description ~= "" then
    return string.format("%s %s", item.label, item.description)
  end
  return item.label
end;

-- Picks the database, then appends the setup's own `-c <odoorc>` if it has one.
local function get_args(setup)
  local prompt = string.format(
    "Select a Database%s",
    setup.prompt_label and string.format(" (%s)", setup.prompt_label) or ""
  )
  return coroutine.create(function(dap_run_co)
    local function finish(item)
      local args = get_name(item)
      if setup.odoorc then
        table.insert(args, '-c' .. setup.odoorc)
      end
      coroutine.resume(dap_run_co, args)
    end

    local function abort(msg)
      vim.notify(msg, vim.log.levels.ERROR)
      coroutine.resume(dap_run_co, dap.ABORT)
    end

    get_database_tables(function(items, err)
      if items == nil then
        return abort("Could not list databases: " .. (err or "psql failed"))
      end
      if #items == 0 then
        return abort("No oes_* databases found.")
      end
      if #items == 1 then
        return finish(items[1])
      end
      vim.ui.select(items, { prompt = prompt, format_item = format_db_item }, function(choice)
        if choice == nil then
          coroutine.resume(dap_run_co, dap.ABORT)
        else
          finish(choice)
        end
      end)
    end)
  end)
end;

local odoo_setups = require "configs.odoo_setups"

-- Resolve at LAUNCH time: sourced once on ft="python", so a local would freeze at that cwd.
local workspace_config = {
  type = 'python',
  justmycode = false,
  request = 'launch',
  -- Read before expansion runs, so this is the one field that cannot defer.
  name = 'Launch Odoo',
  args = function() return get_args(odoo_setups.current()) end,
  program = function() return odoo_setups.current().program end,
  pythonPath = path,
  console = 'integratedTerminal',
};

for _, value in ipairs({py_configs, xml_configs, js_configs}) do
  table.insert(value, workspace_config)
end
