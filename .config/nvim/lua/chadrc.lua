---@type ChadrcConfig
local M = {}
M.ui = {
  statusline = {
    theme = "vscode_colored",
    order = { "mode", "file", "git", "%=", "abc", "lsp_msg", "%=", "diagnostics", "lsp", "cursor", "cwd" },
    modules = {
      abc = function()
        local name = vim.uv.cwd()
        if (name:match "([^/\\]+)[/\\]*$" or name) == 'iap' then
          name ="%#St_lspError#" .. " " .. "IN IAP" .. "%#StText#"
        else
          name = ""
        end
        return (vim.o.columns > 85 and name) or ""
      end,
    }
  },
  cmp = {lspkind_text = true, style = "default", format_colors = { tailwind = true}}

}
M.base46 = {
  theme = "catppuccin",
  hl_add = {
    SnacksPickerDir = { fg = 'light_grey' },
    SnacksPickerDirIcon = { fg = 'blue' },
    SnacksPickerFile = { fg = 'white' },
    SnacksPickerMatch = { fg = 'cyan', bold = true },
  },
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
