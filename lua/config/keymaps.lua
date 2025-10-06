
-- {{{ No-op keymaps so which-key is more descriptive
vim.keymap.set("n", "<leader>s", function() end, { desc = "[s]earch options" })
vim.keymap.set("n", "<leader>t", function() end, { desc = "[t]oggle misc. settings" })
-- }}}

vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "NvimTree [e]xplorer"})

-- vim.keymap.set("n", "<Leader>e", function()
--   require("snacks.picker").explorer()
-- end, { desc = "Open Snacks Explorer" })

-- {{{ Move to window splits using the <ctrl> + hjkl keys
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })
-- }}}

-- {{{ Re-size window using <ctrl> + arrow keys
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })
-- }}}

-- {{{ Toggle colorcolumn at 80 & 100 chars
local function toggle_colorcolumn()
    local current = vim.opt.colorcolumn:get()
    if #current == 0 then
        vim.opt.colorcolumn = "80,100"
        vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#343042" }) -- Set your desired color
    else
        vim.opt.colorcolumn = ""
        -- Optional: clear or dim the highlight
        vim.api.nvim_set_hl(0, "ColorColumn", { bg = "NONE" })
    end
end
-- Set keymap for color comments
vim.keymap.set("n", "<leader>tc", toggle_colorcolumn, { desc = "Toggle [c]olorcolumn" })
-- }}}
