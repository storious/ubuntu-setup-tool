-- lua/core/keymaps.lua

local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- 窗口导航
keymap('n', '<C-h>', '<C-w>h', opts)
keymap('n', '<C-j>', '<C-w>j', opts)
keymap('n', '<C-k>', '<C-w>k', opts)
keymap('n', '<C-l>', '<C-w>l', opts)

-- 缓冲区导航
keymap('n', '<Tab>', ':bnext<CR>', opts)
keymap('n', '<S-Tab>', ':bprevious<CR>', opts)
keymap('n', '<leader>x', ':bdelete<CR>', opts)

-- 快速保存
keymap('n', '<leader>w', ':w<CR>', opts)

-- 终端相关
keymap('t', '<Esc>', '<C-\\><C-n>', opts)
keymap('n', '<leader>t', ':terminal<CR>', opts)

-- 文件/插件快捷键
vim.keymap.set('n', '<leader>e', ':lua MiniFiles.open()<CR>', { desc = 'open file explorer' })
vim.keymap.set('n', '<leader>f', ':Pick files<CR>', { desc = 'open file picker' })
vim.keymap.set('n', '<leader>h', ':Pick help<CR>', { desc = 'open help picker' })
vim.keymap.set('n', '<leader>b', ':Pick buffers<CR>', { desc = 'open buffer picker' })
vim.keymap.set('n', '<leader>dd', vim.diagnostic.open_float, { desc = 'diagnostic messages' })

-- 格式化
vim.keymap.set('n', '<leader>ft', function()
  vim.lsp.buf.format()
end, { desc = 'format' })

-- LSP 快捷键
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition' })
vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { desc = 'Go to declaration' })
vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { desc = 'Go to implementation' })
vim.keymap.set('n', 'gr', vim.lsp.buf.references, { desc = 'Find references' })
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename symbol' })
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'LSP code action' })
-- 快速跳转诊断
vim.keymap.set('n', '[d', function()
  vim.diagnostic.jump({ wrap = true, count = -1 })
end, { desc = 'prev diagnostic' })
vim.keymap.set('n', ']d', function()
  vim.diagnostic.jump({ wrap = true, count = 1 })
end, { desc = 'next diagnostic' })

-- 自动命令 --
-- 保存前自动格式化
vim.api.nvim_create_autocmd('BufWritePre', {
  callback = function()
    vim.lsp.buf.format()
  end,
  pattern = '*',
})

-- 复制高亮提示
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'highlight copying text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank({ timeout = 500 })
  end,
})

-- 系统剪贴板
vim.keymap.set({ 'n', 'v' }, '<C-c>', '"+y', { desc = 'copy to system clipboard' })
vim.keymap.set({ 'n', 'v' }, '<C-x>', '"+d', { desc = 'cut to system clipboard' })
vim.keymap.set({ 'n', 'v' }, '<C-p>', '"+p', { desc = 'paste to system clipboard' })
