return {
    {
        "nvzone/floaterm",
        dependencies = "nvzone/volt",
        config = function()
            require('floaterm').setup {
                boarder = 'double',
                size = { h = 60, w = 70 },
            }
        end

        -- opts = {
        --     boarder = true,
        --     size = { h = 80, w = 80 },
        -- },
    },
}
