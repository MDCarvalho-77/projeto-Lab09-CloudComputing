# Relatório — Atividade Prática Aula 9 (Computação em Nuvem)

Trabalho acadêmico (UniSENAI/SC — CDIA). Baseado no Projeto Aplicado da equipe
Radar ENEM, usado aqui apenas como domínio didático. Atividade **independente**,
sem integração com o backend/frontend originais. Dados fictícios.

> Evidências reais da execução (logs `evidencias/v2-*` e dump
> `backups/radar_backup_v2.sql`) são versionadas de propósito, como
> comprovação da atividade.

---

## 1. Objetivo

Implementar um laboratório isolado de PostgreSQL com Docker, demonstrando:
banco relacional (tabelas `provas` e `questoes` com PK/FK e restrições),
consultas SQL (SELECT, JOIN, filtro, UPDATE) e **persistência de dados via
Docker Volume nomeado** (`radar-db-dados`), incluindo backup lógico com
`pg_dump`.

## 2. Metodologia

1. Diagnóstico do repositório (sem Docker/Postgres pré-existentes).
2. Verificação de conflito de porta no host.
3. Criação de stack Docker Compose isolada com volume nomeado.
4. Modelagem relacional + seed de dados fictícios via script de init.
5. Scripts SQL de consulta e de desafios.
6. Roteiro de persistência (remover container, manter volume, recriar).
7. Procedimento de backup lógico (`pg_dump`).

## 3. Comandos

Consolidados no `README.md` e automatizados em `validar.ps1`. Resumo:

- Subir: `docker compose up -d`
- Atualização controlada (banco existente): `psql ... -f /tmp/02-atualizar-dados.sql`
- Conferir: `docker ps`, `docker volume ls`, `\dt`, `\d questoes`
- Consultas: `psql ... -f /tmp/consultas.sql`
- Desafios: `psql ... -f /tmp/desafios.sql`
- Persistência: `docker compose down` → `docker compose up -d`
- Backup: `docker exec -t radar-db pg_dump -U radar -d radar > backups\radar_backup_v2.sql`

## 3.1 Dados oficiais (2ª rodada — correção)

A 1ª execução usou dados de demonstração genéricos. Esta rodada substitui por
os registros oficiais dos exemplos do professor, via atualização controlada
do banco já existente (`queries/02-atualizar-dados.sql`), **sem recriar o
volume**:

| Prova (id) | ano | nome |
|---|---|---|
| 1 | 2025 | ENEM regular |
| 2 | 2024 | ENEM regular |

| Questão (id) | prova_id | assunto | dificuldade |
|---|---|---|---|
| 1 | 1 | Ecologia | média |
| 2 | 1 | Matemática | alta |
| 3 | 2 | Ecologia | baixa |

## 4. Evidências

**A 2ª rodada foi executada de ponta a ponta com o Docker daemon acessível e o
container `radar-db` em execução.** Todos os resultados abaixo são reais,
capturados nos logs `v2-*` em `evidencias/`. As evidências da 1ª rodada
(`01-*` a `05-*`, `radar_backup.sql`) foram **preservadas** e não se misturam
com as da 2ª (`v2-*`, `radar_backup_v2.sql`).

Resultados reais observados:

| # | Verificação | Resultado | Evidência |
|---|---|---|---|
| 1 | Engine / container | `radar-db` (postgres:16) up, `5433->5432` | `v2-01-engine.log`, `v2-02-ps.log` |
| 2 | Volume do container | `radar-db-dados` → `/var/lib/postgresql/data` | `docker inspect` (sessão) |
| 3 | Atualização controlada | `BEGIN / TRUNCATE / INSERT 0 2 / INSERT 0 3 / COMMIT` | `v2-03-atualizacao.log` |
| 4 | Contagens | provas=2, questoes=3 | `v2-03-atualizacao.log` |
| 5 | Tabelas | `provas`, `questoes` | `v2-03-tabelas.log` |
| 6 | PK/FK/CHECK/NOT NULL | PK id; FK prova_id→provas; CHECK dificuldade | `v2-03-estrutura.log` |
| 7 | SELECT / JOIN | 2 provas; JOIN com 3 linhas | `v2-03-consultas.log` |
| 8 | Filtro Ecologia | **2 linhas** (ids 1 e 3) | `v2-03-consultas.log` |
| 9 | UPDATE Matemática | `UPDATE 1`, alta→média | `v2-03-consultas.log` |
| 10 | Desafio A | SELECT Ecologia = 2 linhas (sem inserir) | `v2-04-desafios.log` |
| 11 | Desafio C (FK) | ERRO `questoes_prova_id_fkey`, Key (prova_id)=(999) | `v2-04-desafios.log` |
| 12 | Desafio D (NOT NULL) | ERRO null em `assunto` viola not-null | `v2-04-desafios.log` |
| 13 | Desafio E (backup) | `radar_backup_v2.sql` = **8276 bytes** (não vazio) | `v2-04-backup-size.log` |
| 14 | Persistência ANTES | provas=2 / questoes=3 | `v2-05-antes.log` |
| 15 | Persistência DEPOIS | provas=2 / questoes=3 (iguais) | `v2-05-depois.log` |
| 16 | Dados finais (JOIN) | 3 questões oficiais intactas | `v2-05-dados-finais.log` |

Acentuação: comandos executados com console em UTF-8 (`chcp 65001` +
`[Console]::OutputEncoding`), acentos exibidos corretamente nos logs.

## 5. Modelo de dados

```
provas(id PK, ano NOT NULL, nome NOT NULL)
   ^
   | prova_id (FK, NOT NULL)
questoes(id PK, prova_id FK->provas.id, assunto NOT NULL,
         enunciado NOT NULL, dificuldade CHECK in (baixa, média, alta))
```

Relação 1:N — uma prova tem várias questões. Diagrama de arquitetura em
`docs/arquitetura.md`.

## 6. Desafios implementados

- **A — Filtro de Ecologia:** apenas `SELECT * FROM questoes WHERE assunto =
  'Ecologia'` (sem inserir). Resultado esperado: **2 linhas** (questões 1 e 3).
- **C — Integridade referencial:** INSERT com `prova_id = 999` deve violar a
  FK `questoes_prova_id_fkey`.
- **D — Restrição NOT NULL:** INSERT com `assunto = NULL` deve violar a
  constraint not-null (bônus: CHECK de dificuldade inválida, comentado).
- **E — Backup lógico (`pg_dump`):** `backups/README-backup.md`.

## 7. Persistência

O diretório `/var/lib/postgresql/data` é montado no volume nomeado
`radar-db-dados`. `docker compose down` (sem `-v`) remove o container mas
preserva o volume; `docker compose up -d` recria o container sobre o mesmo
volume e os dados permanecem. **Não** se usa `docker compose down -v` nem
`docker volume rm`.

**Comprovação real (2ª rodada):** antes do `down` havia provas=2/questoes=3;
após `docker compose down` o volume `radar-db-dados` continuou listado em
`docker volume ls`; após `docker compose up -d` o banco voltou com
provas=2/questoes=3 e os três registros oficiais intactos
(`v2-05-antes.log`, `v2-05-depois.log`, `v2-05-dados-finais.log`).

## 8. Backup

Backup lógico com `pg_dump` sem derrubar o serviço, gerando `.sql` (texto) ou
`.dump` (custom). Restauração validável em banco de teste. Dumps ficam fora do
Git (`.gitignore`).

## 9. Segurança

- Credenciais são de laboratório (`radar_lab_123`), uso didático e local.
- `.env` real fora do Git; apenas `.env.example` versionado.
- Lab isolado: não expõe nem toca dados reais do Radar ENEM.
- Porta exposta em 5433 para não conflitar com o Postgres nativo do host.
- Em produção: usar segredos gerenciados, senhas fortes, rede interna e TLS.

## 10. Respostas às oito perguntas do professor

> As perguntas exatas não acompanham este repositório. Abaixo, respostas às
> perguntas conceituais típicas desta atividade. **Ajustar ao enunciado
> oficial se o texto das 8 perguntas diferir.**

1. **Por que usar Docker para o banco?** Isola o ambiente, reproduz a mesma
   versão do PostgreSQL em qualquer máquina e descarta a instalação nativa.

2. **O que é e para que serve o Docker Volume?** Armazenamento gerenciado pelo
   Docker, independente do ciclo de vida do container; mantém os dados quando
   o container é removido/recriado.

3. **Por que os dados persistem após remover o container?** Porque ficam no
   volume `radar-db-dados`, não na camada de escrita do container. `down` sem
   `-v` preserva o volume.

4. **O que acontece se remover o volume?** Os dados são perdidos. Por isso não
   se usa `down -v` nem `docker volume rm` nesta atividade.

5. **Qual o papel da chave estrangeira (FK)?** Garante integridade referencial:
   impede uma questão apontar para uma prova inexistente (desafio C).

6. **Qual o papel das restrições NOT NULL / CHECK?** Garantem integridade de
   domínio: campos obrigatórios preenchidos (desafio D) e valores dentro de um
   conjunto permitido (dificuldade).

7. **Qual a diferença entre backup lógico e físico?** O lógico (`pg_dump`)
   exporta comandos/estrutura+dados, portável entre versões; o físico copia os
   arquivos do diretório de dados, mais rápido porém amarrado à versão/plataforma.

8. **Como esse modelo se relaciona com computação em nuvem?** O mesmo padrão
   (container + volume gerenciado) é a base de bancos em nuvem: serviços
   gerenciados separam compute (container/instância) de storage persistente
   (volume/disco), permitindo escalar, recriar e fazer backup sem perda de dados.

---

## Critérios de aceite da 2ª rodada — todos atendidos (real)

Validação executada com o Docker acessível e o container em execução:

- [x] Atualização controlada aplicada (sem recriar o volume)
- [x] 2 provas e 3 questões cadastradas
- [x] Desafio A: `SELECT ... WHERE assunto='Ecologia'` retornou **2 linhas**
- [x] 1 questão de Matemática
- [x] JOIN funcionando (3 linhas)
- [x] UPDATE funcionando (Matemática alta → 'média')
- [x] Desafio C: erro de FK (`prova_id = 999`)
- [x] Desafio D: erro de NOT NULL (`assunto = NULL`)
- [x] Desafio E: dump `backups/radar_backup_v2.sql` com 8276 bytes (não vazio)
- [x] Persistência: 2 provas / 3 questões **antes e depois** do down→up
- [x] Acentos legíveis nos logs (console em UTF-8)

Reproduzir a qualquer momento: `.\validar.ps1` (ou os comandos do `README.md`).
