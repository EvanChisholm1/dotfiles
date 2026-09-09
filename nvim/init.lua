-- leader must be set before lazy.nvim loads
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("options")
require("keymaps")

-- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = { { import = "plugins" } },
  install = { colorscheme = { "zenwritten", "habamax" } },
  checker = { enabled = true, notify = false }, -- check for updates, don't nag
  change_detection = { notify = false },
  rocks = { enabled = false }, -- nothing here needs luarocks
  ui = { border = "rounded" },
  performance = {
    rtp = {
      disabled_plugins = { "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin", "netrwPlugin" },
    },
  },
})

-- after lazy.setup, so every colorscheme plugin is on the runtimepath
require("theme").apply()
