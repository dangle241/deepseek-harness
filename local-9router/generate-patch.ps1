[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$apiKey = $env:DEEPSEEK_API_KEY
if ([string]::IsNullOrWhiteSpace($apiKey)) {
  throw 'DEEPSEEK_API_KEY is not set.'
}

$baseUrl = $env:DEEPSEEK_BASE_URL
if ([string]::IsNullOrWhiteSpace($baseUrl)) {
  $baseUrl = 'http://localhost:20128/v1'
}
$baseUrl = $baseUrl.TrimEnd('/')
$modelsUrl = "$baseUrl/models"

$response = Invoke-RestMethod `
  -Uri $modelsUrl `
  -Method Get `
  -Headers @{ Authorization = "Bearer $apiKey" } `
  -TimeoutSec 30

if ($null -eq $response.data) {
  throw "9Router returned no data array from $modelsUrl."
}

$models = @($response.data)
if ($models.Count -eq 0) {
  throw "9Router returned an empty model catalog from $modelsUrl."
}

$ids = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
$modelRows = foreach ($model in $models) {
  $id = [string]$model.id
  if ([string]::IsNullOrWhiteSpace($id)) {
    throw '9Router returned a model without an id.'
  }
  if (-not $ids.Add($id)) {
    throw "9Router returned duplicate model id: $id"
  }

  $name = [string]$model.name
  if ([string]::IsNullOrWhiteSpace($name)) {
    $name = $id
  }

  $quotedId = ConvertTo-Json $id -Compress
  $quotedName = ConvertTo-Json $name -Compress
  "          - id: $quotedId`n            name: $quotedName"
}

$quotedBaseUrl = ConvertTo-Json $baseUrl -Compress
$patch = @"
# Generated from the live 9Router /v1/models response. Do not commit.
- id: llm-pi-ai
  config:
    providers:
      local-9router:
        displayName: Local 9Router
        apiKeyEnv: DEEPSEEK_API_KEY
        api: openai-completions
        baseURL: $quotedBaseUrl
        models:
$($modelRows -join "`n")
"@

$outputPath = Join-Path $PSScriptRoot 'generated.patch.yml'
Set-Content -LiteralPath $outputPath -Value $patch -Encoding utf8
Write-Host "Loaded $($models.Count) models from 9Router."
