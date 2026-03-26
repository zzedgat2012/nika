local parser = require("parser")
local sandbox = require("sandbox")
local router = require("router")
local db = require("db")

local M = {}

local function assert_true(value, message)
    if not value then
        error(message)
    end
end

local function assert_eq(actual, expected, message)
    if actual ~= expected then
        error((message or "assert_eq failed") .. ": expected=" .. tostring(expected) .. ", actual=" .. tostring(actual))
    end
end

function M.run()
    -- XSS: <%= %> deve ser envelopado por escape()
    local compiled, compile_err = parser.compile("<p><%= Request.query.nome %></p>")
    assert_true(compiled ~= nil, "parser nao compilou: " .. tostring(compile_err))
    local compiled_str = compiled or ""
    assert_true(compiled_str:find("write%(escape%(Request%.query%.nome%)%)") ~= nil, "expressao dinamica sem escape")

    -- SSTI: sandbox nao deve permitir os.execute
    local ssti_code = "return os.execute('id')"
    local rendered, render_err = sandbox.render_template(ssti_code, { query = {} }, { headers = {} }, {
        escape = function(v)
            return tostring(v)
        end
    })
    assert_true(rendered == nil, "sandbox deveria bloquear acesso a os")
    assert_eq(render_err, "Erro interno", "erro seguro de sandbox")

    -- Path Traversal: router deve bloquear
    local path, route_err = router.resolve("/%2e%2e/%2e%2e/etc/passwd", { templates_root = "views" })
    assert_true(path == nil, "router deveria bloquear traversal")
    assert_eq(route_err, "invalid_path", "erro esperado para traversal")

    -- SQLi: wrapper deve bloquear query sem placeholder
    local fake_driver = {
        execute = function(sql)
            return { ok = true, sql = sql }
        end
    }

    local ok_set = db.set_driver(fake_driver)
    assert_true(ok_set == true, "driver deveria ser configurado")

    local result, db_err = db.execute("SELECT * FROM users WHERE id = " .. "1", {})
    assert_true(result == nil, "query insegura deveria ser bloqueada")
    assert_eq(db_err, "invalid_query", "erro esperado para SQL inseguro")

    -- SQL seguro deve passar
    local safe_result, safe_err = db.execute("SELECT * FROM users WHERE id = ?", { 1 })
    assert_true(safe_result ~= nil, "query segura deveria executar")
    assert_true(safe_err == nil, "query segura nao deveria retornar erro")

    return true
end

return M
