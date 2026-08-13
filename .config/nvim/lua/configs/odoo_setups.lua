-- Per-workspace Odoo setups for dap-py/chadrc, first `match` wins (Lua patterns), fallback last.

local M = {}

--- The env's `.oenv` name, which `oools` also writes as its odools profile, or else the dir name.
local function oenv_name(root)
  local marker = root .. "/.oenv"
  if vim.fn.filereadable(marker) == 1 then
    for _, line in ipairs(vim.fn.readfile(marker)) do
      local name = line:match("^name=(.+)$")
      if name then
        return name
      end
    end
  end
  return vim.fs.basename(root)
end

M.setups = {
  {
    key = "odoofin",
    match = "/Dev/src/odoofin%-env",
    root = function() return "/home/andg/Dev/src/odoofin-env" end,
    prompt_label = "OdooFin",
    program = "/home/andg/Dev/src/odoofin-env/odoo/odoo-bin",
    odoorc = function(root) return root .. "/.oenv.conf" end,
    odools_profile = oenv_name,
    tag = "IN ODOOFIN",
    tag_hl = "%#St_lspWarning#",
    tag_icon = "\u{f057}",
  },
  {
    key = "iap",
    match = "/Dev/src/iap",
    root = function() return "/home/andg/Dev/src/iap" end,
    prompt_label = "IAP",
    program = "/home/andg/Dev/src/iap/odoo-18.0/odoo-bin",
    odoorc = function(root) return root .. "/.oenv.conf" end,
    odools_profile = oenv_name,
    tag = "IN IAP",
    tag_hl = "%#St_lspError#",
    tag_icon = "\u{f057}",
  },
  -- All `owt` worktree envs: the slug is only known at runtime, so paths are functions of the root.
  {
    key = "worktree",
    match = "/Dev/wt/[^/]+",
    root = function(cwd)
      local root = cwd:match("^(.*/Dev/wt/[^/]+)")
      -- A dir left behind under ~/Dev/wt with no marker is not an env, so fall back to ~/Dev/src.
      return root and vim.fn.filereadable(root .. "/.oenv") == 1 and root or nil
    end,
    prompt_label = function(root) return vim.fs.basename(root) end,
    program = function(root) return root .. "/odoo/odoo-bin" end,
    odoorc = function(root) return root .. "/.oenv.conf" end,
    tag = function(root) return "IN " .. vim.fs.basename(root):upper() end,
    odools_profile = oenv_name,
    tag_hl = "%#St_lspWarning#",
    tag_icon = "\u{f057}",
  },
  -- Fallback: outside an env everything resolves to ~/Dev/src, mirroring the shell's `_oroot`.
  {
    key = "odoo",
    root = function() return "/home/andg/Dev/src" end,
    program = "/home/andg/Dev/src/odoo/odoo-bin",
    odools_profile = oenv_name,
  },
}

--- The setup owning `cwd`, where entries with a `root` resolve their function fields against it.
function M.current(cwd)
  cwd = cwd or vim.fn.getcwd()
  for _, setup in ipairs(M.setups) do
    if not setup.match or cwd:match(setup.match) then
      if not setup.root then
        return setup
      end
      local root = setup.root(cwd)
      -- A `root` that resolves to nothing means this entry does not own `cwd` after all.
      if not root then
        goto continue
      end
      local resolved = vim.tbl_extend("force", {}, setup)
      resolved.root = root
      for _, key in ipairs({ "program", "odoorc", "prompt_label", "tag", "odools_profile" }) do
        if type(resolved[key]) == "function" then
          resolved[key] = resolved[key](root)
        end
      end
      return resolved
    end
    ::continue::
  end
end

return M
