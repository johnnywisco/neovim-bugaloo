return {
    {
        "danymat/neogen",
        -- config = true,
        -- Uncomment next line if you want to follow only stable versions
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "L3MON4D3/LuaSnip",
        },
        version = "*",
        config = function()
            require("neogen").setup {
                enabled = true,
                snippet_engine = "luasnip",
            }
        end,
        keys = {
            {
                "<leader>nf",
                function() require("neogen").generate({ type = "func" }) end,
                desc = "Neogen: Generate function annotation",
            },
            {
                "<leader>nc",
                function() require("neogen").generate({ type = "class" }) end,
                desc = "Neogen: Generate class annotation",
            },
            {
                "<leader>nt",
                function() require("neogen").generate({ type = "type" }) end,
                desc = "Neogen: Generate type annotation",
            },
            {
                "<leader>nF",
                function() require("neogen").generate({ type = "file" }) end,
                desc = "Neogen: Generate file annotation",
            },
        },
        languages = {
            python = {
                template = {
                    annotation_convention = 'google_docstrings'
                },
            },
        },
    },
}
