local error_handler = require("error_handler")

describe("Error handler (Phase 13)", function()
    it("oculta detalhes internos em prod para erro 500", function()
        local handler = error_handler.create_default({ env = "prod" })
        local res = handler({
            status = 500,
            code = "internal_error",
            message = "stack trace interno"
        }, {
            req = {
                headers = {
                    Accept = "application/json"
                }
            }
        })

        assert.are.equal(500, res.status)
        assert.is_not_nil(res.body:find("Internal Error", 1, true))
        assert.is_nil(res.body:find("stack trace interno", 1, true))
    end)

    it("mantem detalhes em dev para erro 500", function()
        local handler = error_handler.create_default({ env = "dev" })
        local res = handler({
            status = 500,
            code = "internal_error",
            message = "falha de compilacao",
            details = "line 8"
        }, {
            req = {
                headers = {
                    Accept = "application/json"
                }
            }
        })

        assert.are.equal(500, res.status)
        assert.is_not_nil(res.body:find("falha de compilacao", 1, true))
        assert.is_not_nil(res.body:find("line 8", 1, true))
    end)

    it("aplica fallback seguro quando handler custom falha", function()
        local res = error_handler.apply(function()
            error("boom")
        end, {
            status = 500,
            code = "internal_error",
            message = "x"
        }, {
            req = {
                headers = {
                    Accept = "application/json"
                }
            }
        })

        assert.are.equal(500, res.status)
        assert.is_not_nil(res.body:find("error_handler_failure", 1, true))
    end)
end)
