---@type ChadrcConfig
local M = {}
M.ui = {
  theme = "catppuccin",
  statusline = { theme = "vscode_colored" },
}
M.base46 = {
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
-- M.plugins = "plugins"
-- M.mappings = require "mappings"
return M
