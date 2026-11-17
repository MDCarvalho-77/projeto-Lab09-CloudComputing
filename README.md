# Atividade Prática — Aula 9 (Computação em Nuvem)

Laboratório **independente** de PostgreSQL com Docker. Demonstra banco
relacional, consultas SQL e persistência de dados via Docker Volume.

## Contexto acadêmico

Trabalho **acadêmico** da disciplina de Computação em Nuvem (Aula 9), do curso
de Bacharelado em Ciência de Dados e Inteligência Artificial — Centro
Universitário SENAI/SC (Florianópolis).

Este laboratório é **baseado no Projeto Aplicado da equipe — Radar ENEM** (uma
plataforma de diagnóstico estatístico de notas do ENEM). O lab reaproveita o
domínio do projeto (provas e questões) apenas como pano de fundo didático: é
um exercício **autônomo**, com **dados fictícios**, que **não** integra nem
modifica o backend/frontend originais do Radar ENEM.

> Esta atividade é isolada: **não** toca em `Backend/`, `frontend/` nem em
> qualquer arquivo original do Radar ENEM, e **não** integra o banco ao
> backend. Usa somente dados fictícios.

## Especificação do ambiente

| Item | Valor |
|---|---|
| Imagem | `postgres:16` |
| Container | `radar-db` |
| Banco | `radar` |
| Usuário | `radar` |
| Senha | `radar_lab_123` |
| Porta (container) | `5432` |
| Porta (host) | **`5433`** — ver nota de conflito abaixo |
| Volume | `radar-db-dados` (nome exato, sem prefixo) |
| Diretório de dados | `/var/lib/postgresql/data` |

### ⚠️ Nota sobre a porta 5432

No diagnóstico, a porta **5432 do host já estava ocupada** por um PostgreSQL
nativo do Windows. Para não alterar serviços fora do escopo do lab, o host é
mapeado em **5433** (`5433:5432`). Dentro do container o PostgreSQL continua
em 5432, como pede o roteiro. Para usar o `5432:5432` literal, pare o Postgres
nativo e ajuste a porta no `docker-compose.yml`.

## Estrutura

```
lab-aula9-postgres/
├── docker-compose.yml       # serviço radar-db + volume radar-db-dados
├── .env.example             # credenciais do lab
├── .gitignore
├── init/
│   └── 01-schema.sql        # DDL + seed oficial (roda na 1ª criação do volume)
├── queries/
│   ├── consultas.sql        # SELECT, JOIN, filtro (Ecologia), UPDATE
│   ├── desafios.sql         # desafios A (só SELECT), C, D
│   └── 02-atualizar-dados.sql  # atualização controlada do banco já existente
├── backups/
│   └── README-backup.md     # desafio E (pg_dump)
├── docs/
│   └── arquitetura.md       # diagrama Aplicação -> PostgreSQL -> Volume
├── evidencias/
│   └── README.md            # checklist de evidências a coletar
├── validar.ps1              # script de validação ponta a ponta (rodar manual)
├── README.md                # este arquivo
└── RELATORIO.md             # relatório da atividade
```

## Dados oficiais (exemplos do professor)

| Prova (id) | ano | nome |
|---|---|---|
| 1 | 2025 | ENEM regular |
| 2 | 2024 | ENEM regular |

| Questão (id) | prova_id | assunto | dificuldade |
|---|---|---|---|
| 1 | 1 | Ecologia | média |
| 2 | 1 | Matemática | alta |
| 3 | 2 | Ecologia | baixa |

Duas questões de Ecologia (uma em cada prova) e uma de Matemática.

## Passo a passo (todos os comandos)

> Rode a partir desta pasta (`lab-aula9-postgres/`), em PowerShell, com o
> **Docker Desktop ligado**.

### 1. Subir o PostgreSQL (cria volume + roda o schema)

```powershell
docker compose up -d
docker ps                 # confirmar radar-db no ar
docker volume ls          # confirmar volume radar-db-dados
```

O `init/01-schema.sql` cria as tabelas e insere os dados fictícios
automaticamente na primeira subida (volume vazio).

### 2. Conferir estrutura e dados

```powershell
# abrir psql interativo
docker exec -it radar-db psql -U radar -d radar

# dentro do psql:
\dt                       -- lista tabelas
\d questoes               -- mostra PK e FK (prova_id -> provas.id)
SELECT * FROM provas;
SELECT * FROM questoes;
\q
```

### 3. Consultas (SELECT, JOIN, filtro, UPDATE)

```powershell
docker cp queries\consultas.sql radar-db:/tmp/consultas.sql
docker exec -it radar-db psql -U radar -d radar -f /tmp/consultas.sql
```

### 4. Desafios A, C, D

```powershell
docker cp queries\desafios.sql radar-db:/tmp/desafios.sql
docker exec -it radar-db psql -U radar -d radar -f /tmp/desafios.sql
```

- **A** — apenas `SELECT * FROM questoes WHERE assunto = 'Ecologia'` (sem
  inserir). Deve retornar **2 linhas**.
- **C** — insere com `prova_id = 999`: deve falhar com erro de **FK**.
- **D** — insere com `assunto = NULL`: deve falhar com erro de **NOT NULL**.

### 5. Persistência (prova do volume)

```powershell
# a) registrar um dado antes
docker exec -it radar-db psql -U radar -d radar -c "SELECT count(*) FROM questoes;"

# b) remover o container SEM remover o volume (sem -v!)
docker compose down

# c) recriar o container usando o MESMO volume
docker compose up -d

# d) consultar de novo: os dados continuam lá
docker exec -it radar-db psql -U radar -d radar -c "SELECT count(*) FROM questoes;"
```

> Nunca use `docker compose down -v` nem `docker volume rm radar-db-dados`:
> isso apagaria o volume e destruiria a prova de persistência.

### 6. Backup lógico (desafio E)

Ver [`backups/README-backup.md`](backups/README-backup.md).

```powershell
docker exec -t radar-db pg_dump -U radar -d radar > backups\radar_backup.sql
```

## Atualizar um banco JÁ EXISTENTE (sem recriar o volume)

O `init/01-schema.sql` só roda na **primeira** criação do volume. Se o volume
`radar-db-dados` já tem dados de uma execução anterior, use a atualização
controlada — ela esvazia as tabelas, reinicia as sequências de id e reinsere
os dados oficiais, **sem** `DROP`, **sem** recriar o volume:

```powershell
docker cp queries\02-atualizar-dados.sql radar-db:/tmp/02-atualizar-dados.sql
docker exec -i radar-db psql -U radar -d radar -f /tmp/02-atualizar-dados.sql
```

## Codificação (acentos nos logs)

Os arquivos `.sql` estão em **UTF-8 sem BOM** (ideal para o psql). Se os
acentos aparecerem trocados no PowerShell, force o console para UTF-8 antes de
rodar os comandos (o `validar.ps1` já faz isso):

```powershell
chcp 65001 > $null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$env:PGCLIENTENCODING = "UTF8"
```

## Validação

**Status: 2ª rodada executada e aprovada** (Docker acessível, container em
execução). Resultados reais: 2 provas, 3 questões (2 de Ecologia, 1 de
Matemática), JOIN e UPDATE OK, desafios C e D rejeitaram os dados inválidos,
backup `radar_backup_v2.sql` gerado (não vazio) e persistência comprovada
(2/3 antes e depois do `down`→`up`). Evidências com prefixo `v2-` em
`evidencias/`; detalhamento em [`RELATORIO.md`](RELATORIO.md).

Para reproduzir: rode `validar.ps1` num terminal PowerShell normal (Docker
ligado) ou siga os comandos acima. Não inventar resultados.
