# 01 — Estrutura do Banco de Dados (Modelo Conceitual Simplificado)

**Projeto Aplicado I — Entrega 02: Modelagem e Implementação de Banco de Dados**
**Empresa parceira:** Schulz S.A.
**Equipe:** Adriano Azevedo Paiva, Gabriel Onetta Matievicz, Jonathan Rabelo Costa, Rafael Ribeiro Péret de Santana, Thiago Zirke Conceição
**Orientador:** Prof. MSc. Hugo Menezes Barra
**SGBD:** SQLite (VS Code)

---

## 1. Visão geral

O banco de dados foi dividido em **3 entidades principais** que refletem diretamente o fluxo do laboratório de metrologia descrito na Entrega 01 e o que o pipeline ETL em Python já entrega hoje:

1. **Tecnico** — representa o profissional que executa a medição, valida ou solicita o serviço.
2. **Equipamento** — representa a Máquina de Medição por Coordenadas (MMC) e demais instrumentos que geram ou são alvos das medições.
3. **Medicao** — representa cada registro de medição importado, vinculado a um técnico e a um equipamento, com seus parâmetros e resultados.

A escolha por exatamente três entidades atende ao requisito do roteiro da Entrega 02 e mantém o modelo enxuto para esta fase do projeto. Entidades adicionais previstas nas próximas entregas (Padrão, Certificado, Critério, Incerteza) não entram agora porque dependem de requisitos ainda em amadurecimento.

---

## 2. Justificativa — por que três entidades e não menos (ou mais)

### 2.1 Por que evitar dados duplicados
O processo atual da Schulz S.A. trabalha com **planilhas paralelas** (planilha MMC, Registro MMC, Dispositivo de controle). Nessas estruturas é comum o mesmo metrologista, a mesma MMC ou a mesma peça aparecer repetida em várias linhas e em vários arquivos. Quando os dados ficam duplicados:

- Qualquer correção (ex.: troca de setor de um técnico, mudança de fornecedor de uma MMC) precisa ser replicada manualmente em cada ocorrência — alto risco de inconsistência.
- Não há como garantir que duas linhas "iguais" representem o mesmo objeto — podem ser homônimos ou códigos parecidos.
- Consultas simples (ex.: "todas as medições da MMC X no último mês") exigem varrer todas as planilhas.

A normalização em 3 entidades resolve isso porque:

- Cada **Tecnico** e cada **Equipamento** existe **uma única vez** no banco, identificado por uma chave primária surrogate (`id_tecnico`, `id_equipamento`).
- Cada **Medicao** referencia o técnico e o equipamento apenas pelo **id** (FK), sem repetir nome, código ou fornecedor.
- Qualquer atualização nas informações do profissional ou do instrumento vale imediatamente para todas as medições associadas, sem retrabalho.

### 2.2 Por que três entidades e não uma única "tabelona"
Juntar tudo em uma única tabela obrigaria a repetir nome do técnico, código da MMC e fornecedor em **cada linha de medição**. Isso reintroduz exatamente o problema que o banco deveria resolver — duplicação, inconsistência e difícil manutenção.

### 2.3 Por que três e não quatro ou cinco
O roteiro da Entrega 02 fixa o escopo em três entidades. Entidades como `Pendencia`, `Padrao`, `Criterio`, `Incerteza` e `Certificado` aparecem no dicionário da Entrega 01 e podem ser incorporadas em entregas futuras conforme o sistema evolui. Para esta fase, manter o foco nas três entidades principais garante um modelo coerente, executável e alinhado com os dados que o pipeline ETL já produz.

### 2.4 Por que essas três especificamente
- **Tecnico** cobre o ator humano (metrologista, responsável técnico, solicitante) — sem ele, a medição fica órfã.
- **Equipamento** cobre o instrumento gerador/alvo da medição — sem ele, não há o que calibrar.
- **Medicao** é o fato que conecta as duas entidades anteriores e carrega os parâmetros e resultados do processo. Sem ela, o banco não armazena o histórico que o sistema precisa consultar.

---

## 3. Relacionamentos

```
Tecnico  1 ───<  N  Medicao  N  >─── 1  Equipamento
```

- Um **Tecnico** pode realizar **muitas** medicoes (1:N).
- Um **Equipamento** pode estar em **muitas** medicoes (1:N).
- Cada **Medicao** pertence a **exatamente um** Tecnico e **exatamente um** Equipamento.

Esses dois relacionamentos 1:N são materializados no banco por duas chaves estrangeiras na tabela `Medicao`:

- `Medicao.id_tecnico` → `Tecnico.id_tecnico`
- `Medicao.id_equipamento` → `Equipamento.id_equipamento`

A integridade referencial do SQLite (default `RESTRICT`) garante que um técnico ou equipamento só possa ser excluído se não houver medições associadas — alinhado com a regra de negócio RN22 (rastreabilidade da origem dos dados).

---

## 4. Resumo das entidades

| Entidade | Papel no domínio | Chave primária | Volume esperado |
|---|---|---|---|
| `Tecnico` | Pessoas envolvidas no processo (metrologistas, responsáveis técnicos, solicitantes) | `id_tecnico` (INTEGER) | baixo (dezenas) |
| `Equipamento` | MMCs e demais instrumentos cadastrados | `id_equipamento` (INTEGER) | baixo/médio (dezenas a centenas) |
| `Medicao` | Cada característica medida em uma data/equipamento | `id_medicao` (INTEGER) | alto (cresce a cada calibração) |

A `Medicao` é a tabela que cresce mais rapidamente — é nela que o pipeline ETL faz carga contínua.

---

## 5. Próximos passos

1. Detalhar cada entidade no dicionário de dados (`02_dicionario.md`).
2. Gerar o script de criação das tabelas (`03_banco.sql`) com PKs, FKs e restrições.
3. Validar o script rodando direto no SQLite do VS Code.
4. Subir os três arquivos para o repositório GitHub e anexar o PDF explicativo na entrega do AVA até **02/10**.
