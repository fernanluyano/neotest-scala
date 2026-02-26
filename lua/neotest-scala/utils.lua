local lib = require("neotest.lib")

local M = {}

--- Strip quotes from the (captured) test position.
---@param position neotest.Position
---@return string
function M.get_position_name(position)
    if position.type == "test" then
        local value = string.gsub(position.name, '"', "")
        return value
    end
    return position.name
end

---Get a package name from the top of the file.
---Supports chained package declarations spanning multiple lines (e.g. `package foo` then `package bar`).
---@return string|nil
function M.get_package_name(file)
    local success, lines = pcall(lib.files.read_lines, file)
    if not success then
        return nil
    end
    local parts = {}
    for _, line in ipairs(lines) do
        local pkg = line:match("^package%s+([%w%.]+)")
        if pkg then
            table.insert(parts, pkg)
        elseif #parts > 0 then
            break
        end
    end
    if #parts > 0 then
        return table.concat(parts, ".") .. "."
    end
    return ""
end

return M
