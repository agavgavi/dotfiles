local plugins = {
  {
  'stevearc/dressing.nvim',
    lazy = false,
    opts = {},
  },
  {
    "Shatur/neovim-session-manager",
    lazy = false,
    dependencies = "nvim-lua/plenary.nvim",
    config = function()
      require ("custom.configs.session")
    end
  },
  {
    "Weissle/persistent-breakpoints.nvim",
    dependencies = "mfussenegger/nvim-dap",
    config = function()
      require('persistent-breakpoints').setup{
	      load_breakpoints_event = { "BufReadPost" }
      }
    end
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = "mfussenegger/nvim-dap",
    config = function()
      require("nvim-dap-virtual-text").setup()
    end
  },
   {
    "rcarriga/nvim-dap-ui",
    dependencies = "mfussenegger/nvim-dap",
    config = function()
      require('custom.configs.dap-ui')
    end
  },
  {
    "Joakker/lua-json5",
    build='./install.sh'
  },
  {
    "mfussenegger/nvim-dap",
    ft = "python",
    config = function(_, opts)
      require("core.utils").load_mappings("dap")
    end
  },
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = {
      "mfussenegger/nvim-dap-python",
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "Weissle/persistent-breakpoints.nvim",
      "Joakker/lua-json5",
    },
    config = function(_, opts)
      require("custom.configs.dap-py")
    end,
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    ft = {"python"},
    opts = function()
      return require "custom.configs.null-ls"
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "debugpy"
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        -- defaults 
        "vim",
        "lua",

        -- web dev 
        "html",
        "css",
        "javascript",
        "typescript",
        "tsx",
        "json",
        -- "vue", "svelte",

       -- low level
        "c",
        "python",
        "cpp",
        "bash",
        "markdown"
      },
    },
  },
}
return plugins
