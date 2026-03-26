local M = {}

local function trim(s)
    return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function compile_tokens(template)
    local lines = {}
    local cursor = 1

    lines[#lines + 1] = "local __buf = {}"
    lines[#lines + 1] = "local function write(v) table.insert(__buf, tostring(v)) end"
    lines[#lines + 1] = "local escape = assert(escape, \"escape function is required\")"

    while true do
        local open_start, open_end = string.find(template, "<%", cursor, true)

        if not open_start then
            local literal = string.sub(template, cursor)
            if literal ~= "" then
                lines[#lines + 1] = "write(" .. string.format("%q", literal) .. ")"
            end
            break
        end

        local literal = string.sub(template, cursor, open_start - 1)
        if literal ~= "" then
            lines[#lines + 1] = "write(" .. string.format("%q", literal) .. ")"
        end

        local close_start, _ = string.find(template, "%>", open_end + 1, true)
        if not close_start then
            return nil, "Template invalido: tag <% sem fechamento %>"
        end

        local raw_block = string.sub(template, open_end + 1, close_start - 1)
        local left_trimmed = raw_block:gsub("^%s+", "")

        if string.sub(left_trimmed, 1, 1) == "=" then
            local expr = trim(string.sub(left_trimmed, 2))
            if expr == "" then
                return nil, "Template invalido: bloco <%= %> vazio"
            end
            lines[#lines + 1] = "write(escape(" .. expr .. "))"
        else
            local code = trim(raw_block)
            if code ~= "" then
                lines[#lines + 1] = code
            end
        end

        cursor = close_start + 2
    end

    lines[#lines + 1] = "return table.concat(__buf)"

    return table.concat(lines, "\n")
end

function M.compile(template_source)
    if type(template_source) ~= "string" then
        return nil, "Template invalido: esperado string"
    end

    return compile_tokens(template_source)
end

return M
