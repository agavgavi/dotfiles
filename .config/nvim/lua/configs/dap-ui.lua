local dap = require("dap")
local dapui = require("dapui")
local treeapi = require("nvim-tree.api")
require('base46').get_integration("dap")
dofile(vim.g.base46_cache .. "dap")

vim.fn.sign_define('DapBreakpoint', {text='', texthl='DapBreakpoint', linehl='', numhl='DapBreakpoint'})
vim.fn.sign_define('DapBreakpointCondition', {text='󰃤', texthl='DapBreakpointCondition', linehl='DapBreakpoint', numhl='DapBreakpoint'})

vim.fn.sign_define('DapBreakpointRejected', { text='', texthl='DapBreakpoint', linehl='DapBreakpoint', numhl= 'DapBreakpoint' })
vim.fn.sign_define('DapLogPoint', { text='', texthl='DapLogPoint', linehl='DapLogPoint', numhl= 'DapLogPoint' })
vim.fn.sign_define('DapStopped', { text='', texthl='DapStopped', linehl='DapStopped', numhl= 'DapStopped' })

local config = {
  layouts = {
    {
      -- You can change the order of elements in the sidebar
      elements = {
        -- Provide IDs as strings or tables with "id" and "size" keys
        {
          id = "scopes",
          size = 0.25, -- Can be float or integer > 1
        },
        { id = "breakpoints", size = 0.25 },
        { id = "stacks", size = 0.25 },
        { id = "watches", size = 0.25 },
      },
      size = 40,
      position = "left", -- Can be "left" or "right"
    },
    {
      elements = {
        "console",
      },
      size = .25,
      position = "bottom", -- Can be "bottom" or "top"
    },
  },
  controls = {
    element = 'console'
  }
}

dapui.setup(config)

dap.listeners.after.event_initialized["dapui_config"] = function()
  treeapi.tree.close()
  dapui.open()
end

dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
  vim.o.laststatus=3;
  treeapi.tree.open()
end

dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
  vim.o.laststatus=3;
  treeapi.tree.open()
end


