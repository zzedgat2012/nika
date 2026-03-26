local M = {}

local base_assert = assert
local suites = {}
local suite_stack = {}

local function current_suite()
    return suite_stack[#suite_stack]
end

local function fail(message)
    error(message or "assertion failed", 3)
end

local function make_assert_table()
    local out = {}

    out.is_true = function(value, message)
        if value ~= true then
            fail(message or ("expected true, got " .. tostring(value)))
        end
    end

    out.is_nil = function(value, message)
        if value ~= nil then
            fail(message or ("expected nil, got " .. tostring(value)))
        end
    end

    out.is_not_nil = function(value, message)
        if value == nil then
            fail(message or "expected non-nil value")
        end
    end

    out.are = {
        equal = function(expected, actual, message)
            if expected ~= actual then
                fail(message or ("expected=" .. tostring(expected) .. ", actual=" .. tostring(actual)))
            end
        end
    }

    return setmetatable(out, {
        __call = function(_, ...)
            return base_assert(...)
        end
    })
end

function M.install_globals()
    local previous = {
        describe = _G.describe,
        it = _G.it,
        before_each = _G.before_each,
        after_each = _G.after_each,
        assert = _G.assert
    }

    _G.assert = make_assert_table()

    _G.describe = function(name, fn)
        if type(name) ~= "string" or type(fn) ~= "function" then
            error("describe(name, fn) invalido")
        end

        local suite = {
            name = name,
            tests = {},
            before_each = nil,
            after_each = nil
        }

        suites[#suites + 1] = suite
        suite_stack[#suite_stack + 1] = suite
        fn()
        suite_stack[#suite_stack] = nil
    end

    _G.it = function(name, fn)
        local suite = current_suite()
        if not suite then
            error("it() deve ser usado dentro de describe()")
        end

        if type(name) ~= "string" or type(fn) ~= "function" then
            error("it(name, fn) invalido")
        end

        suite.tests[#suite.tests + 1] = {
            name = name,
            fn = fn
        }
    end

    _G.before_each = function(fn)
        local suite = current_suite()
        if not suite then
            error("before_each() deve ser usado dentro de describe()")
        end

        if type(fn) ~= "function" then
            error("before_each(fn) invalido")
        end

        suite.before_each = fn
    end

    _G.after_each = function(fn)
        local suite = current_suite()
        if not suite then
            error("after_each() deve ser usado dentro de describe()")
        end

        if type(fn) ~= "function" then
            error("after_each(fn) invalido")
        end

        suite.after_each = fn
    end

    return function()
        _G.describe = previous.describe
        _G.it = previous.it
        _G.before_each = previous.before_each
        _G.after_each = previous.after_each
        _G.assert = previous.assert
    end
end

function M.reset()
    suites = {}
    suite_stack = {}
end

function M.get_suites()
    return suites
end

return M
