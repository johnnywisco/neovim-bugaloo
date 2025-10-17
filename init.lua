require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
require("config.lsp")

-- Set the colorscheme
vim.cmd('colorscheme nord')

-- Iterate files in ~/.config/nvim/lsp/ directory to automatically enable LSPs
local lsp_configs = {}

for _, f in pairs(vim.api.nvim_get_runtime_file('lsp/*.lua', true)) do
    local server_name = vim.fn.fnamemodify(f, ':t:r')
    table.insert(lsp_configs, server_name)
end

vim.lsp.enable(lsp_configs)
