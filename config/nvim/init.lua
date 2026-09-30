vim.pack.add {
  { src = 'https://github.com/neovim/nvim-lspconfig' },
}

vim.lsp.config('ty', {
  root_markers = { 'pyproject.toml', 'ruff.toml', '.ruff.toml' },
})

vim.lsp.enable('ty')

vim.cmd([[
  set runtimepath^=~/.vim runtimepath+=~/.vim/after
  let &packpath = &runtimepath
  source ~/.vimrc
]])

vim.keymap.set("n", "<leader>ca", function() vim.lsp.buf.code_action() end)
vim.keymap.set("n", "<leader>ci", function() vim.lsp.buf.implementation() end)
vim.keymap.set("n", "<leader>cR", function() vim.lsp.buf.rename() end)
vim.keymap.set("n", "<leader>cr", function() vim.lsp.buf.references() end)
vim.keymap.set("n", "<leader>ct", function() vim.lsp.buf.type_definition() end)
vim.keymap.set("n", "<leader>cx", function() vim.lsp.codelens.run() end)
vim.keymap.set("n", "<leader>cs", function() vim.lsp.buf.document_symbol() end)
vim.keymap.set("n", "<leader>ce", function() vim.diagnostic.open_float() end)
vim.keymap.set("n", "L", function() vim.lsp.buf.hover() end)
vim.keymap.set("i", "C-S", function() vim.lsp.buf.signature_help() end)

vim.o.winborder="single"
