return {
    {
        'lukas-reineke/indent-blankline.nvim',
        main = 'ibl',
        -- ---@module "ibl"
        -- ---@type ibl.config
        config = function()
            local highlight = {
                'Nord1',
                'Nord2',
                'Nord3',
                'Nord4',
                'Nord5',
                'Nord6',
                'Nord7',
            }

            local hooks = require 'ibl.hooks'

            -- Setup highlight groups every time the colorscheme changes
            hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
                vim.api.nvim_set_hl(0, 'Nord1', { fg = '#bf616a' })
                vim.api.nvim_set_hl(0, 'Nord2', { fg = '#d08770' })
                vim.api.nvim_set_hl(0, 'Nord3', { fg = '#ebcb8b' })
                vim.api.nvim_set_hl(0, 'Nord4', { fg = '#a3be8c' })
                vim.api.nvim_set_hl(0, 'Nord5', { fg = '#b48ead' })
                vim.api.nvim_set_hl(0, 'Nord6', { fg = '#5e81ac' })
                vim.api.nvim_set_hl(0, 'Nord7', { fg = '#8fbcbb' })
            end)

            require('ibl').setup {
                indent = {
                    highlight = highlight,
                    char = '│',
                },
                scope = {
                    enabled = true,
                    highlight = highlight,
                },
            }
        end,
    },
}
