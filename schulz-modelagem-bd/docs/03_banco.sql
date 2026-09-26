-- ============================================================
-- Projeto Aplicado I - Entrega 02
-- Modelagem e Implementacao de Banco de Dados
-- Empresa parceira: Schulz S.A.
-- SGBD: SQLite (executar no VS Code)
-- ============================================================
-- Esquema relacional com 3 entidades principais:
--   1. Tecnico      (Tecnico / Solicitante)
--   2. Equipamento  (MMC e instrumentos)
--   3. Medicao      (registros de medicao)
-- ============================================================

-- Desabilita a checagem de FK durante a criacao das tabelas
-- (necessario em SQLite porque FKs sao verificadas por tabela).
PRAGMA foreign_keys = OFF;

-- ============================================================
-- Tabela 1: Tecnico / Solicitante
-- ============================================================
CREATE TABLE Tecnico (
    id_tecnico   INTEGER PRIMARY KEY AUTOINCREMENT,
    nome         TEXT    NOT NULL UNIQUE,
    funcao       TEXT    NOT NULL,
    setor        TEXT,
    contato      TEXT,
    CHECK (funcao IN ('metrologista', 'responsavel_tecnico', 'solicitante'))
);

-- ============================================================
-- Tabela 2: Equipamento
-- ============================================================
CREATE TABLE Equipamento (
    id_equipamento     INTEGER PRIMARY KEY AUTOINCREMENT,
    cod_mmc            TEXT    NOT NULL UNIQUE,  -- preservado como texto
    fornecedor         TEXT,
    tag                TEXT,
    numero_serie       TEXT,
    modelo             TEXT,
    ultima_calibracao  TEXT,                     -- ISO YYYY-MM-DD
    proxima_calibracao TEXT                      -- ISO YYYY-MM-DD
);

-- ============================================================
-- Tabela 3: Medicao
-- ============================================================
CREATE TABLE Medicao (
    id_medicao       INTEGER PRIMARY KEY AUTOINCREMENT,
    id_tecnico       INTEGER NOT NULL,
    id_equipamento   INTEGER NOT NULL,
    data_medicao     TEXT    NOT NULL,           -- ISO YYYY-MM-DD (RN04)
    plano_medicao    TEXT    NOT NULL,
    ordem_servico    TEXT    NOT NULL,           -- codigo (F4)
    part_no          TEXT    NOT NULL,           -- codigo (F7)
    caracteristica   TEXT    NOT NULL,
    valor_nominal    REAL,
    valor_obtido     REAL    NOT NULL,
    tolerancia_sup   REAL,                       -- com sinal (RN07)
    tolerancia_inf   REAL,                       -- com sinal (RN07)
    desvio           REAL,
    unidade          TEXT,
    fonte_origem     TEXT    NOT NULL,           -- RN22 - rastreabilidade
    status_auditoria TEXT    NOT NULL
                            DEFAULT 'VALIDO'
                            CHECK (status_auditoria IN ('VALIDO', 'PENDENTE_CORRECAO')),

    FOREIGN KEY (id_tecnico)     REFERENCES Tecnico(id_tecnico),
    FOREIGN KEY (id_equipamento) REFERENCES Equipamento(id_equipamento)
);

-- Reabilita a checagem de FK
PRAGMA foreign_keys = ON;

-- ============================================================
-- Indices de apoio (opcionais, melhoram consultas por FK)
-- ============================================================
CREATE INDEX idx_medicao_tecnico     ON Medicao(id_tecnico);
CREATE INDEX idx_medicao_equipamento ON Medicao(id_equipamento);
CREATE INDEX idx_medicao_data        ON Medicao(data_medicao);
CREATE INDEX idx_medicao_status      ON Medicao(status_auditoria);

-- ============================================================
-- Comentarios finais
-- ============================================================
-- Integridade referencial: ON DELETE padrao do SQLite = RESTRICT,
-- impedindo excluir Tecnico ou Equipamento com medicoes associadas
-- (alinhado a RN22 - rastreabilidade).
--
-- Para executar este script:
--   1. Abrir o VS Code com a extensao SQLite instalada.
--   2. Criar um arquivo vazio, ex.: schulz.db.
--   3. Selecionar todo o conteudo deste arquivo e executar.
-- ============================================================
