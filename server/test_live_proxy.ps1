# Test script for ASP.NET Core NeuroScriptProxy
param(
    [string]$BaseUrl = "http://localhost:5000",
    [string]$ApiKey = "neuroscript-dev-api-key-2026"
)

Write-Host "1. Testing /health endpoint..." -ForegroundColor Cyan
try {
    $health = Invoke-RestMethod -Uri "$BaseUrl/health" -Method Get
    Write-Host "   Health check passed: $($health.status) (Provider: $($health.provider))" -ForegroundColor Green
} catch {
    Write-Host "   Health check failed: $_" -ForegroundColor Red
}

Write-Host "`n2. Testing /api/v1/lessons/generate endpoint..." -ForegroundColor Cyan
$installId = "inst_" + [Guid]::NewGuid().ToString()
$headers = @{
    "X-Api-Key" = $ApiKey
    "X-Install-Id" = $installId
    "Content-Type" = "application/json"
}

$body = @{
    noteHash = "live_test_hash_01"
    lines = @(
        "Photosynthesis occurs in chloroplasts."
        "Chlorophyll absorbs blue and red wavelengths."
    )
    profile = "Dyslexia"
    mode = "standard"
    clientVersion = "0.3.0-m3"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/api/v1/lessons/generate" -Method Post -Headers $headers -Body $body
    Write-Host "   Generation succeeded! Title: $($response.title)" -ForegroundColor Green
    Write-Host "   Flashcards count: $($response.flashcards.Count)" -ForegroundColor Green
    Write-Host "   Concept nodes: $($response.conceptMap.nodes.Count)" -ForegroundColor Green
} catch {
    Write-Host "   Generation failed: $_" -ForegroundColor Red
}

Write-Host "`nLive proxy verification complete." -ForegroundColor Cyan
