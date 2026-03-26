local function inject_security_headers(req, res)
    -- Garante que a tabela de headers exista
    res.headers = res.headers or {}

    -- Protecao contra Clickjacking
    res.headers["X-Frame-Options"] = "DENY"
    -- Previne MIME-Sniffing (forca o navegador a respeitar o Content-Type)
    res.headers["X-Content-Type-Options"] = "nosniff"
    -- Forca HTTPS estrito
    res.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"
    -- Mitigacao base para XSS (permite scripts apenas da propria origem)
    res.headers["Content-Security-Policy"] = "default-src 'self'"

    -- Retorna false para indicar que o fluxo deve continuar (sem short-circuit)
    return false
end

return inject_security_headers
