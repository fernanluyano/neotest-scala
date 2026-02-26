-- Note: This test file was generated with AI assistance. The solution (utils.lua) was not.

-- Mock neotest.lib before loading utils to avoid pulling in the full neotest dependency chain.
package.loaded["neotest.lib"] = {
    files = {
        read_lines = function(path)
            if vim.fn.filereadable(path) == 0 then
                error("File not found: " .. path)
            end
            return vim.fn.readfile(path)
        end,
    },
}

local utils = require("neotest-scala.utils")

--- Write lines to a temp file and return its path.
local function write_temp_file(lines)
    local path = vim.fn.tempname()
    vim.fn.writefile(lines, path)
    return path
end

describe("get_package_name", function()
    it("returns package name with trailing dot for single package line", function()
        local path = write_temp_file({ "package foo", "", "class Bar" })
        assert.equals("foo.", utils.get_package_name(path))
    end)

    it("joins two chained package lines", function()
        local path = write_temp_file({ "package foo", "package bar", "", "class Baz" })
        assert.equals("foo.bar.", utils.get_package_name(path))
    end)

    it("joins three chained package lines", function()
        local path = write_temp_file({ "package foo", "package bar", "package baz", "", "class Qux" })
        assert.equals("foo.bar.baz.", utils.get_package_name(path))
    end)

    it("handles dotted package name on a single line", function()
        local path = write_temp_file({ "package foo.bar", "", "class Baz" })
        assert.equals("foo.bar.", utils.get_package_name(path))
    end)

    it("stops at first non-package line", function()
        local path = write_temp_file({ "package foo", "import bar.Baz", "package ignored" })
        assert.equals("foo.", utils.get_package_name(path))
    end)

    it("returns empty string when no package declaration", function()
        local path = write_temp_file({ "class Foo {}", "" })
        assert.equals("", utils.get_package_name(path))
    end)

    it("returns empty string for empty file", function()
        local path = write_temp_file({})
        assert.equals("", utils.get_package_name(path))
    end)

    it("returns nil when file does not exist", function()
        assert.is_nil(utils.get_package_name("/nonexistent/path/file.scala"))
    end)
end)

describe("get_position_name", function()
    it("strips quotes from test position name", function()
        local position = { type = "test", name = '"my test name"' }
        assert.equals("my test name", utils.get_position_name(position))
    end)

    it("returns name unchanged for non-test positions", function()
        local position = { type = "namespace", name = '"MySpec"' }
        assert.equals('"MySpec"', utils.get_position_name(position))
    end)

    it("returns name unchanged when no quotes present", function()
        local position = { type = "test", name = "my test name" }
        assert.equals("my test name", utils.get_position_name(position))
    end)
end)
