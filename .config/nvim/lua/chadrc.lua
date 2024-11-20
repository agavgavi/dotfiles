---@type ChadrcConfig
local M = {}
M.ui = {
  statusline = { theme = "vscode_colored" },
  cmp = {lspkind_text = true, style = "default", format_colors = { tailwind = true}}
}
M.base46 = {
  theme = "catppuccin",
  integrations = {
    "bufferline",
    "dap",
    "lspsaga",
    "notify"
  },
}
M.mason = {
  pkgs = {
        "debugpy",
        "pyright",
        "html-lsp",
        "json-lsp",
        "eslint-lsp",
        "lemminx",
        "lua-language-server",
        "ltex",
  }
}

 M.colorify = {
   enabled = true,
   mode = "virtual", -- fg, bg, virtual
   virt_text = "󱓻 ",
   highlight = { hex = true, lspvars = true },
 }
-- M.plugins = "plugins"
-- M.mappings = require "mappings"
return M
