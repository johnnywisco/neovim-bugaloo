--- ~/.config/nvim/lua/config/utils.lua
--
-- An updated utility module for dynamically inspecting LSP client capabilities.
-- This version iterates over all capabilities reported by the server, making it
-- future-proof and comprehensive.

local M = {}

--- Formats the value of a capability for clean printing.
-- @param value The capability value (can be boolean, table, string, number).
-- @return A string representation of the capability's status.
local function format_capability_value(value)
    if value == nil or value == false then
        return "false"
    elseif value == true then
        return "true"
    elseif type(value) == 'table' then
        -- vim.tbl_isempty is a Neovim 0.11+ API to check if a table is empty.
        -- An empty table often signifies support with default options.
        if vim.tbl_isempty(value) then
            return "true (no options)"
        else
            return "true (options configured)"
        end
    elseif type(value) == 'string' or type(value) == 'number' then
        -- Some capabilities can be strings or numbers.
        return tostring(value)
    else
        -- Fallback for any other unexpected data types.
        return "unknown"
    end
end

--- Prints all capabilities of active LSP clients for the current buffer.
-- This function dynamically inspects the server_capabilities table to show
-- everything the LSP server supports, sorted alphabetically for clarity.
function M.inspect_lsp_capabilities()
    -- Get all LSP clients attached to the current buffer.
    local clients = vim.lsp.get_clients({ bufnr = 0 })

    if not clients or #clients == 0 then
        print("No active LSP clients for the current buffer.")
        return
    end

    print("--- Active LSP Client Capabilities (Dynamically Inspected) ---")

    for _, client in ipairs(clients) do
        print("\nClient: " .. client.name .. " (ID: " .. client.id .. ")")

        local capabilities = client.server_capabilities

        -- To ensure a consistent and readable output, we'll collect all the keys,
        -- sort them, and then print the key-value pairs.
        local sorted_keys = {}
        for key, _ in pairs(capabilities) do
            table.insert(sorted_keys, key)
        end
        table.sort(sorted_keys)

        if #sorted_keys == 0 then
            print("  Server reported no capabilities.")
        else
            for _, key in ipairs(sorted_keys) do
                local value = capabilities[key]
                -- Use string formatting for alignment to make the output easy to scan.
                -- %-35s creates a left-aligned string padded to 35 characters.
                local formatted_key = string.format("%-35s", key .. ":")
                print(string.format("  - %s %s", formatted_key, format_capability_value(value)))
            end
        end
    end
    print("\n-------------------------------------------------------------")
end

return M
