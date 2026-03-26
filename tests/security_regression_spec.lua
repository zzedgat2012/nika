local parser = require("parser")
local sandbox = require("sandbox")
local router = require("router")
local db = require("db")

describe("Security regression suite", function()
    it("envelopa expressoes com escape no parser", function()
        local compiled, compile_err = parser.compile("<p><%= Request.query.nome %></p>")
        assert(compiled ~= nil, "parser nao compilou: " .. tostring(compile_err))

        local compiled_str = compiled or ""
        assert.is_not_nil(compiled_str:find("write%(escape%(Request%.query%.nome%)%)"))
    end)

    it("bloqueia acesso a os no sandbox", function()
        local rendered, render_err = sandbox.render_template("return os.execute('id')", { query = {} }, { headers = {} },
            {
                escape = function(v)
                    return tostring(v)
                end
            })

        assert.is_nil(rendered)
        assert.are.equal("Erro interno", render_err)
    end)

    it("bloqueia path traversal no router", function()
        local path, route_err = router.resolve("/%2e%2e/%2e%2e/etc/passwd", { templates_root = "views" })
        assert.is_nil(path)
        assert.are.equal("invalid_path", route_err)
    end)

    it("bloqueia SQL inseguro e permite SQL parametrizado", function()
        local fake_driver = {
            execute = function(sql)
                return { ok = true, sql = sql }
            end
        }

        local ok_set = db.set_driver(fake_driver)
        assert.is_true(ok_set)

        local result, db_err = db.execute("SELECT * FROM users WHERE id = " .. "1", {})
        assert.is_nil(result)
        assert.are.equal("invalid_query", db_err)

        local safe_result, safe_err = db.execute("SELECT * FROM users WHERE id = ?", { 1 })
        assert.is_not_nil(safe_result)
        assert.is_nil(safe_err)
    end)
end)
