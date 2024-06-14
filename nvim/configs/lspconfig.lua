local config = require("plugins.configs.lspconfig")

local on_attach = config.on_attach
local capabilities = config.capabilities

vim.lsp.set_log_level('info')

local lsp = require('lsp-zero').preset({})
lsp.on_attach(function(client, bufnr)
	lsp.default_keymaps({buffer = bufnr})
end)

local lspconfig = require("lspconfig")

local lspconfigs = require('lspconfig.configs')

lspconfigs.odoo_lsp = {
  default_config = {
    name = 'odoo-lsp',
    cmd = {'odoo-lsp'},
    filetypes = {'javascript', 'xml', 'python'},
    root_dir = require('lspconfig.util').root_pattern('.odoo_lsp', '.odoo_lsp.json', '.git')
  }
}
lspconfig.odoo_lsp.setup({})

local border = {
    { '┌', 'FloatBorder' },
    { '─', 'FloatBorder' },
    { '┐', 'FloatBorder' },
    { '│', 'FloatBorder' },
    { '┘', 'FloatBorder' },
    { '─', 'FloatBorder' },
    { '└', 'FloatBorder' },
    { '│', 'FloatBorder' },
}

vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {border = border},
  hover = {border = border}
})

local handlers =  {
  ["textDocument/hover"] =  vim.lsp.with(vim.lsp.handlers.hover, {border = border}),
  ["textDocument/signatureHelp"] =  vim.lsp.with(vim.lsp.handlers.signature_help, {border = border }),
}

lspconfig.pyright.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = {"python"},
  handlers = handlers,
  settings = {
    pyright = {
      -- Using Ruff's import organizer
      disableOrganizeImports = true,
    },
    python = {
      analysis = {
        -- Ignore all files for analysis to exclusively use Ruff for linting
        ignore = { '*' },
      },
    },
  },
})

lspconfig.ruff_lsp.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = {"python"},
  handlers = handlers,
  init_options = {
    settings = {
      -- Any extra CLI arguments for `ruff` go here.
      args = {
        "--select", "ALL",
        "--preview",
        "--ignore", "ANN,B,C901,COM812,D,E501,E741,EM101,ERA001,FBT,I001,N,PD,PERF,PIE790,PLR,PT,Q,RET502,RET503,RSE102,RUF001,RUF012,S,SIM102,SIM108,SLF001,TID252,UP031,TRY002,TRY003,TRY300,UP038,E713,SIM117,PGH003,RUF005,RET,DTZ,FIX,TD,ARG,TRY400,B904,C408,PLW2901,PTH,EM102,INP001,CPY001,UP006,UP007,E266,PIE808,PLC2701,FURB101,RUF021,FURB118,FA100,FA102",
      },
    }
  }
})


lspconfig.lemminx.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = {"xml"},
  handlers = handlers,
  settings = {
    xml = {
      format = {
        splitAttributes = false
      }
    }
  }
})
lsp.setup()

local cmp_action = require('lsp-zero').cmp_action()
require('cmp').setup {
  mapping = {
    ['<Tab>'] = cmp_action.luasnip_supertab(),
    ['<S-Tab>'] = cmp_action.luasnip_shift_supertab(),
  }
}
