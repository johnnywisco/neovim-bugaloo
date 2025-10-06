return {
    cmd = { 'lua-language-server' },
    filetypes = { 'lua' },
    root_markers = { '.luarc.json', '.luarc.jsonc' },
    settings = {
        Lua = {
            codelens = {
                enable = true,
            },
            diagnostics = {
                globals = { 'vim' },
            },
            hint = {
                enable = true,
            },
            runtime = {
                version = 'LuaJIT',
            },
            workspace = {
                checkThirdParty = false,
            },
            completion = {
                enable = true,
                displayContext = 1,
                callSnippet = 'Both',
            },
        },
    },
}
