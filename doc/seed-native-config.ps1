$ErrorActionPreference = 'Stop'
if (-not $env:PORTAL_NOCODB_TOKEN) { throw 'PORTAL_NOCODB_TOKEN is required' }
$headers = @{ 'xc-token' = $env:PORTAL_NOCODB_TOKEN }
$origin = 'http://localhost:8080'
$seed = Get-Content -LiteralPath (Join-Path $PSScriptRoot '../docs/development/nocodb-seed.json') -Raw | ConvertFrom-Json
if ($seed.baseId -ne 'pb3gir75kkooyea') { throw 'Unexpected seed base' }
$tables = (Invoke-RestMethod "$origin/api/v2/meta/bases/pb3gir75kkooyea/tables" -Headers $headers).list
$table = @($tables | Where-Object { $_.title -eq 'system_config' -and $_.source_id -eq 'bojz43pok1w9vqa' })
if ($table.Count -ne 1) { throw 'Expected one native system_config table' }
$uri = "$origin/api/v2/tables/$($table[0].id)/records"
$created = 0
foreach ($record in $seed.records.system_config) {
  $filter = [uri]::EscapeDataString('(code,eq,' + $record.code + ')')
  $found = @( (Invoke-RestMethod "$($uri)?where=$filter&limit=2" -Headers $headers).list )
  if ($found.Count -gt 1) { throw 'Duplicate configuration code' }
  if ($found.Count) { continue }
  $body = $record | ConvertTo-Json -Depth 6
  $null = Invoke-RestMethod $uri -Method Post -Headers $headers -ContentType 'application/json; charset=utf-8' -Body ([Text.Encoding]::UTF8.GetBytes($body))
  $readback = @( (Invoke-RestMethod "$($uri)?where=$filter&limit=2" -Headers $headers).list )
  if ($readback.Count -ne 1 -or $readback[0].id -ne $record.id -or $readback[0].status -ne 'UNCONFIGURED' -or $null -ne $readback[0].value) { throw 'Configuration readback mismatch' }
  $created++
}
$result = Invoke-RestMethod "$($uri)?limit=100" -Headers $headers
[pscustomobject]@{tableId=$table[0].id; created=$created; total=$result.pageInfo.totalRows; rows=@($result.list | Select-Object code,status,value)} | ConvertTo-Json -Depth 4
