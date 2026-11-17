# =============================================================================
# validar.ps1 - Validação do Lab Aula 9 com os DADOS CORRIGIDOS (2ª rodada).
#
# Rode num terminal PowerShell NORMAL da máquina (fora de qualquer sandbox),
# a partir da pasta lab-aula9-postgres/, com o Docker Desktop LIGADO:
#
#   cd lab-aula9-postgres
#   .\validar.ps1
#
# Faz atualização CONTROLADA do banco já existente (não recria o volume).
# NÃO executa nada destrutivo: nunca usa 'down -v' nem 'volume rm', e não
# toca em serviços externos ao laboratório.
# =============================================================================

# --- Codificação: garante acentos corretos nos logs do PowerShell -----------
chcp 65001 > $null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$env:PGCLIENTENCODING = "UTF8"

$ErrorActionPreference = "Continue"
$ev = "evidencias"
New-Item -ItemType Directory -Force -Path $ev, "backups" | Out-Null

function Passo($t) { Write-Host "`n===== $t =====" -ForegroundColor Cyan }

# ETAPA 1 - VERIFICAÇÃO -------------------------------------------------------
Passo "ETAPA 1 - Verificacao"
docker info --format "Engine: {{.ServerVersion}}" | Tee-Object "$ev\v2-01-engine.log"
docker compose config --quiet; if ($LASTEXITCODE -eq 0) { "compose OK" }

# ETAPA 2 - INICIALIZAÇÃO -----------------------------------------------------
Passo "ETAPA 2 - Inicializacao (container existente ou novo; volume preservado)"
docker compose up -d                        | Tee-Object "$ev\v2-02-up.log"
Start-Sleep -Seconds 6
docker compose ps                           | Tee-Object "$ev\v2-02-ps.log"
docker compose logs --tail=30 radar-db      | Tee-Object "$ev\v2-02-logs.log"

# ETAPA 3 - ATUALIZAÇÃO CONTROLADA DOS DADOS ---------------------------------
Passo "ETAPA 3 - Atualizacao controlada dos dados oficiais"
docker cp queries\02-atualizar-dados.sql radar-db:/tmp/02-atualizar-dados.sql
docker exec -i radar-db psql -U radar -d radar -f /tmp/02-atualizar-dados.sql | Tee-Object "$ev\v2-03-atualizacao.log"

# Conferências da etapa 4 do roteiro
docker exec -i radar-db psql -U radar -d radar -c "\dt"          | Tee-Object "$ev\v2-03-tabelas.log"
docker exec -i radar-db psql -U radar -d radar -c "\d questoes"  | Tee-Object "$ev\v2-03-estrutura.log"
docker cp queries\consultas.sql radar-db:/tmp/consultas.sql
docker exec -i radar-db psql -U radar -d radar -f /tmp/consultas.sql | Tee-Object "$ev\v2-03-consultas.log"

# ETAPA 4 - DESAFIOS ----------------------------------------------------------
Passo "ETAPA 4 - Desafios (A=2 Ecologia; C e D devem FALHAR; E=backup)"
docker cp queries\desafios.sql radar-db:/tmp/desafios.sql
docker exec -i radar-db psql -U radar -d radar -f /tmp/desafios.sql 2>&1 | Tee-Object "$ev\v2-04-desafios.log"
# Desafio E - backup logico
docker exec -t radar-db pg_dump -U radar -d radar > backups\radar_backup_v2.sql
$size = (Get-Item backups\radar_backup_v2.sql).Length
"Tamanho do dump (bytes): $size" | Tee-Object "$ev\v2-04-backup-size.log"
if ($size -gt 0) { "Backup OK (nao vazio)" } else { "ATENCAO: backup vazio!" }

# ETAPA 5 - PERSISTÊNCIA ------------------------------------------------------
Passo "ETAPA 5 - Persistencia (esperado: 2 provas e 3 questoes antes e depois)"
"ANTES:"  | Tee-Object "$ev\v2-05-antes.log"
docker exec -i radar-db psql -U radar -d radar -t -A -c "SELECT 'provas='||count(*) FROM provas UNION ALL SELECT 'questoes='||count(*) FROM questoes;" | Tee-Object -Append "$ev\v2-05-antes.log"
docker compose down                         # remove SO o container (sem -v)
docker compose up -d
Start-Sleep -Seconds 6
"DEPOIS:" | Tee-Object "$ev\v2-05-depois.log"
docker exec -i radar-db psql -U radar -d radar -t -A -c "SELECT 'provas='||count(*) FROM provas UNION ALL SELECT 'questoes='||count(*) FROM questoes;" | Tee-Object -Append "$ev\v2-05-depois.log"

Write-Host "`nValidacao concluida. Evidencias (prefixo v2-) em $ev\ e backups\radar_backup_v2.sql." -ForegroundColor Green
Write-Host "Compare ETAPA 5 antes x depois: ambos devem ser provas=2 / questoes=3." -ForegroundColor Green
