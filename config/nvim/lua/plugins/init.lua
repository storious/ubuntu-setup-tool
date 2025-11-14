-- vim pack manage plugins (require neovim >= 12.0)

vim.pack.add({
  { src = 'https://github.com/morhetz/gruvbox' },       -- themes
  { src = 'https://github.com/neovim/nvim-lspconfig' }, -- lsp config
  { src = 'https://github.com/nvim-mini/mini.pick' },   -- file/buffer selector
  { src = 'https://github.com/nvim-mini/mini.files' },  -- file explorer
  { src = 'https://github.com/mason-org/mason.nvim' },
  { src = 'https://github.com/windwp/nvim-autopairs' },
})

vim.pack.add({
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter' } -- grammer highlight and fold
}, {
  load = function(plug_data)
    -- Treesitter config
    -- vim.api.nvim_create_autocmd("BufReadPre", {
    -- once = true,
    -- callback = function()
    vim.opt.runtimepath:append(plug_data.path)
    --@diagnostic disable-next-line: missing-fields
    require('nvim-treesitter.configs').setup({
      ignore_install = {},
      modules = {},
      sync_install = false,
      auto_install = true,
      ensure_installed = { 'lua', 'python', 'json', 'markdown', 'c' }, -- install language
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = { enable = true },
    })
    --end,
    -- })
  end
})


-- blink.cmp complete config and trigger load
vim.pack.add({
  { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range('1.*') },
}, {
  load = function(plug_data)
    -- 不执行任何操作，完全不加载插件
    -- 只在 InsertEnter 时手动添加到 runtimepath 并加载
    vim.api.nvim_create_autocmd("InsertEnter", {
      once = true,
      callback = function()
        -- 手动添加到 runtimepath
        vim.opt.runtimepath:append(plug_data.path)
        -- 加载 plugin 文件
        require('blink.cmp').setup({
          keymap = { preset = 'super-tab' },
          sources = {
            default = { 'lsp', 'path', 'snippets', 'buffer' },
          },
        })
      end,
    })
  end
})

-- color theme
-- defer load gruvbox theme
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    vim.cmd("colorscheme gruvbox")
  end,
})

-- plugin config
--
vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  callback = function()
    -- mason
    require("mason").setup()
    -- mini.pick
    require("mini.pick").setup()
    -- nvim-autopairs
    require("nvim-autopairs").setup()
    -- mini.files file explorer
    require("mini.files").setup({
      windows = {
        preview = true, -- open review windows
      },
    })
  end,
})

-- LSP config
--
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT', path = vim.split(package.path, ';') },
      diagnostics = { globals = { 'vim' } },
      workspace = {
        library = vim.api.nvim_get_runtime_file('', true),
        checkThirdParty = false,
      },
      format = { enable = true },
    },
  },
})


-- launch LSP
--
vim.lsp.enable({ 'lua_ls', 'pyright', 'clangd' })
-- LSP diagnostics show
vim.diagnostic.config({ virtual_text = true })
