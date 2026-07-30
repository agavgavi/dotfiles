-- Per-workspace Odoo setups, shared by configs/dap-py.lua and chadrc.lua.
-- First `match` wins so keep the fallback last; matches are Lua patterns (`%-`).

local M = {}

M.setups = {
  {
    key = "odoofin",
    match = "/Dev/src/odoofin%-env",
    prompt_label = "OdooFin",
    program = "/home/andg/Dev/src/odoofin-env/odoo/odoo-bin",
    odoorc = "/home/andg/.odoorc-odoofin",
    odools_profile = "odoofin",
    tag = "IN ODOOFIN",
    tag_hl = "%#St_lspWarning#",
    tag_icon = "\u{f057}",
  },
  {
    key = "iap",
    match = "/Dev/src/iap",
    prompt_label = "IAP",
    program = "/home/andg/Dev/src/iap/odoo-18.0/odoo-bin",
    odoorc = "/home/andg/.odoorc-iap",
    odools_profile = "iap",
    tag = "IN IAP",
    tag_hl = "%#St_lspError#",
    tag_icon = "\u{f057}",
  },
  {
    key = "odoo",
    program = "/home/andg/Dev/src/odoo/odoo-bin",
    odools_profile = "Custom Setup",
  },
}

--- The setup owning `cwd` (defaults to the current working directory).
function M.current(cwd)
  cwd = cwd or vim.fn.getcwd()
  for _, setup in ipairs(M.setups) do
    if not setup.match or cwd:match(setup.match) then
      return setup
    end
  end
end

return M
