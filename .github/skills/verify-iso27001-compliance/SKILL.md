---
name: verify-iso27001-compliance
description: 'Cruza proposta de arquitetura ou diff de PR com o Anexo A.14 da ISO 27001, identifica lacunas de desenvolvimento seguro, logs de ações críticas e proteção de credenciais.'
argument-hint: 'Cole a descrição da feature, ADR ou diff do PR para avaliação de conformidade A.14.'
user-invocable: true
---

# Verify ISO27001 Compliance (A.14)

## O que esta skill produz
Gera um relatório de conformidade focado no Anexo A.14 da ISO 27001 (aquisição, desenvolvimento e manutenção de sistemas), incluindo:
- controles atendidos
- controles ausentes
- evidências encontradas no texto/diff
- riscos associados
- recomendações mínimas de correção

## Quando usar
- Revisão de propostas de arquitetura antes de implementação.
- Revisão de PRs para validar desenvolvimento seguro.
- Gate de segurança para features que alteram autenticação, autorização, dados sensíveis, logs, integrações e segredos.

## Entrada esperada
- String com proposta arquitetural, descrição técnica, ADR ou diff de código.

## Procedimento
1. Mapear escopo e ativos.
- Identificar fluxo de dados, pontos de entrada, dependências, componentes impactados e dados sensíveis.

2. Extrair evidências de desenvolvimento seguro (A.14).
- Verificar requisitos de segurança definidos para a mudança.
- Verificar validação de entrada, sanitização e tratamento de erros.
- Verificar controles para mudanças em produção e manutenção.

3. Verificar logs de ações críticas.
- Confirmar se eventos críticos possuem auditoria: autenticação, falhas de autenticação, elevação de privilégio, acesso a dados sensíveis, mudanças de configuração e erros de segurança.
- Confirmar se logs têm contexto mínimo: ator, ação, resultado, timestamp, origem e correlação.

4. Verificar proteção de credenciais e segredos.
- Garantir que não há segredos hardcoded no diff/proposta.
- Garantir uso de armazenamento seguro e rotação.
- Garantir não exposição de segredos em logs, erros ou mensagens ao usuário.

5. Classificar lacunas e impacto.
- Atribuir severidade para cada lacuna: LOW, MEDIUM, HIGH, CRITICAL.
- Relacionar impacto em confidencialidade, integridade e disponibilidade.

6. Definir recomendação mínima e verificável.
- Propor correções diretas, de baixo acoplamento e auditáveis.
- Priorizar bloqueadores antes de recomendações de melhoria.

## Regras de decisão
- Se faltar log para ação crítica, marcar como não conforme.
- Se houver risco de vazamento de credencial/segredo, marcar não conforme e elevar severidade para no mínimo HIGH.
- Se não houver evidência suficiente no input, marcar como "evidência insuficiente" e listar o que falta para concluir.
- Se todos os pontos críticos estiverem cobertos, marcar conforme com observações residuais.

## Critérios de qualidade e conclusão
- Toda não conformidade deve citar evidência objetiva do texto/diff.
- Toda não conformidade deve ter recomendação prática de correção.
- O relatório deve separar claramente: Conforme, Não Conforme, Evidência Insuficiente.
- Deve incluir seção explícita para logs e seção explícita para credenciais.

## Formato de saída recomendado
```json
{
  "overall_status": "NON_COMPLIANT",
  "standard": "ISO 27001 Annex A.14",
  "summary": "Lacunas relevantes de desenvolvimento seguro foram encontradas.",
  "controls": [
    {
      "control": "A.14 - Logging de ações críticas",
      "status": "NON_COMPLIANT",
      "severity": "HIGH",
      "evidence": "Falta log de auditoria na falha de autenticação.",
      "recommendation": "Registrar falhas de autenticação com ator, origem, timestamp e resultado sem expor segredo."
    },
    {
      "control": "A.14 - Proteção de credenciais",
      "status": "NON_COMPLIANT",
      "severity": "CRITICAL",
      "evidence": "Token de API exposto no código fonte.",
      "recommendation": "Mover segredo para cofre/variável de ambiente, rotacionar imediatamente e remover do histórico de código."
    }
  ],
  "missing_controls": [
    "Falta log de auditoria na falha de autenticação",
    "Credenciais hardcoded"
  ],
  "next_actions": [
    "Implementar logs imutáveis para eventos críticos",
    "Aplicar gestão de segredos com rotação"
  ]
}
```

## Restrições
- Não inventar evidências que não existam no input.
- Não transformar a análise em auditoria completa de toda ISO 27001; foco em A.14 com ênfase em logs e credenciais.
- Não sugerir dependências complexas quando houver correção mínima viável.
