vim.pack.add {
  { src = 'https://github.com/neovim/nvim-lspconfig' },
}

vim.lsp.config('ty', {
  root_markers = { 'pyproject.toml', 'ruff.toml', '.ruff.toml' },
  on_attach = function(client, bufnr)
    -- use LSP completion for omnifunc
    --vim.api.nvim_buf_set_option(buf, "omnifunc", "v:lua.vim.lsp.omnifunc")
    -- Ctrl+] for go to definition using LSP instead of ctags
    vim.api.nvim_buf_set_option(buf, "tagfunc", "v:lua.vim.lsp.tagfunc()")
    -- Code formatting (gq etc) using LSP
    vim.api.nvim_buf_set_option(buf, "formatexpr", "v:lua.vim.lsp.formatexpr()")
    vim.lsp.completion.enable(true, client.id, bufnr, {
      autotrigger = true,
      convert = function(item)
        return { abbr = item.label:gsub("%b()", "") }
      end
    })
  end
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
vim.keymap.set("n", "L", vim.lsp.buf.hover)
vim.keymap.set("i", "C-S", function() vim.lsp.buf.signature_help() end)
vim.keymap.set("n", "<leader>qf", vim.diagnostic.setqflist)

vim.o.winborder="single"
vim.opt.completeopt = { "menuone", "noselect", "popup" }

vim.keymap.set("i", "<Tab>", "<C-N>")

vim.keymap.set("i", "<S-Tab>", function()
    return vim.fn.pumvisible() == 1 and '<C-P>' or '<Tab>'
  end,
  { expr = true }
)

vim.keymap.set("i", "<CR>", function()
    return vim.fn.pumvisible() == 1 and '<C-y>' or '<CR>'
  end,
  { expr = true }
)
