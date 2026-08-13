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

-- enabled with their nvim-lspconfig defaults, no local overrides
local plain = { 'lua_ls', 'bashls', 'html', 'cssls' }

--- ~/Dev first (keeps rootUri) plus the active env, whose odools.toml needs its own walk-up.
local function odoo_ws_folders()
  local folders = { { uri = vim.uri_from_fname('/home/andg/Dev'), name = '/home/andg/Dev' } }
  local setup = require('configs.odoo_setups').current()
  if setup and setup.root and setup.root ~= '/home/andg/Dev' then
    table.insert(folders, { uri = vim.uri_from_fname(setup.root), name = setup.odools_profile })
  end
  return folders
end


-- name -> vim.lsp.config() overrides
local servers = {
  -- Everything protocol-shaped comes from the odoo-neovim plugin, leaving personal overrides here.
  odoo_ls = {
    -- --config-path pins ~/Dev/odools.toml, read with no current ws (bare ${workspaceFolder} dies).
    cmd = { '/home/andg/Dev/archived/odoo-ls/server/target/release/odoo_ls_server', '--config-path', '/home/andg/Dev/odools.toml' },
    -- cmd = { 'odoo_ls_server', '--config-path', '/home/andg/Dev/odools.toml' }, -- released build
    -- LOAD-BEARING: buffers outside a workspace folder decay to Any on edit, one root = one client.
    root_dir = '/home/andg/Dev',
    -- Override NvChad's on_init, which nils semanticTokensProvider, and mirror the sent folders.
    on_init = function(client)
      client.workspace_folders = odoo_ws_folders()
    end,
    -- Resolved at CLIENT-START: a static value would freeze at the cwd this file was sourced with.
    before_init = function(params, config)
      -- Mutate in place: the client already aliased `config.settings`.
      config.settings.Odoo.selectedProfile = require('configs.odoo_setups').current().odools_profile
      params.workspaceFolders = odoo_ws_folders()
    end,
    settings = {
      Odoo = {
        selectedProfile = 'src', -- must match a profile in some odools.toml
      }
    },
  },
  ruff = {
    -- odoo_ls is utf-16-only, so pin ruff too or python buffers mix position encodings.
    capabilities = { general = { positionEncodings = { 'utf-16' } } },
    init_options = {
      settings = {
        configuration = '~/ruff.toml',
        configurationPreference = "filesystemFirst",
      },
    },
  },
  eslint = {
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
  lemminx = {
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
        symbols = {
          enabled = true,
        },
        format = {
          splitAttributes = false
        },
        validation = {
          noGrammar = 'ignore',
        },
      },
    },
  },
}

vim.lsp.enable(plain)
for name, opts in pairs(servers) do
  vim.lsp.config(name, opts)
  vim.lsp.enable(name)
end
