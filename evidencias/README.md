# Evidências — Lab Aula 9

Pasta destinada aos prints e logs que comprovam cada etapa da atividade.
Capture as evidências **executando os comandos reais** (não inventar saídas).

A forma mais simples é rodar `..\validar.ps1`, que salva os logs abaixo
(prefixo `v2-` = 2ª rodada, dados oficiais). Não misturar com a 1ª execução.

| # | Evidência | Arquivo gerado pelo validar.ps1 | Resultado esperado |
|---|-----------|--------------------------------|--------------------|
| 1 | Engine / container no ar | `v2-01-engine.log`, `v2-02-ps.log` | `radar-db` rodando |
| 2 | Logs do PostgreSQL | `v2-02-logs.log` | banco pronto para conexões |
| 3 | Atualização controlada | `v2-03-atualizacao.log` | 2 provas / 3 questões |
| 4 | Tabelas | `v2-03-tabelas.log` | `provas`, `questoes` |
| 5 | PK/FK | `v2-03-estrutura.log` | PK em id; FK prova_id→provas |
| 6 | SELECT / JOIN / filtro / UPDATE | `v2-03-consultas.log` | JOIN 3 linhas; filtro 2 Ecologia; UPDATE Matemática |
| 7 | Desafios A, C, D | `v2-04-desafios.log` | A=2 linhas; C=erro FK; D=erro NOT NULL |
| 8 | Backup (pg_dump) | `backups\radar_backup_v2.sql` + `v2-04-backup-size.log` | arquivo não vazio |
| 9 | Persistência antes | `v2-05-antes.log` | provas=2 / questoes=3 |
| 10 | Persistência depois | `v2-05-depois.log` | provas=2 / questoes=3 (iguais) |

Os arquivos de log/dump ficam fora do Git (ver `../.gitignore`); mantenha aqui
apenas os prints/anexos que irão para o relatório. **Não inventar saídas.**

> Nota: `00-bloqueio-sandbox.md` documenta por que o agente não pôde executar
> estes comandos automaticamente (sem acesso ao Docker daemon).
