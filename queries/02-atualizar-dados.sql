-- =============================================================================
-- Atividade Prática - Aula 9 (Computação em Nuvem)
-- 02-atualizar-dados.sql : atualização CONTROLADA do banco JÁ EXISTENTE.
--
-- Contexto: o volume radar-db-dados já contém os dados da 1ª execução
-- (Matemática/Biologia/História). O 01-schema.sql NÃO roda de novo (só executa
-- na 1ª criação do volume). Este script substitui os dados de demonstração
-- pelos registros oficiais do professor, SEM recriar tabelas nem o volume.
--
-- NÃO usa DROP TABLE, DROP DATABASE, nem mexe no volume. Apenas limpa as
-- linhas e reinsere, reiniciando as sequências de ID para casar com os
-- exemplos (provas 1 e 2; questões 1, 2 e 3).
--
-- Uso:
--   docker cp queries\02-atualizar-dados.sql radar-db:/tmp/02-atualizar-dados.sql
--   docker exec -i radar-db psql -U radar -d radar -f /tmp/02-atualizar-dados.sql
-- =============================================================================

BEGIN;

-- Esvazia as duas tabelas e REINICIA as sequências de id (RESTART IDENTITY).
-- CASCADE garante que questoes (que referencia provas) seja truncada junto,
-- respeitando a FK. Nenhuma estrutura é removida; só o conteúdo.
TRUNCATE TABLE questoes, provas RESTART IDENTITY CASCADE;

-- Reinsere os dados oficiais. Com as sequências reiniciadas, provas recebe
-- id 1 (2025) e 2 (2024); questoes recebe id 1, 2 e 3 na ordem abaixo.
INSERT INTO provas (ano, nome) VALUES
    (2025, 'ENEM regular'),
    (2024, 'ENEM regular');

INSERT INTO questoes (prova_id, assunto, enunciado, dificuldade) VALUES
    (1, 'Ecologia',   'Questão demonstrativa sobre ecossistemas',       'média'),
    (1, 'Matemática', 'Questão demonstrativa sobre funções',            'alta'),
    (2, 'Ecologia',   'Questão demonstrativa sobre cadeias alimentares', 'baixa');

COMMIT;

-- Conferência imediata (deve mostrar 2 provas e 3 questões):
SELECT 'provas'   AS tabela, count(*) AS total FROM provas
UNION ALL
SELECT 'questoes' AS tabela, count(*) AS total FROM questoes;

SELECT * FROM provas   ORDER BY id;
SELECT * FROM questoes ORDER BY id;
