# Entrega 02 — Modelagem e Implementação de Banco de Dados
**Projeto Aplicado I — Schulz S.A.**

Arquivos desta pasta:

| Arquivo | Conteúdo | Formato |
|---|---|---|
| `01_estrutura.md` | Explicação da divisão do banco em 3 entidades (Tecnico/Solicitante, Equipamento, Medicao) e justificativa para evitar dados duplicados. | Markdown (≥20 linhas) |
| `02_dicionario.md` | Tabela com 26 campos mapeados (4 de Tecnico + 7 de Equipamento + 15 de Medicao) e seus tipos no SQLite. | Tabela Markdown (≥12 campos) |
| `03_banco.sql` | Script DDL com `CREATE TABLE` das 3 tabelas, PKs, FKs, CHECK constraints e índices. | SQL executável no SQLite |

## Como executar o `03_banco.sql`

1. Abrir o VS Code.
2. Instalar a extensão **SQLite** (por exemplo, `alexcvzz.vscode-sqlite`).
3. Criar/abrir um arquivo de banco vazio, ex.: `schulz.db`.
4. Abrir `03_banco.sql` e executar (Ctrl+Shift+P → `SQLite: Run Query`).
5. Confirmar que as três tabelas (`Tecnico`, `Equipamento`, `Medicao`) aparecem listadas.

## Decisões de modelagem (resumo)

- **3 entidades**: `Tecnico`, `Equipamento`, `Medicao` (escopo do roteiro da Entrega 02).
- **Tecnico único** com campo `funcao` (`metrologista` / `responsavel_tecnico` / `solicitante`).
- **Códigos alfanuméricos preservados como `TEXT`** (`cod_mmc`, `part_no`, `ordem_servico`, `tag`, `numero_serie`).
- **Datas em `TEXT` no formato ISO `YYYY-MM-DD`** (SQLite não tem tipo DATE nativo).
- **`ON DELETE RESTRICT`** (default do SQLite) impede excluir técnico/equipamento com medições vinculadas (RN22).
- **`status_auditoria` controlado por CHECK** com `DEFAULT 'VALIDO'`, refletindo a regra do ETL que marca pendências.

## Próximas entregas

Itens fora do escopo desta entrega, previstos para fases seguintes do projeto:

- Entidades `Padrao`, `Criterio`, `Incerteza` e `Certificado` (já mapeadas no dicionário da Entrega 01).
- Carga inicial a partir do pipeline ETL em Python.
- Consultas de histórico e emissão do certificado com aprovação técnica.
