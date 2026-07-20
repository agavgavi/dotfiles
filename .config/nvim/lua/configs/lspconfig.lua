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


function andg_list_workspace_folders()
  for _, client in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
    for _, folder in pairs(client.workspace_folders or {}) do
      print(folder.name, client.name)
    end
  end
end

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
  -- everything protocol-shaped (handlers, restart, utf-16 caps, filetypes)
  -- comes from odoo-ls.nvim; only personal overrides live here.
  odools = {
    active = not use_odoo_lsp,
    opts = {
      -- test builds: swap the binary, then :Odools restart
      -- cmd = { '/home/andg/Dev/archived/odoo-ls/server/target/release/odoo_ls_server', '--config-path', '/home/andg/Dev/odools.toml' },
      -- --config-path pins the config regardless of launch dir (the server's
      -- own discovery walks up from root_dir, which would miss ~/Dev).
      cmd = { 'odoo_ls_server', '--config-path', '/home/andg/Dev/odools.toml' },
      root_dir = '/home/andg/.local/share/nvim/odoo',
      -- NvChad's `vim.lsp.config("*", ...)` on_init nils semanticTokensProvider
      -- on every client; override with a no-op so odools' semantic tokens survive.
      on_init = function() end,
      settings = {
        Odoo = {
          selectedProfile = 'Custom Setup', -- must match a profile in odools.toml
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
      -- lemminx sends the spec-CORRECT spelling `unregistrations`, but the LSP
      -- spec (and nvim's default handler) use the misspelled `unregisterations`,
      -- so nvim reads nil and ipairs() errors (neovim #30985). Normalize the
      -- field, then delegate to the default handler.
      handlers = {
        ['client/unregisterCapability'] = function(err, params, ctx)
          if type(params) == 'table' and params.unregisterations == nil then
            params.unregisterations = params.unregistrations or {}
          end
          return vim.lsp.handlers['client/unregisterCapability'](err, params, ctx)
        end,
      },
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
