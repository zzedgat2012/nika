---
name: "Nika Lua Module Implementation"
description: "Implementa módulos Lua no Nika com foco em contrato req/res, simplicidade, segurança e auditabilidade sem dependências externas."
argument-hint: "Informe nome do módulo e contexto/assinatura aprovada para implementação."
agent: "Nika Principal Lua Developer"
---

@Nika Principal Lua Developer

**Tarefa:** Implementar o módulo {{nome_do_modulo}}.

**Contexto:**
{{contexto_implementacao}}

Gere o código Lua respeitando estritamente as regras do Nika:
1. O fluxo deve seguir o contrato agnóstico (se for handler, receber req e retornar res).
2. Utilizar table.concat para manipulação massiva de strings.
3. Não utilizar dependências externas (apenas standard library do Lua).
4. Aplicar pcall em áreas de risco e injetar logs (nika_audit.log_error / nika_audit.log_security) em falha de validação ou erro de sistema.

Formato obrigatório da resposta:
1. Código Lua completo.
2. Justificativa de segurança curta (XSS, SQLi, isolamento e tratamento de erros quando aplicável).

Restrições:
- Evitar over-engineering e abstrações desnecessárias.
- Preservar legibilidade e auditabilidade.
- Se faltar contexto crítico para implementação segura, assumir defaults mínimos e sinalizar no comentário TODO dentro do código.
