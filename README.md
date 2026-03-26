# Nika

Framework web minimalista em Lua, agnostico de servidor e orientado a seguranca by design (ISO 27001).

## Principios
- Simples e auditavel (zero-magic)
- Contrato agnostico req/res
- Templates estilo ASP Classico (`.nika`)
- Defesa nativa contra XSS, SSTI, SQLi e Path Traversal

## Estrutura
- `src/`: core do framework
- `hooks/`: hooks nativos de runtime
- `views/`: templates `.nika`
- `tests/`: suite de testes estilo Busted (runner local)
- `scripts/`: utilitarios de smoke/execucao
- `docs/`: relatorios de validacao por fase

## Quickstart
### 1) Requisitos
- Lua 5.4+ (compativel com fallback 5.1 em partes do sandbox)

### 2) Smoke test do adapter CGI
```bash
lua scripts/smoke_cgi.lua
```
Resultado esperado:
- `SMOKE CGI: OK`

### 3) Rodar suite de testes (integracao + regressao de seguranca)
```bash
lua tests/run_all.lua
```
Resultado esperado:
- `ALL SPECS PASSED`

### 4) Exemplo minimo de uso no seu adapter
```lua
package.path = "./src/?.lua;./?.lua;" .. package.path

local nika = require("nika")

local req = {
    method = "GET",
    path = "/",
    query = { nome = "Mundo" },
    headers = {}
}

local res = nika.handle_request(req, {
    templates_root = "views"
})

print(res.status)
print(res.body)
```

## Regras de seguranca importantes
- Nunca concatenar input em SQL
- Sempre escapar output dinamico em HTML
- Templates rodam em sandbox restrito
- Hooks e fluxo do request executam com tratamento defensivo e logs de auditoria

## Documentacao adicional
- Roadmap do MVP: `ROADMAP.md`
- Revisoes por fase: `docs/`
