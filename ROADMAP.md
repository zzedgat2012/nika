### Fase 1: Fundação e Rastreabilidade (ISO 27001)
Antes de processar qualquer requisição, o framework precisa saber como registrar eventos de segurança e como empacotar os dados de entrada e saída no formato agnóstico.

| Tarefa | Descrição | Agente Responsável | Definition of Done (DoD) |
| :--- | :--- | :--- | :--- |
| **1. Módulo de Auditoria (`nika_audit.lua`)** | Criar o sistema de logs imutáveis para falhas de sistema (`log_error`) e anomalias de acesso (`log_security`). | 💻 **Desenvolvedor** | Módulo escreve logs estruturados (JSON ou texto formatado) com timestamp, sem quebrar a execução (usando `pcall`). |
| **2. Revisão de Trilha de Auditoria** | Validar se os logs contêm contexto suficiente para a ISO 27001 (Anexo A.14), sem vazar dados sensíveis (senhas, tokens). | 🛡️ **Arquiteto** | Relatório de aprovação garantindo que não há vazamento de PII nos logs gerados. |
| **3. Fábrica de Request/Response** | Definir as tabelas base genéricas `req` (method, path, query, body) e `res` (status, headers, body). | 💻 **Desenvolvedor** | Estruturas de dados criadas com metatables defensivas (read-only onde aplicável). |

---

### Fase 2: O Motor ASP (Parser & Sandbox)
O coração do Nika. É aqui que garantimos que o desenvolvedor final terá a experiência do ASP Clássico sem abrir brechas para injeção de código (RCE/SSTI).

| Tarefa | Descrição | Agente Responsável | Definition of Done (DoD) |
| :--- | :--- | :--- | :--- |
| **1. Parser de Templates (`parser.lua`)** | Converter o arquivo `.nika` em código Lua puro, transformando `<%= %>` em chamadas seguras envelopadas por `escape()`. | 💻 **Desenvolvedor** | Parser lê HTML com Lua, otimiza com `table.insert` e retorna string Lua válida. Zero concatenação `..` em loops. |
| **2. Validação contra SSTI/XSS** | Tentar quebrar o parser enviando strings maliciosas e aspas não escapadas para avaliar vazamento de contexto. | 🛡️ **Arquiteto** | Aprovação de segurança confirmando que código injetado via HTML vira string literal (`%q`). |
| **3. Motor de Sandbox (`sandbox.lua`)** | Implementar o carregamento do código compilado isolado (`load` com `_ENV` ou `setfenv`), restringindo globais. | 💻 **Desenvolvedor** | Template roda sem acesso a `os`, `io`, `require` ou `_G`. Apenas a *allow-list* da API Nika está visível. |

---

### Fase 3: Ciclo de Vida e Interceptação
Com a renderização segura, precisamos direcionar a requisição correta para o arquivo correto e permitir a interceptação (autenticação, rate limit) de forma controlada.

| Tarefa | Descrição | Agente Responsável | Definition of Done (DoD) |
| :--- | :--- | :--- | :--- |
| **1. Roteador Minimalista (`router.lua`)** | Mapear `req.path` para o arquivo `.nika` correspondente no sistema de arquivos. Prevenir Path Traversal. | 💻 **Desenvolvedor** | Roteador resolve a URL para o path físico. Retorna 404 seguro se o arquivo não existir. |
| **2. Motor de Hooks (`hooks.lua`)** | Criar a estrutura para os 3 estágios permitidos: `before_request`, `before_render`, `after_request`. | 💻 **Desenvolvedor** | Hooks executam sequencialmente em `pcall`. Retorno `true` dá *short-circuit* imediato na requisição. |
| **3. Hook de Security Headers** | Implementar o hook nativo de `after_request` injetando CSP, HSTS, X-Frame-Options, etc. | 🛡️ **Arquiteto** | Hook padrão criado e validado contra OWASP Top 10 e compliance básico ISO. |

---

### Fase 4: Camada de Dados (Database Agnostic)
A última fronteira do MVP é permitir que o template acesse dados sem permitir SQL Injection.

| Tarefa | Descrição | Agente Responsável | Definition of Done (DoD) |
| :--- | :--- | :--- | :--- |
| **1. Wrapper de Banco de Dados (`db.lua`)** | Criar a interface padrão do Nika para comunicação com drivers (ex: LuaSQL ou FFI). Exigir uso de Prepared Statements (`?`). | 💻 **Desenvolvedor** | Módulo rejeita qualquer tentativa de query dinâmica. Aceita apenas a query parametrizada e o array de valores. |
| **2. Auditoria de SQL Injection** | Revisar o wrapper para garantir que não há bypass possível que permita concatenação de strings na query final. | 🛡️ **Arquiteto** | Pentest estático aprovando que queries malformadas acionam o `nika_audit` e retornam erro seguro. |

---

### Fase 5: Integração e Lançamento do MVP
Unindo as peças isoladas em um servidor web real para provar o conceito.

| Tarefa | Descrição | Agente Responsável | Definition of Done (DoD) |
| :--- | :--- | :--- | :--- |
| **1. Entrypoint Principal (`nika.lua`)** | Orquestrar o fluxo: Hook (before) -> Roteador -> Hook (render) -> Sandbox -> Hook (after) -> Retorno. | 💻 **Desenvolvedor** | Fluxo de dados entra e sai limpo, sem perda de estado ou mutação indesejada. |
| **2. Adapter de Servidor Web** | Escrever a "cola" entre um servidor web simples (ex: Xavante, ou um script CGI puro) e o contrato agnóstico do Nika. | 👨‍💻 **Tech Lead (Você)** | O servidor recebe requisições HTTP reais, traduz para a tabela `req`, roda o Nika, e traduz a tabela `res` para HTTP. |
| **3. Revisão Arquitetural Final** | Passar a pente fino o código inteiro contra a lista de bloqueios estabelecida nas *Cursorrules*. | 🛡️ **Arquiteto** | Selo de aprovação do MVP. Nenhuma dependência externa identificada. Código 100% auditável. |
