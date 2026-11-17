-- =============================================================================
-- Atividade Prática - Aula 9 (Computação em Nuvem)
-- 01-schema.sql : modelagem relacional + dados fictícios.
--
-- Executado automaticamente pelo PostgreSQL na PRIMEIRA criação do volume
-- (pasta /docker-entrypoint-initdb.d). Dados 100% fictícios do roteiro.
-- =============================================================================

-- ----------------------------------------------------------------------------
-- 2. MODELAGEM
-- ----------------------------------------------------------------------------

CREATE TABLE provas (
    id   SERIAL PRIMARY KEY,
    ano  INTEGER NOT NULL,
    nome TEXT    NOT NULL
);

CREATE TABLE questoes (
    id          SERIAL PRIMARY KEY,
    prova_id    INTEGER NOT NULL REFERENCES provas(id),
    assunto     TEXT    NOT NULL,
    enunciado   TEXT    NOT NULL,
    dificuldade TEXT    CHECK (dificuldade IN ('baixa', 'média', 'alta'))
);

-- ----------------------------------------------------------------------------
-- 3. DADOS (fictícios) - registros oficiais dos exemplos do professor.
--    Duas provas "ENEM regular" (2025 e 2024) + três questões demonstrativas.
--    Ecologia aparece em duas provas; Matemática apenas na de 2025.
-- ----------------------------------------------------------------------------

INSERT INTO provas (ano, nome) VALUES
    (2025, 'ENEM regular'),
    (2024, 'ENEM regular');

INSERT INTO questoes (prova_id, assunto, enunciado, dificuldade) VALUES
    (1, 'Ecologia',   'Questão demonstrativa sobre ecossistemas',       'média'),
    (1, 'Matemática', 'Questão demonstrativa sobre funções',            'alta'),
    (2, 'Ecologia',   'Questão demonstrativa sobre cadeias alimentares', 'baixa');
