local use_odoo_lsp = false

-- Set the log level to info
vim.lsp.log.set_level('info')
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

local servers = {
  vtsls = {active = true, opts = {}},
  lua_ls = {active = true, opts = {}},
  bashls = {active = true, opts = {}},
  html = {active = true, opts = {}},
  cssls = {active = true, opts = {}},
  odoo_lsp = {
    active = use_odoo_lsp,
    opts = {
      cmd = {'odoo-lsp'},
      filetypes = {'javascript', 'xml', 'python'},
      root_markers = '.odoo_lsp'
    }
  },
  odools = {
    active = not use_odoo_lsp,
    opts = {
      cmd = {'odoo_ls_server'},
      root_dir = '/home/andg/.local/share/nvim/odoo',
      filetypes = {'python', 'csv', 'xml'},
      workspace_folders = {{
        uri = vim.uri_from_fname(vim.fn.getcwd()),
        name = 'main_folder',
      }},
      capabilities = capabilities,
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

for name, data in pairs(servers) do
  if data.active then
    local opts = data.opts
    vim.lsp.config(name, opts)
    vim.lsp.enable(name)
  end
end
