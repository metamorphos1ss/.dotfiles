return {
  "neovim/nvim-lspconfig",
  config = function()
    local lspconfig = require("lspconfig")

    -- Пример: питон через pyright
    lspconfig.pyright.setup({})
    -- JS/TS
    lspconfig.ts_ls.setup({})
  end,
}
