-- Set <space> as the leader key
-- See `:help mapleader`
-- NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- {{{ Disable netrw and set termguicolors for NvimTree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
-- optionally enable 24-bit colour
vim.opt.termguicolors = true
-- }}}

-- Set the colorscheme
-- vim.cmd('colorscheme nord')

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- Python venv where "pynvim" library installed.
vim.g.python_host_prog = "~/projects/.venv/neovim/bin/python"
vim.g.python3_host_prog = "~/projects/.venv/neovim/bin/python"

-- Enable spell checking and set language
vim.opt.spell = true
vim.opt.spelllang = "en_us"
vim.opt.spelloptions = "camel"

-- Display line numbers
vim.o.number = true

-- Display relative line numbers
-- vim.o.relativenumber = true

-- Disbable show mode since it has been replaced by mini.statusline.
vim.o.showmode = false

-- A tab is 4 spaces. If you think otherwise, you are wrong
vim.opt.tabstop = 4

-- If tabs are 4 spaces, indents should be 1 tab. Vim defaulting to 8 is just fucking silly
vim.opt.shiftwidth = 4

-- Tab is 4 spaces.
vim.opt.softtabstop = 4

-- Change tabs to 4 spaces
vim.o.expandtab = true

-- How wide is my number column? I have it set to 2, though I might bump it up to 3 so include more info there. Not sure yet
vim.opt.numberwidth = 3

-- Enable mouse mode, can be useful for resizing splits for example!
vim.o.mouse = "a"

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.o.signcolumn = "yes"

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Sets how Neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
--
--  Notice listchars is set using `vim.opt` instead of `vim.o`.
--  It is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
--   See `:help lua-options`
--   and `:help lua-options-guide`
vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
vim.o.inccommand = "split"

-- Show which line your cursor is on
vim.o.cursorline = true

vim.opt.cursorlineopt = "number"

-- Minimal number of screen lines to keep above and below the cursor.
vim.o.scrolloff = 15

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true

-- Set default border for all floating windows
vim.opt.winborder = 'rounded'

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'
vim.schedule(function()
    vim.o.clipboard = "unnamedplus"
end)

-- NOTE: EXPERIMENT WITH OPTIONS BELOW

-- {{{ NOTE: Diagnostic Config See :help vim.diagnostic.Opts
vim.diagnostic.config {
    severity_sort = true,
    float = { border = 'rounded', source = 'if_many' },
    underline = { severity = vim.diagnostic.severity.ERROR },
    update_in_insert = true,
    signs = vim.g.have_nerd_font and {
        text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
        },
    } or {},
    virtual_text = {
        source = 'if_many',
        spacing = 2,
        format = function(diagnostic)
            local diagnostic_message = {
                [vim.diagnostic.severity.ERROR] = diagnostic.message,
                [vim.diagnostic.severity.WARN] = diagnostic.message,
                [vim.diagnostic.severity.INFO] = diagnostic.message,
                [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
        end,
    },
}
-- }}}

-- 1. Set the folding method to look for markers in the text
vim.opt.foldmethod = 'marker'

-- 2. Define the start and end markers
-- The format is a string with the start and end markers separated by a comma.
vim.opt.foldmarker = '-- {{{,-- }}}'

-- Optional, but recommended for a better experience:
vim.opt.foldlevelstart = 99 -- Start with all folds open when you enter a buffer
vim.opt.foldenable = true   -- Make sure folding is enabled



-- vim.opt.guicursor = 'n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175'

-- {{{
-- Enable Telescope extensions if they are installed
-- }}}
