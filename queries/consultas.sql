-- =============================================================================
-- Atividade Prática - Aula 9 (Computação em Nuvem)
-- consultas.sql : consultas SQL de demonstração (etapa 4).
--
-- Uso:
--   docker exec -it radar-db psql -U radar -d radar -f /tmp/consultas.sql
-- ou copie/cole cada bloco no psql interativo.
-- =============================================================================

-- 4.1 SELECT simples das tabelas -------------------------------------------
SELECT * FROM provas ORDER BY ano DESC;
SELECT * FROM questoes ORDER BY id;

-- 4.2 JOIN : cada questão com o nome/ano da sua prova ----------------------
SELECT q.id        AS questao_id,
       p.nome      AS prova,
       p.ano       AS ano,
       q.assunto,
       q.dificuldade,
       q.enunciado
FROM questoes q
JOIN provas p ON p.id = q.prova_id
ORDER BY q.id;

-- 4.3 Filtro por assunto ----------------------------------------------------
-- Dados oficiais: duas questões de Ecologia (provas 2025 e 2024).
SELECT id, assunto, dificuldade, enunciado
FROM questoes
WHERE assunto = 'Ecologia';

-- 4.4 Atualização de registro ----------------------------------------------
-- Ex.: rebaixar a dificuldade da questão de Matemática de 'alta' para 'média'.
UPDATE questoes
SET dificuldade = 'média'
WHERE assunto = 'Matemática';

-- Confirmação da atualização:
SELECT id, assunto, dificuldade FROM questoes WHERE assunto = 'Matemática';
