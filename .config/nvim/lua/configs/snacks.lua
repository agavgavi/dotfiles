return {
  dashboard = {
    enabled = true,
    sections = {
      { section = "header" },
      { section = "keys", gap = 1, padding = 1 },
      { pane = 2, icon = " ", key = "s", title = "Recent Files", action = "<leader>rS", padding = 1, hidden = 1 },
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
  },
}
