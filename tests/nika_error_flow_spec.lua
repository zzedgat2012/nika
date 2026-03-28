local hooks = require("hooks")

describe("Nika error flow (Phase 13)", function()
    local nika

    before_each(function()
        hooks.clear()
        package.loaded["nika"] = nil
        nika = require("nika")
        nika.reset_error_handler()
    end)

    it("usa content negotiation para erro de upload", function()
        local res = nika.handle_request({
            method = "POST",
            path = "/upload",
            headers = {
                Accept = "application/xml"
            },
            upload_error = "payload_too_large"
        }, {
            auto_register_default_hooks = false
        })

        assert.are.equal(413, res.status)
        assert.are.equal("application/xml; charset=utf-8", res.headers["Content-Type"])
        assert.is_not_nil(res.body:find("<error>", 1, true))
    end)

    it("permite configurar error handler global customizado", function()
        nika.set_error_handler(function(err)
            return {
                status = 418,
                headers = {
                    ["Content-Type"] = "application/json; charset=utf-8"
                },
                body = '{"error":"custom"}'
            }
        end)

        local res = nika.handle_request({
            method = "POST",
            path = "/upload",
            upload_error = "any"
        }, {
            auto_register_default_hooks = false
        })

        assert.are.equal(418, res.status)
        assert.is_not_nil(res.body:find("custom", 1, true))

        nika.reset_error_handler()
    end)
end)
