# Desafio E — Backup lógico com `pg_dump`

Backup lógico do banco `radar` do container `radar-db`, sem parar o serviço.

> Pré-requisito: o container `radar-db` precisa estar **em execução** e o
> Docker engine ligado.

## Gerar o backup (dump lógico)

A partir desta pasta (`lab-aula9-postgres/`), em PowerShell:

```powershell
# Dump em formato texto (SQL puro) para a pasta backups/
# (2ª rodada / dados oficiais: use o nome radar_backup_v2.sql)
docker exec -t radar-db pg_dump -U radar -d radar > backups\radar_backup_v2.sql
```

Alternativa em formato custom (comprimido, restaurável com pg_restore):

```powershell
docker exec -t radar-db pg_dump -U radar -d radar -F c -f /tmp/radar_backup.dump
docker cp radar-db:/tmp/radar_backup.dump backups\radar_backup.dump
```

## Conferir o conteúdo do dump

```powershell
Get-Content backups\radar_backup.sql | Select-String "CREATE TABLE","INSERT INTO" | Select-Object -First 20
```

## Restaurar (teste de validação)

Restauração do dump em texto para um banco limpo (exemplo didático):

```powershell
# cria um banco de teste e restaura nele
docker exec -it radar-db createdb -U radar radar_restore_test
Get-Content backups\radar_backup.sql | docker exec -i radar-db psql -U radar -d radar_restore_test
# conferir:
docker exec -it radar-db psql -U radar -d radar_restore_test -c "SELECT count(*) FROM questoes;"
```

> O arquivo `.sql`/`.dump` gerado é ignorado pelo Git (ver `.gitignore`).
> Guarde o print da geração e da restauração na pasta `../evidencias/`.
