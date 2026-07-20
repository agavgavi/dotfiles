return {
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
    "sql",
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
}
