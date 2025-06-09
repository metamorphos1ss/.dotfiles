local lazypath = vim.fn.stdpath("data") .. "/site/pack/lazy/start/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  print("📦 Устанавливаю lazy.nvim...")
  vim.fn.system({ "git", "clone", "--filter=blob:none", 
    "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  require("plugins.catppuccin"),
  require("plugins.lualine"),
  require("plugins.nvim-tree"),
  require("plugins.treesitter"),
  require("plugins.telescope"),
  require("plugins.cmp"),
  require("plugins.lspconfig")
})
