local dap = require("dap")
local dv = require("dap-view")

require('base46').get_integration("dap")
dofile(vim.g.base46_cache .. "dap")

vim.fn.sign_define('DapBreakpoint', {text='', texthl='DapBreakpoint', linehl='', numhl='DapBreakpoint'})
vim.fn.sign_define('DapBreakpointCondition', {text='󰃤', texthl='DapBreakpointCondition', linehl='DapBreakpoint', numhl='DapBreakpoint'})

vim.fn.sign_define('DapBreakpointRejected', { text='', texthl='DapBreakpoint', linehl='DapBreakpoint', numhl= 'DapBreakpoint' })
vim.fn.sign_define('DapLogPoint', { text='', texthl='DapLogPoint', linehl='DapLogPoint', numhl= 'DapLogPoint' })
vim.fn.sign_define('DapStopped', { text='', texthl='DapStopped', linehl='DapStopped', numhl= 'DapStopped' })


dv.setup(
  {
    winbar = {
      show = true,
      -- You can add a "console" section to merge the terminal with the other views
      sections = {"console", "breakpoints", "repl", "watches", "exceptions", "threads", },
      -- Must be one of the sections declared above
      default_section = "console",
    }
  }
)

dap.listeners.before.attach["dap-view-config"] = function()
  if require('snacks').picker.get({ source = "explorer" })[1] ~= nil then
    require('snacks').picker.get({ source = "explorer" })[1]:close()
  end
  dv.open()
end

dap.listeners.before.launch["dap-view-config"] = function()
  if require('snacks').picker.get({ source = "explorer" })[1] ~= nil then
    require('snacks').picker.get({ source = "explorer" })[1]:close()
  end
  dv.open()
end

dap.listeners.before.event_terminated["dap-view-config"] = function()
  dv.close()
end

dap.listeners.before.event_exited["dap-view-config"] = function()
  dv.close()
end
