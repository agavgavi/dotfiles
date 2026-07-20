local use_odoo_lsp = false

-- Set the log level to info (enable when debugging LSP issues; default is 'warn')
-- vim.lsp.log.set_level('info')
local sev = vim.diagnostic.severity

local signs = { [sev.ERROR] = "󰅙", [sev.WARN] = "", [sev.INFO] = "󰋼", [sev.HINT] = "󰌵" }

local shorter_source_names = {
    ["Lua Diagnostics."] = "Lua",
    ["Lua Syntax Check."] = "Lua",
}

local function diagnostic_format(diagnostic)
    if diagnostic.source and diagnostic.code then
      return string.format(
          "%s %s (%s): %s",
          signs[diagnostic.severity],
          shorter_source_names[diagnostic.source] or diagnostic.source,
          diagnostic.code,
          diagnostic.message
      )
    end
    return string.format(
        "%s %s",
        signs[diagnostic.severity],
        diagnostic.message
    )

end

vim.diagnostic.config({
  virtual_text = false,
  signs = { text = signs },
  virtual_lines = {
    current_line = true,
    format = diagnostic_format,
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- Patch for lemminx/nvim-lspconfig issue: https://github.com/neovim/neovim/issues/30985
local orig_unregister = vim.lsp.client._unregister
vim.lsp.client._unregister = function(self, unregistrations)
  return orig_unregister(self, unregistrations or {})
end

local orig_register = vim.lsp.client._register
vim.lsp.client._register = function(self, registrations)
  return orig_register(self, registrations or {})
end


function andg_list_workspace_folders()
  for _, client in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
    for _, folder in pairs(client.workspace_folders or {}) do
      print(folder.name, client.name)
    end
  end
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.general.markdown = {
  parser = 'marked',
  version = ''
}
-- odools picks utf-8 when offered; lemminx is utf-16 only. Advertise only
-- utf-16 so both clients on an XML buffer agree (checkhealth vim.lsp warning).
capabilities.general.positionEncodings = { 'utf-16' }

-- OdoolS custom notifications: the server fires these, but a stock LSP client
-- silently drops them. Mirrors what the odoo-vscode/zed clients handle.
local odools_state = { pid = nil, config_diagnostics = {} }

local function restart_odools()
  vim.notify('odools: config changed - restarting server…', vim.log.levels.INFO)
  -- Fast path if the command still exists (lspconfig, or a native alias).
  if vim.fn.exists(':LspRestart') == 2 then
    pcall(vim.cmd, 'LspRestart odools')
    return
  end
  -- Native (nvim 0.11+): stop each odools client, then reattach its buffers.
  local clients = vim.lsp.get_clients({ name = 'odools' })
  if vim.tbl_isempty(clients) then
    vim.lsp.enable('odools')  -- not running; (re)enable
    return
  end
  for _, client in ipairs(clients) do
    local bufs = vim.lsp.get_buffers_by_client_id(client.id)
    local config = client.config
    client:stop()
    local timer = assert(vim.uv.new_timer())
    timer:start(0, 100, vim.schedule_wrap(function()
      if not client:is_stopped() then return end  -- wait for the process to exit
      timer:stop()
      timer:close()
      for _, buf in ipairs(bufs) do
        if vim.api.nvim_buf_is_valid(buf) then
          vim.lsp.start(config, { bufnr = buf })
        end
      end
    end))
  end
end

local odools_handlers = {
  ['$Odoo/setPid'] = function(_, r) odools_state.pid = r and r.server_pid end,
  ['$Odoo/loadingStatusUpdate'] = function(_, r)   -- $/progress already feeds fidget
    if r == 'git_locked' then
      vim.notify('odools: git index locked, indexing paused', vim.log.levels.WARN)
    end
  end,
  ['$Odoo/invalid_python_path'] = function()
    vim.notify('odools: bad python_path - Python failed to start; check odools.toml', vim.log.levels.ERROR)
  end,
  ['$Odoo/restartNeeded'] = function() restart_odools() end,
  ['$Odoo/setConfiguration'] = function(_, r)
    odools_state.config_diagnostics = (r and r.diagnostics) or {}
    for _, d in ipairs(odools_state.config_diagnostics) do
      local lvl = (d.severity == 2) and vim.log.levels.ERROR or vim.log.levels.WARN  -- 2=error, 1=warn
      vim.notify('odools config: ' .. (d.message or vim.inspect(d)), lvl)
    end
  end,
  ['$Odoo/diagnostic_config'] = function(_, r)
    if r and r.messages and #r.messages > 0 then
      vim.notify('odools: ' .. table.concat(vim.tbl_map(tostring, r.messages), '\n'), vim.log.levels.INFO)
    end
  end,
  ['Odoo/displayCrashNotification'] = function(_, r)  -- note: NO '$' prefix
    vim.notify('odools crashed:\n' .. ((r and r.crashInfo) or 'unknown'), vim.log.levels.ERROR)
  end,
}

local servers = {
  vtsls = {active = use_odoo_lsp, opts = {}},
  lua_ls = {active = true, opts = {}},
  bashls = {active = true, opts = {}},
  html = {active = true, opts = {}},
  cssls = {active = true, opts = {}},
  odoo_lsp = {
    active = use_odoo_lsp,
    opts = {
      cmd = {'odoo-lsp'},
      filetypes = {'javascript', 'xml', 'python', 'csv'},
      root_markers = '.odoo_lsp'
    }
  },
  odools = {
    active = not use_odoo_lsp,
    opts = {
      -- cmd = { '/home/andg/pr642-build/odoo_ls_server' },
      --cmd = { '/home/andg/Dev/archived/odoo-ls/server/target/release/odoo_ls_server' },
      cmd = {'odoo_ls_server'},
      root_dir = '/home/andg/.local/share/nvim/odoo',
      filetypes = {'python', 'csv', 'xml', 'javascript'},
      workspace_folders = {{
        uri = vim.uri_from_fname(vim.fn.getcwd()),
        name = 'main_folder',
      }},
      capabilities = capabilities,
      handlers = odools_handlers,
      -- NvChad's `vim.lsp.config("*", ...)` on_init nils semanticTokensProvider
      -- on every client; override with a no-op so odools' semantic tokens survive.
      on_init = function() end,
      settings = {
        Odoo = {
          selectedProfile = 'Custom Setup', -- should be the name defined in odools.toml
        }
      },
    }
  },
  ruff = {
    active = true,
    opts = {
      init_options = {
        settings = {
          configuration = '~/ruff.toml',
          configurationPreference = "filesystemFirst",
        },
      },
    },
  },
  pyright = {
    active = use_odoo_lsp,
    opts = {
      settings = {
        pyright = {
          disableOrganizeImports = true,
        },
        python = {
          analysis = {
            ignore = { '*' },
          },
        },
      },
    },
  },
  eslint = {
    active = true,
    opts = {
      cmd = { vim.fn.stdpath('data') .. '/mason/bin/vscode-eslint-language-server', '--stdio' },
      filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
      root_markers = { '.eslintrc.json', '.eslintrc.js', 'eslint.config.js', 'package.json', '.git' },
      settings = {
        useFlatConfig = false,
        format = true,
        validate = 'on',
        run = 'onType',
        workingDirectories = { mode = 'auto' },
        onIgnoredFiles = 'warn',
        options = {
          ignore = false,
          resolvePluginsRelativeTo = '.',
          overrideConfig = {
            extends = { 'plugin:diff/ci' },
          },
        },
      },
    },
  },
  lemminx = {
    active = true,
    opts = {
      settings = {
        xml = {
          -- completion = {
          --   autoCloseTags = true,
          -- },
          symbols = {
            enabled = true,
          },
          format = {
            splitAttributes = false
          },
        },
      },
    },
  },
}

local code_action_priority = { eslint = 1, ruff = 2, vtsls = 5 }
local original_ui_select = vim.ui.select
vim.ui.select = function(items, opts, on_choice)
  if opts and opts.kind == 'codeaction' then
    table.sort(items, function(a, b)
      local an = a.ctx and a.ctx.client_id and vim.lsp.get_client_by_id(a.ctx.client_id)
      local bn = b.ctx and b.ctx.client_id and vim.lsp.get_client_by_id(b.ctx.client_id)
      local pa = code_action_priority[an and an.name] or 99
      local pb = code_action_priority[bn and bn.name] or 99
      if pa ~= pb then return pa < pb end
      return (a.action.title or '') < (b.action.title or '')
    end)
  end
  return original_ui_select(items, opts, on_choice)
end

for name, data in pairs(servers) do
  if data.active then
    local opts = data.opts
    vim.lsp.config(name, opts)
    vim.lsp.enable(name)
  end
end
