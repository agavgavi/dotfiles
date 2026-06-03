require('noice').setup({
  lsp = {
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
    },
    -- hover = { enabled = false},
    -- signature = { enabled = false}
  },
  presets = {
    lsp_doc_border = true,
  }
})
