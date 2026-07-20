---@type ChadrcConfig
local M = {}
M.ui = {
  statusline = {
    theme = "vscode_colored",
    order = { "mode", "file", "git", "%=", "abc", "lsp_msg", "%=", "odoo", "diagnostics", "lsp", "cursor", "cwd" },
    modules = {
      odoo = function()
        local ok, odools = pcall(require, "odoo_ls")
        if not ok or vim.o.columns <= 85 then
          return ""
        end
        local s = odools.status()
        if not s.running then
          return ""
        end
        if s.crashed then
          return "%#St_lspError#  " .. (s.profile or "odoo") .. " ✗ %#StText#"
        end
        local out = "%#St_LspStatus#  " .. (s.profile or "odoo") .. (s.loading == "start" and " 󰦖" or "")
        if s.config_errors > 0 then
          out = out .. " %#St_lspError#" .. s.config_errors .. "E"
        end
        if s.config_warnings > 0 then
          out = out .. " %#St_lspWarning#" .. s.config_warnings .. "W"
        end
        return out .. "%#StText# "
      end,
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
    NvimDapViewVirtualText = { fg = 'light_grey' },
    ConflictMarkerBegin = { bg = '#2f7366' },
    ConflictMarkerOurs = { bg = '#2e5049' },
    ConflictMarkerTheirs = { bg = '#344f69' },
    ConflictMarkerEnd = { bg = '#2f628e' },
    ConflictMarkerCommonAncestorsHunk = { bg = '#754a81' },
  },
  integrations = {
    "bufferline",
    "dap",
    "notify"
  },
}
M.mason = {
  pkgs = {
        "debugpy",
        "html-lsp",
        "css-lsp",
        "eslint-lsp",
        "lemminx",
        "lua-language-server",
        "bash-language-server",
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
