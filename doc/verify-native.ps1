$ErrorActionPreference = 'Stop'
if (-not $env:PORTAL_NOCODB_TOKEN) { throw 'PORTAL_NOCODB_TOKEN is required' }
$headers = @{ 'xc-token' = $env:PORTAL_NOCODB_TOKEN }
$origin = 'http://localhost:8080'
$design = Get-Content -LiteralPath (Join-Path $PSScriptRoot '../docs/development/nocodb-schema.json') -Raw | ConvertFrom-Json
$base = Invoke-RestMethod "$origin/api/v1/db/meta/projects/pb3gir75kkooyea" -Headers $headers
$tables = @((Invoke-RestMethod "$origin/api/v2/meta/bases/pb3gir75kkooyea/tables" -Headers $headers).list)
$errors = [Collections.Generic.List[string]]::new()
$mapped = @()
if ($tables.Count -ne $design.tables.Count) { $errors.Add('Table count mismatch') }
foreach ($table in $design.tables) {
  $found = @($tables | Where-Object { $_.title -eq $table.name })
  if ($found.Count -ne 1) { $errors.Add("Missing/duplicate table: $($table.name)"); continue }
  $meta = Invoke-RestMethod "$origin/api/v2/meta/tables/$($found[0].id)" -Headers $headers
  if ($meta.base_id -ne 'pb3gir75kkooyea' -or $meta.source_id -ne 'bojz43pok1w9vqa') { $errors.Add("Wrong source: $($table.name)") }
  if (@($meta.columns | Where-Object {$_.uidt -in @('Links','LinkToAnotherRecord','Lookup','Rollup')}).Count) { $errors.Add("Linked column: $($table.name)") }
  foreach ($field in $table.fields) {
    $actual = @($meta.columns | Where-Object { $_.title -eq $field.name })
    if ($actual.Count -ne 1) { $errors.Add("Missing field: $($table.name).$($field.name)"); continue }
    $a = $actual[0]
    if ($field.required -and -not $a.rqd) { $errors.Add("Required: $($table.name).$($field.name)") }
    if ($field.name -eq 'id' -and -not $a.un) { $errors.Add("Unique business id: $($table.name)") }
    foreach ($key in $table.unique) { if ($key.Count -eq 1 -and $key[0] -eq $field.name -and -not $a.un) { $errors.Add("Unique: $($table.name).$($field.name)") } }
    $values = @()
    if ($field.enum) { $values = @($design.enums.($field.enum)) } elseif ($field.values) { $values = @($field.values) }
    if ($values.Count -and (Compare-Object $values @($a.colOptions.options.title))) { $errors.Add("Enum: $($table.name).$($field.name)") }
    if ($field.type -eq 'datetime' -and $a.dt -ne 'timestamptz') { $errors.Add("Timezone type: $($table.name).$($field.name)") }
    if ($field.type -eq 'integer' -and $a.dt -ne 'int8') { $errors.Add("Integer type: $($table.name).$($field.name)") }
    $actualDefault = [string]$a.cdf
    if ($actualDefault.StartsWith("'") -and $actualDefault.EndsWith("'")) { $actualDefault = $actualDefault.Substring(1, $actualDefault.Length - 2).Replace("''", "'") }
    if ($null -ne $field.default -and $actualDefault -ne [string]$field.default) { $errors.Add("Default: $($table.name).$($field.name)") }
  }
  $rows = Invoke-RestMethod "$origin/api/v2/tables/$($meta.id)/records?limit=1" -Headers $headers
  $mapped += [pscustomobject]@{name=$table.name; tableId=$meta.id; physicalName=$meta.table_name; sourceId=$meta.source_id; businessFields=$table.fields.Count; totalFields=$meta.columns.Count; records=$rows.pageInfo.totalRows; columns=@($meta.columns | Select-Object id,title,column_name,uidt,dt,rqd,un,pk,cdf,@{n='options';e={@($_.colOptions.options.title)}})}
}
[pscustomobject]@{checkedAt=(Get-Date).ToString('o'); baseId=$base.id; baseTitle=$base.title; source=@($base.sources | Select-Object id,type,is_local,is_schema_readonly,is_data_readonly); tableCount=$tables.Count; businessFields=($design.tables.fields | Measure-Object).Count; errors=@($errors); tables=$mapped} | ConvertTo-Json -Depth 10 -Compress
