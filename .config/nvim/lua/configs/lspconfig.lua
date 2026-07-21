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

-- name -> vim.lsp.config() overrides
local servers = {
  -- everything protocol-shaped (handlers, restart, utf-16 caps, filetypes)
  -- comes from the odoo-neovim plugin; only personal overrides live here.
  odoo_ls = {
    -- test builds: swap the binary, then :OdooLs restart
    -- cmd = { '/home/andg/Dev/archived/odoo-ls/server/target/release/odoo_ls_server', '--config-path', '/home/andg/Dev/odools.toml' },
    -- --config-path pins the config regardless of launch dir (the server's
    -- own discovery walks up from root_dir, which would miss ~/Dev).
    cmd = { 'odoo_ls_server', '--config-path', '/home/andg/Dev/odools.toml' },
    -- LOAD-BEARING: the server only fully re-analyzes MODIFIED buffers that
    -- live under a workspace folder (else they degrade to Any/dead tokens on
    -- the first edit, permanently). The derived workspace folder from this
    -- root covers odoo, enterprise AND ad-hoc task worktrees, and the
    -- constant root keeps every buffer on ONE client/server instance.
    root_dir = '/home/andg/Dev',
    -- NvChad's `vim.lsp.config("*", ...)` on_init nils semanticTokensProvider
    -- on every client; override with a no-op so odools' semantic tokens survive.
    on_init = function() end,
    settings = {
      Odoo = {
        selectedProfile = 'Custom Setup', -- must match a profile in odools.toml
      }
    },
  },
  ruff = {
    -- odoo_ls is utf-16-only (lemminx coexistence); pin ruff to utf-16 too so
    -- python buffers don't mix position encodings (checkhealth vim.lsp warning).
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
}

vim.lsp.enable(plain)
for name, opts in pairs(servers) do
  vim.lsp.config(name, opts)
  vim.lsp.enable(name)
end
