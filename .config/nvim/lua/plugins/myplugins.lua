local plugins = {
  {
    'whenrow/odoo-ls.nvim',
    dependencies = { 'neovim/nvim-lspconfig' }
  },
  {
    "stevearc/dressing.nvim",
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
      require "configs.noice"
      require("notify").setup {
        timeout = 50,
      }
    end,
  },
  {
    "Shatur/neovim-session-manager",
    lazy = false,
    dependencies = "nvim-lua/plenary.nvim",
    config = function()
      require "configs.session"
    end,
  },
  {
    "Weissle/persistent-breakpoints.nvim",
    dependencies = "mfussenegger/nvim-dap",
    config = function()
      require("persistent-breakpoints").setup {
        load_breakpoints_event = { "BufReadPost" },
      }
    end,
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = "mfussenegger/nvim-dap",
    config = function()
      require("nvim-dap-virtual-text").setup()
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      require "configs.dap-ui"
    end,
  },
  {
    "L3MON4D3/LuaSnip",
    dependencies = { "mstuttgart/vscode-odoo-snippets" },
    config = function(_, opts)
      require "nvchad.configs.luasnip"
    end,
  },
  {
    "Joakker/lua-json5",
    build = "./install.sh",
  },
  {
    "mfussenegger/nvim-dap",
    -- dependencies ={ { "igorlfs/nvim-dap-view", opts = {} }},
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
      require "configs.dap-py"
    end,
  },
  {
    'Bekaboo/dropbar.nvim',
    lazy = false,
    -- optional, but required for fuzzy finder support
    dependencies = {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make'
    },
    config = function()
      local dropbar_api = require('dropbar.api')
      vim.keymap.set('n', '<Leader>;', dropbar_api.pick, { desc = 'Pick symbols in winbar' })
      vim.keymap.set('n', '[;', dropbar_api.goto_context_start, { desc = 'Go to start of current context' })
      vim.keymap.set('n', '];', dropbar_api.select_next_context, { desc = 'Select next context' })
    end
  },
  {
      'cameron-wags/rainbow_csv.nvim',
      config = true,
      ft = {
          'csv',
          'tsv',
          'csv_semicolon',
          'csv_whitespace',
          'csv_pipe',
          'rfc_csv',
          'rfc_semicolon'
      },
      cmd = {
          'RainbowDelim',
          'RainbowDelimSimple',
          'RainbowDelimQuoted',
          'RainbowMultiDelim'
      }
  },
  {
    "williamboman/mason.nvim",
    opts = {
    },
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("nvchad.configs.lspconfig").defaults()
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
        "vimdoc",
				"luadoc",

        -- web dev
        "html",
        "css",
        "javascript",
        "typescript",
        "tsx",
        "json",
        "rst",
        -- "vue", "svelte",

        -- low level
        "c",
        "python",
        "cpp",
        "bash",
        "markdown",
      },
    },
  },
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      {
        "nvim-telescope/telescope-live-grep-args.nvim",
        -- This will not install any breaking changes.
        -- For major updates, this must be adjusted manually.
        version = "^1.0.0",
      },
      {
        "nvim-telescope/telescope-file-browser.nvim",
      },
    },
    opts = {
      extensions_list = { "themes", "terms", "live_grep_args", "fzf" },
      extensions = {
        fzf = {
          fuzzy = true, -- false will only do exact matching
          override_generic_sorter = true, -- override the generic sorter
          override_file_sorter = true, -- override the file sorter
          case_mode = "smart_case", -- or "ignore_case" or "respect_case"
          -- the default case_mode is "smart_case"
        },
      },
    },
  },
  {
    "folke/which-key.nvim",
    keys = { "<leader>", "<c-r>", "<c-w>", '"', "'", "`", "c", "v", "g" },
    cmd = "WhichKey",
    config = function(_, opts)
      dofile(vim.g.base46_cache .. "whichkey")
      require("which-key").setup({
        delay = 0,
        icons = {
          rules = false
        }
      })
    end,
  },
  {
    "nvim-tree/nvim-tree.lua",
    opts = {git = {enable = false}, filters = {dotfiles = true }}
  }
}
return plugins
