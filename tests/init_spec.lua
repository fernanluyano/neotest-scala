-- Mock neotest.lib before loading the adapter to avoid the full neotest dependency chain.
package.loaded["neotest.lib"] = {
    files = {
        match_root_pattern = function()
            return function(path) return vim.fn.fnamemodify(path, ":h") end
        end,
        read_lines = function(path)
            if vim.fn.filereadable(path) == 0 then
                error("File not found: " .. path)
            end
            return vim.fn.readfile(path)
        end,
    },
    treesitter = {
        parse_positions = function() return nil end,
    },
    func_util = {
        index = function(t, v)
            for _, val in ipairs(t) do
                if val == v then return true end
            end
            return false
        end,
    },
}

local adapter = require("neotest-scala")({ framework = "scalatest", runner = "bloop" })

describe("ScalaNeotestAdapter.create", function()
    local original_cmd
    local original_notify
    local cmd_calls
    local notify_calls

    before_each(function()
        original_cmd = vim.cmd
        original_notify = vim.notify
        cmd_calls = {}
        notify_calls = {}
        vim.cmd = function(cmd) table.insert(cmd_calls, cmd) end
        vim.notify = function(msg, level) table.insert(notify_calls, { msg = msg, level = level }) end
    end)

    after_each(function()
        vim.cmd = original_cmd
        vim.notify = original_notify
    end)

    it("warns when file is not under src/main/scala", function()
        adapter.create("/some/random/Foo.scala")
        assert.equals(1, #notify_calls)
        assert.equals(vim.log.levels.WARN, notify_calls[1].level)
        assert.equals(0, #cmd_calls)
    end)

    it("opens existing test file without creating a new one", function()
        local base = vim.fn.tempname()
        local src = base .. "/src/main/scala/Foo.scala"
        local test = base .. "/src/test/scala/FooTest.scala"
        vim.fn.mkdir(vim.fn.fnamemodify(src, ":h"), "p")
        vim.fn.mkdir(vim.fn.fnamemodify(test, ":h"), "p")
        vim.fn.writefile({ "class Foo {}" }, src)
        vim.fn.writefile({ "class FooTest {}" }, test)

        adapter.create(src)

        assert.equals("edit " .. test, cmd_calls[1])
        assert.equals(0, #notify_calls)
    end)

    it("creates AnyFunSuite test file with package for scalatest", function()
        local base = vim.fn.tempname()
        local src = base .. "/src/main/scala/com/example/Foo.scala"
        vim.fn.mkdir(vim.fn.fnamemodify(src, ":h"), "p")
        vim.fn.writefile({ "package com.example", "", "class Foo {}" }, src)

        adapter.create(src)

        local test_path = base .. "/src/test/scala/com/example/FooTest.scala"
        assert.equals(1, vim.fn.filereadable(test_path))
        local lines = vim.fn.readfile(test_path)
        assert.equals("package com.example", lines[1])
        assert.equals("", lines[2])
        assert.equals("import org.scalatest.funsuite.AnyFunSuite", lines[3])
        assert.equals("", lines[4])
        assert.equals("class FooTest extends AnyFunSuite {", lines[5])
        assert.equals("", lines[6])
        assert.equals("}", lines[7])
    end)

    it("creates test file without package line when source has none", function()
        local base = vim.fn.tempname()
        local src = base .. "/src/main/scala/Foo.scala"
        vim.fn.mkdir(vim.fn.fnamemodify(src, ":h"), "p")
        vim.fn.writefile({ "class Foo {}" }, src)

        adapter.create(src)

        local test_path = base .. "/src/test/scala/FooTest.scala"
        assert.equals(1, vim.fn.filereadable(test_path))
        local lines = vim.fn.readfile(test_path)
        assert.equals("import org.scalatest.funsuite.AnyFunSuite", lines[1])
        assert.equals("", lines[2])
        assert.equals("class FooTest extends AnyFunSuite {", lines[3])
    end)

    it("notifies with INFO after creating the test file", function()
        local base = vim.fn.tempname()
        local src = base .. "/src/main/scala/Bar.scala"
        vim.fn.mkdir(vim.fn.fnamemodify(src, ":h"), "p")
        vim.fn.writefile({}, src)

        adapter.create(src)

        assert.equals(1, #notify_calls)
        assert.equals(vim.log.levels.INFO, notify_calls[1].level)
    end)

    it("handles multiline chained package declarations", function()
        local base = vim.fn.tempname()
        local src = base .. "/src/main/scala/Baz.scala"
        vim.fn.mkdir(vim.fn.fnamemodify(src, ":h"), "p")
        vim.fn.writefile({ "package com", "package example", "", "class Baz {}" }, src)

        adapter.create(src)

        local test_path = base .. "/src/test/scala/BazTest.scala"
        local lines = vim.fn.readfile(test_path)
        assert.equals("package com.example", lines[1])
    end)
end)
