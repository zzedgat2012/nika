local db = require("db")
local dataware = require("dataware")

describe("Query Builder (Phase 11)", function()
    local calls

    before_each(function()
        calls = {}
        dataware.clear()

        db.set_driver({
            execute_prepared = function(sql, params)
                calls[#calls + 1] = { sql = sql, params = params }

                if sql:match("COUNT%(%*%)") then
                    return { { total = 2 } }
                end

                return {
                    { id = 1, name = "Alice" },
                    { id = 2, name = "Bob" }
                }
            end
        })
    end)

    it("monta select com where e tenant obrigatorio", function()
        local user = dataware.model("User")
            :table("users")
            :tenant("tenant_id")

        local rows, err = user:find(nil, { tenant_id = "t-1" })
            :where("active", "=", true)
            :order_by("id", "desc")
            :limit(10)
            :all()

        assert.is_not_nil(rows)
        assert.is_nil(err)
        assert.is_true(#calls >= 1)
        assert.is_true(calls[1].sql:find("tenant_id = %?") ~= nil)
    end)

    it("falha sem tenant quando tenant e obrigatorio", function()
        local user = dataware.model("User")
            :table("users")
            :tenant("tenant_id")

        local rows, err = user:find():all()
        assert.is_nil(rows)
        assert.are.equal("tenant_required", err)
    end)

    it("executa paginate com total", function()
        local user = dataware.model("User")
            :table("users")
            :tenant("tenant_id")

        local rows, total, err = user:find(nil, { tenant_id = "t-2" }):paginate(1, 5)
        assert.is_not_nil(rows)
        assert.are.equal(2, total)
        assert.is_nil(err)
    end)
end)
