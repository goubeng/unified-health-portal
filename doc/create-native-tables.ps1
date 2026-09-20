param([int]$Limit = 1)
$ErrorActionPreference = 'Stop'
if (-not $env:PORTAL_NOCODB_TOKEN) { throw 'PORTAL_NOCODB_TOKEN is required' }
$headers = @{ 'xc-token' = $env:PORTAL_NOCODB_TOKEN }
$origin = 'http://localhost:8080'
$baseId = 'pb3gir75kkooyea'
$sourceId = 'bojz43pok1w9vqa'
$design = Get-Content -LiteralPath (Join-Path $PSScriptRoot '../docs/development/nocodb-schema.json') -Raw | ConvertFrom-Json
if ($design.baseId -ne $baseId -or $design.externalDataSource) { throw 'Unexpected design target' }
$base = Invoke-RestMethod "$origin/api/v1/db/meta/projects/$baseId" -Headers $headers
$source = @($base.sources | Where-Object { $_.id -eq $sourceId })
if ($base.id -ne $baseId -or $source.Count -ne 1 -or -not $source[0].is_local -or $source[0].type -ne 'pg' -or $source[0].is_schema_readonly) { throw 'Unexpected base/source or read-only schema' }
$existing = @( (Invoke-RestMethod "$origin/api/v2/meta/bases/$baseId/tables" -Headers $headers).list )
$count = 0
foreach ($table in $design.tables) {
  $match = @($existing | Where-Object { $_.title -eq $table.name })
  if ($match.Count) {
    if ($match.Count -ne 1 -or $match[0].source_id -ne $sourceId) { throw "Ambiguous existing table: $($table.name)" }
    $meta = Invoke-RestMethod "$origin/api/v2/meta/tables/$($match[0].id)" -Headers $headers
    $missing = @($table.fields | Where-Object { $_.name -notin $meta.columns.title })
    if ($missing.Count) { throw "Existing table missing fields: $($table.name)" }
    [pscustomobject]@{ action='verified-existing'; name=$table.name; id=$meta.id; fields=$meta.columns.Count } | ConvertTo-Json -Compress
    continue
  }
  if ($count -ge $Limit) { break }
  $columns = @(@{title='nc_id'; column_name='nc_id'; uidt='ID'; dt='int4'; pk=$true; ai=$true; rqd=$true})
  foreach ($field in $table.fields) {
    $type = switch ($field.type) { 'datetime' {'DateTime'} 'integer' {'Number'} 'json' {'LongText'} default {'SingleLineText'} }
    $values = @()
    if ($field.enum) { $values = @($design.enums.($field.enum)) }
    elseif ($field.values) { $values = @($field.values) }
    if ($values.Count) { $type = 'SingleSelect' }
    if ($table.name -eq 'announcement_attachment' -and $field.name -eq 'attachment') { $type = 'Attachment' }
    $column = @{ title=$field.name; column_name=$field.name; uidt=$type; rqd=[bool]$field.required; pk=$false }
    if ($field.name -eq 'id') { $column.un = $true; $column.pv = $true }
    foreach ($uniqueKey in $table.unique) { if ($uniqueKey.Count -eq 1 -and $uniqueKey[0] -eq $field.name) { $column.un = $true } }
    if ($field.type -eq 'integer') { $column.dt = 'int8' }
    if ($field.type -eq 'datetime') { $column.dt = 'timestamptz' }
    if ($values.Count) { $column.dtxp = $values -join ',' }
    if ($null -ne $field.default) { $column.cdf = $field.default }
    $columns += $column
  }
  $body = @{ title=$table.name; table_name=$table.name; columns=$columns } | ConvertTo-Json -Depth 15
  $created = Invoke-RestMethod "$origin/api/v2/meta/bases/$baseId/$sourceId/tables" -Method Post -Headers $headers -ContentType 'application/json; charset=utf-8' -Body ([Text.Encoding]::UTF8.GetBytes($body))
  $meta = Invoke-RestMethod "$origin/api/v2/meta/tables/$($created.id)" -Headers $headers
  if ($meta.base_id -ne $baseId -or $meta.source_id -ne $sourceId) { throw 'Created target mismatch' }
  $missing = @($table.fields | Where-Object { $_.name -notin $meta.columns.title })
  if ($missing.Count) { throw "Readback missing fields: $($table.name)" }
  foreach ($field in $table.fields) {
    $actual = $meta.columns | Where-Object { $_.title -eq $field.name }
    if ($field.required -and -not $actual.rqd) { throw "Required mismatch: $($table.name).$($field.name)" }
    $expectedValues = @()
    if ($field.enum) { $expectedValues = @($design.enums.($field.enum)) }
    elseif ($field.values) { $expectedValues = @($field.values) }
    if ($expectedValues.Count -and (Compare-Object $expectedValues @($actual.colOptions.options.title))) { throw "Enum mismatch: $($table.name).$($field.name)" }
    if ($field.type -eq 'datetime' -and $actual.dt -ne 'timestamptz') { throw "Datetime mismatch: $($table.name).$($field.name)" }
  }
  if (@($meta.columns | Where-Object { $_.uidt -eq 'Links' -or $_.uidt -eq 'LinkToAnotherRecord' -or $_.uidt -eq 'Lookup' }).Count) { throw 'Unexpected linked column' }
  [pscustomobject]@{action='created-readback'; name=$table.name; id=$meta.id; physicalName=$meta.table_name; sourceId=$meta.source_id; fields=$meta.columns.Count} | ConvertTo-Json -Compress
  $count++
}
