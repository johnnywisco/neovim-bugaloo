return {
    {
        'akinsho/bufferline.nvim',
        version = "*",
        dependencies = 'nvim-tree/nvim-web-devicons',
        config = function()
            require("bufferline").setup({
                options = {
                    offsets = {
                        {
                            filetype = "NvimTree",
                            text = "| File Explorer |", -- Optional label
                            highlight = "Directory",    -- Optional highlight group
                            text_align = "center",      -- "left", "center", or "right"
                            separator = true            -- Adds a visual separator
                        },
                    },
                    numbers = "both",
                    show_buffer_icons = true,
                    show_buffer_close_icons = true,
                    separator_style = "slant",
                },
            })
        end,
    }
}
