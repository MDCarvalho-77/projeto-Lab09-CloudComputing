# Bloqueio de execução — acesso ao Docker daemon pelo ambiente

Data da tentativa de validação end-to-end: registrada nesta sessão.

## Resumo

A validação end-to-end **não pôde ser executada** porque o ambiente em que
rodo os comandos (sandbox) **não consegue contatar o Docker daemon**, embora
o Docker Desktop esteja iniciado na máquina do usuário.

Isso NÃO é falha do lab nem do docker-compose.yml. É uma limitação de acesso
do executor de comandos ao named pipe do Docker Engine
(`\\.\pipe\docker_engine`) no Windows.

## Evidência — comportamento observado (real)

| Comando | Toca o daemon? | Resultado |
|---|---|---|
| `docker compose config --quiet` | Não (parse local do YAML) | **OK** (exit 0) |
| `docker compose config --volumes` | Não | **OK** — retornou `radar-db-dados` |
| `docker ps` | Sim | **FALHA** |
| `docker info` | Sim | **FALHA** |
| `docker version` | Sim | **FALHA** |

Mensagem de erro recorrente nos comandos que contatam o daemon:

```
Falha na execução do programa 'docker.exe': O nome do diretório é inválido
```

E, via executor de processo em background:

```
[ERROR kiro_sandbox] spawn failed: O sistema não pôde encontrar a opção
de ambiente digitada. (0x800700CB)
```

## Conclusão

- Tudo que é **estático/local** foi validado: o `docker-compose.yml` é
  sintaticamente válido e o volume resolve para o nome exato `radar-db-dados`
  (sem prefixo do projeto).
- Tudo que exige o **daemon** (subir container, consultas, desafios,
  persistência, `pg_dump`) ficou **bloqueado pelo ambiente**, não pôde ser
  executado por mim e, portanto, **não há evidências de execução reais** —
  nenhuma saída foi inventada.

## O que o usuário precisa fazer manualmente

Rodar os comandos do `README.md` (seções 1–6) num terminal PowerShell normal
da máquina (fora do sandbox), com o Docker Desktop ligado, e salvar os prints
nesta pasta. O roteiro já está pronto e testado na parte estática.
