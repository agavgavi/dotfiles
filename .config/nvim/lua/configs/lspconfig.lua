local use_odoo_lsp = true

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

local config = require("nvchad.configs.lspconfig")

local lspconfig = require("lspconfig")
local lspconfigs = require('lspconfig.configs')

lspconfigs.odoo_lsp = {
  default_config = {
      name = 'odoo-lsp',
      cmd = {'odoo-lsp'},
      filetypes = {'javascript', 'xml', 'python'},
      root_dir = require('lspconfig.util').root_pattern('.odoo_lsp')
  }
}

local servers = {
  html = {active = true, opts = {}},
  odoo_lsp = {active = use_odoo_lsp, opts = {}},
  ruff = {
    active = true,
    opts = {
      init_options = {
        settings = {
          -- Any extra CLI arguments for `ruff` go here.
          args = {
            "--select", "ALL",
            "--preview",
            "--ignore", "A,ARG,ANN,B,C901,D,DTZ,DOC,E501,E741,ERA001,FBT,N,PD,PERF,PIE790,PLR,PT,Q,RET,RSE102,RUF001,RUF012,S,SIM102,SIM108,SLF001,TID252,UP031,TRY003,TRY300,UP038,E713,SIM117,PGH003,RUF005,FIX,TD,TRY400,C408,PLW2901,PTH,EM102,INP001,CPY001,UP006,UP007,E266,PIE808,PLC2701,RUF021,RUF100,FA100,FURB,C420,COM812,TRY002,B904,EM101,I001,FAST,ASYNC,AIR,DJ,NPY,FA102",
          },
        },
      },
    },
  },
  pyright = {
    active = true,
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
    opts.on_init = config.on_init
    opts.on_attach = config.on_attach
    opts.capabilities = config.capabilities

    lspconfig[name].setup(opts)
  end
end

if not use_odoo_lsp then
  local odools = require('odools')
  local h = os.getenv('HOME')
  odools.setup({
      -- mandatory
      odoo_path = h .. "/Dev/src/odoo",
      python_path = h .. "/.pyenv/shims/python3",
      server_path = h .. "/.local/share/nvim/odoo/odoo_ls_server",

      -- optional
      addons = {h .. "/Dev/src/odoo/addons", h .. "/Dev/src/enterprise", h .. "/Dev/src/user/totd"},
      additional_stubs = {h .. "/.local/share/nvim/odoo/typeshed/stubs"},
      root = h .. "/Dev/src/", -- working directory, odoo_path if empty
      settings = {
          autoRefresh = true,
          autoRefreshDelay = nil,
          diagMissingImportLevel = "none",
      },
  })
end

