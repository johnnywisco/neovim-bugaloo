local function augroup(name)
    return vim.api.nvim_create_augroup("usernvim_" .. name, { clear = true })
end


-- {{{ Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
    group = augroup("highlight_yank"),
    callback = function()
        (vim.hl or vim.highlight).on_yank()
    end,
})
-- }}}

-- {{{ Reopen buffer to last cursor location
vim.api.nvim_create_autocmd("BufReadPost", {
    group = augroup("last_loc"),
    callback = function(event)
        local exclude = { "gitcommit" }
        local buf = event.buf
        if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
            return
        end
        vim.b[buf].lazyvim_last_loc = true
        local mark = vim.api.nvim_buf_get_mark(buf, '"')
        local lcount = vim.api.nvim_buf_line_count(buf)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})
-- }}}


-- {{{  LSP Settings
--
-- Format file on save
-- This autocommand is the central point for configuring LSP features for a given buffer.
-- It runs once whenever a language server client attaches to a buffer (`LspAttach` event).
-- We use a single autocommand to keep all buffer-specific LSP setup in one place.
vim.api.nvim_create_autocmd('LspAttach', {
    -- Create a new augroup or clear the existing one. This prevents autocommands from
    -- being duplicated every time the configuration is reloaded.
    group = vim.api.nvim_create_augroup('UserLspAttach', { clear = true }),

    -- The callback function that executes when the LspAttach event is triggered.
    -- 'event' contains information about the attached client and the buffer.
    callback = function(event)
        -- Get the LSP client object and the buffer number from the event data.
        -- These are used throughout the function to configure the LSP for the current buffer.
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        local bufnr = event.buf

        -- vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        --     buffer = bufnr,
        --     group = vim.api.nvim_create_augroup('LspDiagnosticHover' .. bufnr, { clear = true }),
        --     callback = function()
        --         local opts = {
        --             focusable = false,
        --             close_events = { 'BufLeave', 'CursorMoved', 'InsertEnter', 'FocusLost' },
        --             border = 'rounded',
        --             source = 'always',
        --             prefix = ' ',
        --             scope = 'cursor',
        --         }
        --         vim.diagnostic.open_float(nil, opts)
        --     end,
        -- })

        --============================================================================--
        -- PART 1: SETUP LSP FORMATTING ON SAVE
        --============================================================================--

        -- Check if the attached language server client supports the 'textDocument/formatting' method.
        -- This ensures we only try to set up format-on-save if the LSP is capable of it.
        if client and client.supports_method('textDocument/formatting') then
            -- Create a new autocommand that will run just before the buffer is written to a file ('BufWritePre').
            vim.api.nvim_create_autocmd('BufWritePre', {
                buffer = bufnr, -- This autocommand is specific to the current buffer.
                -- A unique augroup for this buffer's format-on-save to manage it separately.
                group = vim.api.nvim_create_augroup('LspFormatOnSave' .. bufnr, { clear = true }),
                -- The function to run when the event is triggered.
                callback = function()
                    -- Format the buffer synchronously before saving.
                    -- 'async = false' is important to ensure formatting completes before the file is written.
                    vim.lsp.buf.format({ async = false, id = client.id })
                end,
            })
        end


        -- vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        --     group = vim.api.nvim_create_augroup('LspDiagnosticHover', { clear = true }),
        --     callback = function()
        --         -- Only open float if there are diagnostics at the cursor position
        --         if next(vim.diagnostic.get_line_diagnostics()) then
        --             vim.diagnostic.open_float(nil, { focus = false })
        --         end
        --     end,
        -- })




        --============================================================================--
        -- PART 2: SETUP LSP KEYMAPS AND UI FEATURES
        --============================================================================--

        -- A helper function to simplify creating keymaps that are local to the current buffer.
        -- This prevents LSP keymaps from being active in buffers without an attached LSP client.
        local map = function(keys, func, desc, mode)
            mode = mode or 'n' -- Default to normal mode if no mode is specified.
            -- vim.keymap.set is the modern way to set keymaps in Neovim.
            vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
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

        -- A compatibility function to handle API differences between Neovim 0.10 and 0.11
        -- when checking if an LSP client supports a specific method for a given buffer.
        ---@param lsp_client vim.lsp.Client
        ---@param method vim.lsp.protocol.Method
        ---@return boolean
        local function client_supports_method(lsp_client, method)
            if vim.fn.has('nvim-0.11') == 1 then
                return lsp_client:supports_method(method, { bufnr = bufnr })
            else
                return lsp_client.supports_method(method)
            end
        end

        -- Automatically highlight all references of the symbol under the cursor.
        -- This checks if the client supports the 'textDocument/documentHighlight' capability.
        if client and client_supports_method(client, 'textDocument/documentHighlight') then
            -- Create a non-clearing augroup for managing highlight-related autocommands.
            local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })

            -- When the cursor stays still for a moment ('CursorHold'), highlight the symbol's references.
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                buffer = bufnr,
                group = highlight_augroup,
                callback = vim.lsp.buf.document_highlight,
            })

            -- When the cursor moves ('CursorMoved'), clear the highlights.
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                buffer = bufnr,
                group = highlight_augroup,
                callback = vim.lsp.buf.clear_references,
            })

            -- Add a cleanup mechanism for when the LSP client detaches.
            vim.api.nvim_create_autocmd('LspDetach', {
                group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
                callback = function(event2)
                    -- Clear any remaining highlights and remove the highlighting autocommands for this buffer.
                    vim.lsp.buf.clear_references()
                    vim.api.nvim_clear_autocmds({ group = 'lsp-highlight', buffer = event2.buf })
                end,
            })
        end

        -- Add a keymap to toggle inlay hints if the LSP client supports them.
        -- Inlay hints are extra informational text displayed in your code (e.g., type hints).
        if client and client_supports_method(client, 'textDocument/inlayHint') then
            map('<leader>th', function()
                -- Toggle the display of inlay hints for the current buffer.
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }))
            end, '[T]oggle Inlay [H]ints')
        end

        --============================================================================--
        -- PART 3: SETUP CODELENS
        --============================================================================--

        -- Check if the client supports CodeLens, which displays contextual info and actions in the code.
        if client and client_supports_method(client, 'textDocument/codeLens') then
            -- Create a new augroup for this buffer's CodeLens autocommands.
            local codelens_augroup = vim.api.nvim_create_augroup('LspCodeLens' .. bufnr, { clear = true })

            -- Refresh CodeLens information automatically.
            -- This ensures the lenses are up-to-date as you navigate and edit.
            vim.api.nvim_create_autocmd({ 'BufEnter', 'CursorHold', 'InsertLeave' }, {
                buffer = bufnr,
                group = codelens_augroup,
                callback = vim.lsp.codelens.refresh,
            })

            -- Immediately refresh CodeLens when the LSP attaches.
            vim.lsp.codelens.refresh()

            -- Add a keymap to execute the action associated with the CodeLens under the cursor.
            map('<leader>tC', vim.lsp.codelens.run, '[C]ode [L]ens Action')
        end
    end,
})

-- }}}
