# 02 — Dicionário de Dados do Sistema

**Projeto Aplicado I — Entrega 02: Modelagem e Implementação de Banco de Dados**
**Empresa parceira:** Schulz S.A.
**SGBD:** SQLite

Este dicionário mapeia todos os campos extraídos do pipeline ETL em Python para as três entidades do banco (`Tecnico`, `Equipamento`, `Medicao`), com tipo de dado e descrição da finalidade.

---

## Entidade 1 — `Tecnico` (Técnico / Solicitante)

| Campo | Tipo SQLite | Restrição | Finalidade |
|---|---|---|---|
| `id_tecnico` | INTEGER | PK AUTOINCREMENT | Identificar unicamente cada profissional no banco (surrogate key). |
| `nome` | TEXT | NOT NULL, UNIQUE | Nome do profissional (metrologista, responsável técnico ou solicitante). O `UNIQUE` evita cadastros duplicados e facilita o mapeamento automático do ETL (nome → id). |
| `funcao` | TEXT | NOT NULL | Papel do profissional no processo. Valores previstos: `metrologista`, `responsavel_tecnico`, `solicitante`. |
| `setor` | TEXT | — | Setor do profissional dentro da Schulz S.A. (informação vinda do cadastro auxiliar). |
| `contato` | TEXT | — | E-mail, ramal ou outro meio de contato. |

---

## Entidade 2 — `Equipamento`

| Campo | Tipo SQLite | Restrição | Finalidade |
|---|---|---|---|
| `id_equipamento` | INTEGER | PK AUTOINCREMENT | Identificar unicamente cada equipamento cadastrado. |
| `cod_mmc` | TEXT | NOT NULL, UNIQUE | Código da Máquina de Medição por Coordenadas. Preservado como **texto** porque pode conter zeros à esquerda ou sufixos alfanuméricos. |
| `fornecedor` | TEXT | — | Nome do fornecedor do equipamento. |
| `tag` | TEXT | — | Identificação interna (TAG) usada pela Schulz para localizar o instrumento (RN05). |
| `numero_serie` | TEXT | — | Número de série informado pelo fabricante. |
| `modelo` | TEXT | — | Modelo do equipamento. |
| `ultima_calibracao` | TEXT | — | Data da última calibração realizada, no formato ISO `YYYY-MM-DD`. |
| `proxima_calibracao` | TEXT | — | Data prevista para a próxima calibração, no formato ISO `YYYY-MM-DD`. |

> Observação: `tag`, `numero_serie`, `modelo`, `ultima_calibracao` e `proxima_calibracao` não são trazidos pelo pipeline ETL atual. Ficam como campos `TEXT` sem `NOT NULL` para serem preenchidos em outra etapa (cadastro manual ou outro arquivo), mantendo o modelo extensível.

---

## Entidade 3 — `Medicao`

| Campo | Tipo SQLite | Restrição | Finalidade |
|---|---|---|---|
| `id_medicao` | INTEGER | PK AUTOINCREMENT | Identificar unicamente cada medição registrada. |
| `id_tecnico` | INTEGER | NOT NULL, FK → `Tecnico(id_tecnico)` | Quem executou ou solicitou a medição. Garante o vínculo `Medicao ↔ Tecnico`. |
| `id_equipamento` | INTEGER | NOT NULL, FK → `Equipamento(id_equipamento)` | MMC ou instrumento medido. Garante o vínculo `Medicao ↔ Equipamento`. |
| `data_medicao` | TEXT | NOT NULL | Data em que a medição foi realizada, no formato ISO `YYYY-MM-DD` (RN04 — padronização de datas). |
| `plano_medicao` | TEXT | NOT NULL | Identificação do plano de medição utilizado (vem da célula `B4` do relatório MMC). |
| `ordem_servico` | TEXT | NOT NULL | Código da ordem de serviço (vem da célula `F4`). Preservado como texto — pode conter letras. |
| `part_no` | TEXT | NOT NULL | Código de identificação da peça (vem da célula `F7`). Preservado como texto — pode conter zeros à esquerda. |
| `caracteristica` | TEXT | NOT NULL | Nome da característica avaliada (coluna `A` da tabela de medições). |
| `valor_nominal` | REAL | — | Valor de referência esperado para a característica (coluna `C`). |
| `valor_obtido` | REAL | NOT NULL | Valor efetivamente medido (coluna `B`). Obrigatório conforme regra do ETL. |
| `tolerancia_sup` | REAL | — | Limite superior de tolerância (coluna `D`), preservando o sinal. |
| `tolerancia_inf` | REAL | — | Limite inferior de tolerância (coluna `E`), preservando o sinal. |
| `desvio` | REAL | — | Diferença entre o valor obtido e o valor nominal (coluna `F`). |
| `unidade` | TEXT | — | Unidade de medida do resultado (ex.: `mm`). Hoje não é trazida pelo ETL — fica preparada para cargas futuras (RN08). |
| `fonte_origem` | TEXT | NOT NULL | String com o caminho do arquivo original e a aba da planilha (ex.: `relatorio.xlsx -> Aba: Report`). Atende à RN22 — rastreabilidade da origem dos dados. |
| `status_auditoria` | TEXT | NOT NULL, CHECK (`status_auditoria` IN ('VALIDO','PENDENTE_CORRECAO')), DEFAULT `'VALIDO'` | Situação da medição após a validação do ETL. `VALIDO` indica que passou em todos os campos obrigatórios; `PENDENTE_CORRECAO` indica que precisa de revisão antes de virar certificado (RN19). |

---

## Contagem total

| Entidade | Campos mapeados (sem PK surrogate) |
|---|---|
| `Tecnico` | 4 |
| `Equipamento` | 7 |
| `Medicao` | 15 |
| **Total** | **26** |

Mínimo exigido pelo roteiro: 12 campos. Entrega supera o mínimo.

---

## Tipagem — convenções adotadas

- **INTEGER** para chaves primárias surrogate (`AUTOINCREMENT`).
- **TEXT** para todo identificador alfanumérico (`cod_mmc`, `part_no`, `ordem_servico`, `tag`, `numero_serie`) — preserva zeros à esquerda e suporta letras.
- **TEXT** para datas, no formato ISO `YYYY-MM-DD` — SQLite não tem tipo DATE nativo e o pipeline ETL já gera nesse formato.
- **REAL** para todos os valores numéricos de medição e tolerância, com sinal preservado.
- **TEXT** com `CHECK` para campos de valores controlados (`status_auditoria`).
