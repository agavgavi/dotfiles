local plugins = {
  {
    "folke/todo-comments.nvim",
    event='VeryLazy',
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function(opts)
      require("todo-comments").setup {
      }
    end,
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
    enabled=false,
    dependencies = "nvim-lua/plenary.nvim",
  },
  {
    "marcinjahn/gemini-cli.nvim",
    cmd = "Gemini",
    -- Example key mappings for common actions:
    keys = {
      { "<leader>a/", "<cmd>Gemini toggle<cr>", desc = "Toggle Gemini CLI" },
      { "<leader>aa", "<cmd>Gemini ask<cr>", desc = "Ask Gemini", mode = { "n", "v" } },
      { "<leader>af", "<cmd>Gemini add_file<cr>", desc = "Add File" },

    },
    dependencies = {
      "folke/snacks.nvim",
    },
    opts = {
      -- Command line arguments passed to gemini-cli
      args = {

      },
      -- Automatically reload buffers changed by GeminiCLI (requires vim.o.autoread = true)
      auto_reload = true,
    },
  },
  {
    "folke/persistence.nvim",
    event = "BufReadPre", -- this will only start session saving when an actual file was opened
    opts = {
      -- add any custom options here
    }
  },
  {
    "rhysd/conflict-marker.vim",
    lazy = false,
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
      require("nvim-dap-virtual-text").setup({
        -- display_callback = function(variable)
        --   if #variable.value > 15 then
        --     return ' ' .. variable.value:sub(1, 15) .. '...'
        --   end
        --   return ' ' .. variable.value
        -- end,
      })
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
    "mfussenegger/nvim-dap",
    dependencies = {
      {
        "igorlfs/nvim-dap-view",
        config = function(_, opts)
            require("configs.dap-view")
        end,
        enabled = true,
      },
      {
        "rcarriga/nvim-dap-ui",
        dependencies = {"mfussenegger/nvim-dap", "nvim-neotest/nvim-nio"},
        enabled = false,
      }
    },
    ft = "python",
  },
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = {
      "mfussenegger/nvim-dap",
      "theHamsta/nvim-dap-virtual-text",
      "Weissle/persistent-breakpoints.nvim",
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
    "neovim/nvim-lspconfig",
    config = function()
      require("nvchad.configs.lspconfig").defaults()
      require "configs.lspconfig"
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = function()
      local o = require "nvchad.configs.gitsigns"
      o['preview_config'] = {border = 'rounded'}
      return o
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
        "xml",
        "c",
        "python",
        "cpp",
        "bash",
        "markdown",
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<A-k>",
          node_incremental = "<A-k>",
          scope_incremental = "<A-K>",
          node_decremental = "<A-l>",
        },
      },
    },
  },
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make" , enabled = false},
  {
    "nvim-telescope/telescope.nvim",
    enabled = false,
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
      {
        'Marskey/telescope-sg',
      },
    },
    opts = {
      extensions_list = { "themes", "terms", "live_grep_args", "fzf", "ast_grep"},
      extensions = {
        fzf = {
          fuzzy = true, -- false will only do exact matching
          override_generic_sorter = true, -- override the generic sorter
          override_file_sorter = true, -- override the file sorter
          case_mode = "smart_case", -- or "ignore_case" or "respect_case"
          -- the default case_mode is "smart_case"
        },
        ast_grep = {
            command = {
                "ast-grep", -- For Linux, use `ast-grep` instead of `sg`
                "--json=stream",
            }, -- must have --json=stream
            grep_open_files = false, -- search in opened files
            lang = nil, -- string value, specify language for ast-grep `nil` for default
        }
      },
    },
  },
  {
    "folke/which-key.nvim",
    keys = { "<leader>", "<c-r>", "<c-w>", '"', "'", "`", "c", "v", "g" },
    cmd = "WhichKey",
    lazy = false,
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
    "folke/snacks.nvim",
    lazy = false,
    opts = {
      dashboard = {
        enabled = true,
        sections = {
          { section = "header" },
          { section = "keys", gap = 1, padding = 1 },
          { pane = 2, icon = " ",key="s", title = "Recent Files", action = "<leader>rS", padding = 1, hidden=1},
          { section = "startup" },
        },
      },
      picker = {
        enabled = true,
        win = {
          preview = {
            keys = {
              ["<PageUp>"] = { "preview_scroll_up", mode = { "n", "i" } },
              ["<PageDown>"] = { "preview_scroll_down", mode = { "n", "i" } },
            },
          },
          list = {
            keys = {
              ["<PageUp>"] = { "list_scroll_up", mode = { "n", "i" } },
              ["<PageDown>"] = { "list_scroll_down", mode = { "n", "i" } },
            },
          },
          input = {
            keys = {
              ["<PageUp>"] = { "list_scroll_up", mode = { "n", "i" } },
              ["<PageDown>"] = { "list_scroll_down", mode = { "n", "i" } },
            },
          },
        },
      }
    }
  },
  { import = "nvchad.blink.lazyspec" },
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = { enabled = false },
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        help = true,
      },
    },
  },
  {
    "saghen/blink.cmp",
    optional = true,
    dependencies = { "fang2hou/blink-copilot" },
    opts = {
      sources = {
        default = { "copilot" },
        providers = {
          copilot = {
            name = "copilot",
            module = "blink-copilot",
            score_offset = 100,
            async = true,
          },
        },
      },
    },
  },
  {
    "nvim-tree/nvim-tree.lua",
    enabled = false,
  }
}
return plugins
