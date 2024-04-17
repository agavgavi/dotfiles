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

-- local border = {
--     { '┌', 'FloatBorder' },
--     { '─', 'FloatBorder' },
--     { '┐', 'FloatBorder' },
--     { '│', 'FloatBorder' },
--     { '┘', 'FloatBorder' },
--     { '─', 'FloatBorder' },
--     { '└', 'FloatBorder' },
--     { '│', 'FloatBorder' },
-- }
--
vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  -- float = {border = border},
  -- hover = {border = border}
})

-- local handlers =  {
--   ["textDocument/hover"] =  vim.lsp.with(vim.lsp.handlers.hover, {border = border}),
--   ["textDocument/signatureHelp"] =  vim.lsp.with(vim.lsp.handlers.signature_help, {border = border }),
-- }

lspconfig.pyright.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = {"python"},
  -- handlers = handlers,
})

lspconfig.lemminx.setup({})
lsp.setup()

local cmp_action = require('lsp-zero').cmp_action()
require('cmp').setup {
  mapping = {
    ['<Tab>'] = cmp_action.luasnip_supertab(),
    ['<S-Tab>'] = cmp_action.luasnip_shift_supertab(),
  }
}
