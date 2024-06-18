local plugins = {
  {
  'stevearc/dressing.nvim',
    lazy = false,
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    config = function(opts)
      require('configs.noice')
      require("notify").setup({
        timeout = 50,
      })
    end
  },
  {
    "Shatur/neovim-session-manager",
    lazy = false,
    dependencies = "nvim-lua/plenary.nvim",
    config = function()
      require ("configs.session")
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
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio"
    },
    config = function()
      require('configs.dap-ui')
    end
  },
  {
    "L3MON4D3/LuaSnip",
    dependencies = { "mstuttgart/vscode-odoo-snippets" },
    config = function(_, opts)
      require("nvchad.configs.luasnip")
    end,
  },
  {
    "Joakker/lua-json5",
    build='./install.sh'
  },
  {
    "mfussenegger/nvim-dap",
    ft = "python",
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
      require("configs.dap-py")
    end,
  },
  {
    "utilyre/barbecue.nvim",
    lazy = false,
    name = "barbecue",
    version = "*",
    dependencies = {
      "SmiteshP/nvim-navic",
      "nvim-tree/nvim-web-devicons", -- optional dependency
    },
    opts = {
      -- configurations go here
      show_dirname = true,
    },
  },

  {
    "jose-elias-alvarez/null-ls.nvim",
    ft = {"python"},
    opts = function()
      return require "configs.null-ls"
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "debugpy",
        "pyright",
        "html-lsp",
        "json-lsp",
        "eslint-lsp",
        "lemminx",
        "lua-language-server"
      },
    },
  },
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v2.x',
    dependencies = {
      -- LSP Support
      {'neovim/nvim-lspconfig'},             -- Required
      {'williamboman/mason.nvim'},           -- Optional
      {'williamboman/mason-lspconfig.nvim'}, -- Optional

      -- Autocompletion
      {'hrsh7th/nvim-cmp'},     -- Required
      {'hrsh7th/cmp-nvim-lsp'}, -- Required
      {'L3MON4D3/LuaSnip'},     -- Required
    }
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require ("nvchad.configs.lspconfig").defaults()
      require "configs.lspconfig"
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
  { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      {
          "nvim-telescope/telescope-live-grep-args.nvim" ,
          -- This will not install any breaking changes.
          -- For major updates, this must be adjusted manually.
          version = "^1.0.0",
      },
      {
        "nvim-telescope/telescope-file-browser.nvim",
      }
    },
    opts = {
      extensions_list = { "themes", "terms", "live_grep_args", "fzf"},
      extensions = {
        fzf = {
          fuzzy = true,                    -- false will only do exact matching
          override_generic_sorter = true,  -- override the generic sorter
          override_file_sorter = true,     -- override the file sorter
          case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                                           -- the default case_mode is "smart_case"
        }
      }
    }
  }
}
return plugins
