-- =============================================================================
-- Atividade Prática - Aula 9 (Computação em Nuvem)
-- desafios.sql : desafios do roteiro (etapa 6).
-- Implementados: A, C, D. (O desafio E - backup com pg_dump - está no
-- procedimento de backup: ver ../backups/README-backup.md.)
-- =============================================================================

-- ----------------------------------------------------------------------------
-- DESAFIO A - Filtro de Ecologia
-- Apenas CONSULTA, sem inserir registros. Os dados oficiais já têm duas
-- questões de Ecologia (provas 2025 e 2024). Resultado esperado: 2 linhas.
-- ----------------------------------------------------------------------------
SELECT * FROM questoes
WHERE assunto = 'Ecologia';

-- ----------------------------------------------------------------------------
-- DESAFIO C - Integridade referencial (FK) com prova_id inexistente
-- Esperado: ERRO de violação de chave estrangeira. NÃO deve inserir a linha.
-- A prova de id = 999 não existe em provas.
-- ----------------------------------------------------------------------------
-- Execute e observe o erro:
--   ERROR:  insert or update on table "questoes" violates foreign key
--           constraint "questoes_prova_id_fkey"
--   DETAIL: Key (prova_id)=(999) is not present in table "provas".
INSERT INTO questoes (prova_id, assunto, enunciado, dificuldade) VALUES
    (999, 'Física', 'Questão órfã - prova inexistente.', 'alta');

-- ----------------------------------------------------------------------------
-- DESAFIO D - Restrição NOT NULL
-- Esperado: ERRO de violação de NOT NULL em 'assunto'. NÃO deve inserir.
-- ----------------------------------------------------------------------------
-- Execute e observe o erro:
--   ERROR:  null value in column "assunto" of relation "questoes"
--           violates not-null constraint
INSERT INTO questoes (prova_id, assunto, enunciado, dificuldade) VALUES
    (1, NULL, 'Questão sem assunto.', 'baixa');

-- Bônus de verificação do CHECK de dificuldade (valor inválido):
--   ERROR:  new row for relation "questoes" violates check constraint
--           "questoes_dificuldade_check"
-- INSERT INTO questoes (prova_id, assunto, enunciado, dificuldade) VALUES
--     (1, 'Química', 'Dificuldade inválida.', 'altíssima');
