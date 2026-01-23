vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'go', 'lua', 'python' },
  callback = function()
    vim.treesitter.start()
  end,
})
