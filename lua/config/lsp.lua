-- Lsp capabilities and on_attach {{{
-- Here we grab default Neovim capabilities and extend them with ones we want on top
local capabilities = vim.lsp.protocol.make_client_capabilities()

capabilities.textDocument.foldingRange = {
    dynamicRegistration = true,
    lineFoldingOnly = true,
}

capabilities.textDocument.semanticTokens.multilineTokenSupport = true
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.codeLens = { dynamicRegistration = false }

-- Defined in init.lua
vim.lsp.config('*', {
    capabilities = capabilities,
    root_markers = { '.git' },
})

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(event)
        local client = vim.lsp.get_client_by_id(event.data.client_id)

        -- Enable auto completions
        if client.supports_method('textDocument/completion') then
            vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
        end

        -- Create keymap to toggle inlay hints
        if client.supports_method('textDocument/inlayHint') then
            vim.keymap.set('n', '<leader>th',
                function()
                    -- Toggle the display of inlay hints for the current buffer.
                    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({}))
                end, { desc = 'Toggle Inlay [H]ints' })
        end

        -- Enable Document Highlights
        if client.supports_method('textDocument/documentHighlight') then
            -- Create a non-clearing augroup for managing highlight-related autocommands.
            local highlight_augroup = vim.api.nvim_create_augroup('LspHighlight', { clear = false })
            -- When the cursor stays still for a moment ('CursorHold'), highlight the symbol's references.
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                buffer = event.buf,
                group = highlight_augroup,
                callback = vim.lsp.buf.document_highlight,
            })
            -- When the cursor moves ('CursorMoved'), clear the highlights.
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                buffer = event.buf,
                group = highlight_augroup,
                callback = vim.lsp.buf.clear_references,
            })
            -- Add a cleanup mechanism for when the LSP client detaches.
            vim.api.nvim_create_autocmd('LspDetach', {
                group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
                callback = function(event2)
                    -- Clear any remaining highlights and remove the highlighting autocommands for this buffer.
                    vim.lsp.buf.clear_references()
                    vim.api.nvim_clear_autocmds({ group = 'LspHighlight', buffer = event2.buf })
                end,
            })
        end

        -- Format on save
        if client.supports_method('textDocument/formatting') then
            -- Create a clearing augroup for managing format on save.
            local formatonsave_augroup = vim.api.nvim_create_augroup('LspFormatOnSave', { clear = true })
            -- Create a new autocommand that will run just before the buffer is written to a file ('BufWritePre').
            vim.api.nvim_create_autocmd('BufWritePre', {
                buffer = event.buf, -- This autocommand is specific to the current buffer.
                -- A unique augroup for this buffer's format-on-save to manage it separately.
                group = formatonsave_augroup,
                -- The function to run when the event is triggered.
                callback = function()
                    -- Format the buffer synchronously before saving.
                    -- 'async = false' is important to ensure formatting completes before the file is written.
                    vim.lsp.buf.format({ async = false, id = client.id })
                end,
            })
        end


        -- Check if the client supports CodeLens, which displays contextual info and actions in the code.
        if client.supports_method(client, 'textDocument/codeLens') then
            -- Create a new augroup for this buffer's CodeLens autocommands.
            local codelens_augroup = vim.api.nvim_create_augroup('LspCodeLens' .. event.buf, { clear = true })

            -- Refresh CodeLens information automatically.
            -- This ensures the lenses are up-to-date as you navigate and edit.
            vim.api.nvim_create_autocmd({ 'BufEnter', 'CursorHold', 'InsertLeave' }, {
                buffer = event.buf,
                group = codelens_augroup,
                callback = vim.lsp.codelens.refresh,
            })

            -- Immediately refresh CodeLens when the LSP attaches.
            vim.lsp.codelens.refresh()

            -- Add a keymap to execute the action associated with the CodeLens under the cursor.
            vim.keymap.set('n', '<leader>tC', vim.lsp.codelens.run, { desc = '[C]ode [L]ens Action' })
        end



        -- Check if capability works with Current LSP
        local cap_check = 'textDocument/codeLens'
        if client.supports_method(cap_check) then
            -- Enable inline completion for this client and buffer
            -- The exact method for enabling might vary slightly depending on your setup
            -- and any specific inline completion plugins you are using.
            -- For native Neovim support, you would typically rely on the client's capabilities.
            print("Yay! LSP Client supports: ", cap_check)
            -- You might need to add specific configuration here if using a plugin like Tabby
            -- to integrate with its agent for inline completions.
        else
            vim.notify("BOO! LSP client does not support. ", cap_check, vim.log.levels.WARN)
        end


        -- Add capabilities here
        -- Add capabilities here


        --- {{{ LSP related keymaps
        local map = function(keys, func, desc, mode)
            mode = mode or 'n' -- Default to normal mode if no mode is specified.
            -- vim.keymap.set is the modern way to set keymaps in Neovim.
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        -- Define keymaps for common LSP actions, using the 'map' helper function.
        -- These provide quick access to LSP functionality like renaming, code actions, and navigation.
        -- Neovim global defaults keymaps (https://neovim.io/doc/user/lsp.html#lsp-defaults),
        -- some replaced by Telescope functionality.
        map('gra', vim.lsp.buf.code_action, 'Code [A]ction', { 'n', 'x' }) -- Works in normal and visual mode
        map('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
        map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
        map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
        map('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')
        map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')
        -- Additional Telescope LSP Picker keymaps
        -- (https://github.com/nvim-telescope/telescope.nvim?tab=readme-ov-file#neovim-lsp-pickers)
        map('grw', require('telescope.builtin').lsp_workspace_symbols, 'Open [W]orkspace Symbols')
        map('grx', require('telescope.builtin').diagnostics, 'Telescope [X]Diagnostics')
        map('grT', require('telescope.builtin').treesitter, 'Telescope [T]reesitter')
        map('grd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
        map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
        map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')
        -- }}}
    end,
})

-- Improve LSPs UI {{{
local icons = {
    Class = " ",
    Color = " ",
    Constant = " ",
    Constructor = " ",
    Enum = " ",
    EnumMember = " ",
    Event = " ",
    Field = " ",
    File = " ",
    Folder = " ",
    Function = "󰊕 ",
    Interface = " ",
    Keyword = " ",
    Method = "ƒ ",
    Module = "󰏗 ",
    Property = " ",
    Snippet = " ",
    Struct = " ",
    Text = " ",
    Unit = " ",
    Value = " ",
    Variable = " ",
}

local completion_kinds = vim.lsp.protocol.CompletionItemKind
for i, kind in ipairs(completion_kinds) do
    completion_kinds[i] = icons[kind] and icons[kind] .. kind or kind
end
-- }}}
