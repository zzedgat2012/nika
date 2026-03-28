local json_util = require("json_util")

local M = {}

local function contains(haystack, needle)
    return tostring(haystack or ""):lower():find(needle, 1, true) ~= nil
end

local function escape_html(value)
    local str = tostring(value or "")
    str = str:gsub("&", "&amp;")
    str = str:gsub("<", "&lt;")
    str = str:gsub(">", "&gt;")
    str = str:gsub('"', "&quot;")
    str = str:gsub("'", "&#39;")
    return str
end

local function escape_xml(value)
    local str = tostring(value or "")
    str = str:gsub("&", "&amp;")
    str = str:gsub("<", "&lt;")
    str = str:gsub(">", "&gt;")
    str = str:gsub('"', "&quot;")
    str = str:gsub("'", "&apos;")
    return str
end

function M.negotiate(accept_header, default_format)
    local header = tostring(accept_header or "")
    local fallback = default_format or "json"

    if contains(header, "application/json") then
        return "json"
    end
    if contains(header, "application/xml") or contains(header, "text/xml") then
        return "xml"
    end
    if contains(header, "text/html") then
        return "html"
    end

    return fallback
end

function M.render(payload, format)
    local safe_payload = payload or {}
    local target = format or "json"

    if target == "xml" then
        local body = table.concat({
            "<?xml version=\"1.0\" encoding=\"UTF-8\"?>",
            "<error>",
            "<status>" .. escape_xml(safe_payload.status) .. "</status>",
            "<code>" .. escape_xml(safe_payload.error) .. "</code>",
            "<message>" .. escape_xml(safe_payload.message) .. "</message>",
            "</error>"
        })
        return body, "application/xml; charset=utf-8"
    end

    if target == "html" then
        local body = table.concat({
            "<html><head><title>Error</title></head><body>",
            "<h1>" .. escape_html(safe_payload.status) .. "</h1>",
            "<p>" .. escape_html(safe_payload.message) .. "</p>",
            "</body></html>"
        })
        return body, "text/html; charset=utf-8"
    end

    return json_util.encode(safe_payload), "application/json; charset=utf-8"
end

return M
