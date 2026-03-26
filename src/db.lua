local M = {}

local has_audit, audit = pcall(require, "nika_audit")

local driver = nil

local function log_security(message, context)
    if has_audit and audit and type(audit.log_security) == "function" then
        audit.log_security(message, context)
    end
end

local function log_error(message, context)
    if has_audit and audit and type(audit.log_error) == "function" then
        audit.log_error(message, context)
    end
end

local function count_placeholders(sql)
    local _, count = sql:gsub("%?", "?")
    return count
end

local function is_dense_array(tbl)
    if type(tbl) ~= "table" then
        return false
    end

    local n = #tbl
    for k, _ in pairs(tbl) do
        if type(k) ~= "number" or k < 1 or k % 1 ~= 0 or k > n then
            return false
        end
    end
    return true
end

local function validate_param_value(v)
    local t = type(v)
    if t == "nil" or t == "boolean" or t == "number" or t == "string" then
        return true
    end
    return false
end

local function validate_sql(sql, params)
    if type(sql) ~= "string" or sql == "" then
        return nil, "invalid_sql"
    end

    if type(params) ~= "table" then
        return nil, "params_must_be_table"
    end

    if not is_dense_array(params) then
        return nil, "params_must_be_dense_array"
    end

    local placeholders = count_placeholders(sql)
    if placeholders == 0 then
        return nil, "placeholders_required"
    end

    if placeholders ~= #params then
        return nil, "placeholder_param_mismatch"
    end

    if sql:find(";", 1, true) then
        return nil, "multi_statement_not_allowed"
    end

    for i = 1, #params do
        if not validate_param_value(params[i]) then
            return nil, "invalid_param_type"
        end
    end

    return true
end

function M.set_driver(db_driver)
    if type(db_driver) ~= "table" then
        return nil, "driver_must_be_table"
    end

    local supports_execute = type(db_driver.execute) == "function"
    local supports_prepared = type(db_driver.execute_prepared) == "function"

    if not supports_execute and not supports_prepared then
        return nil, "driver_missing_execute"
    end

    driver = db_driver
    return true
end

function M.execute(sql, params)
    if type(driver) ~= "table" then
        log_error("Driver de banco nao configurado", { op = "execute" })
        return nil, "driver_not_configured"
    end

    local ok, validation_err = validate_sql(sql, params)
    if not ok then
        log_security("Query bloqueada por politica SQL segura", {
            reason = validation_err,
            sql = tostring(sql)
        })
        return nil, "invalid_query"
    end

    local call_ok, result_or_err = pcall(function()
        if type(driver.execute_prepared) == "function" then
            return driver.execute_prepared(sql, params)
        end

        return driver.execute(sql, table.unpack(params))
    end)

    if not call_ok then
        log_error("Erro de execucao no driver", {
            error = tostring(result_or_err)
        })
        return nil, "database_error"
    end

    return result_or_err
end

return M
