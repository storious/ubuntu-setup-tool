-- set <leader> as space
vim.g.mapleader = ' '


-- load core module
require "core.options"
require "core.keymaps"
require "core.autocmds"


-- load plugins module
require "plugins.init"
