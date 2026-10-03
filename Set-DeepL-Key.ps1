param([string]$GamePath)
$ErrorActionPreference = 'Stop'
try {
    if (-not $GamePath -and (Test-Path (Join-Path $PSScriptRoot '.game-path'))) {
        $GamePath = [IO.File]::ReadAllText((Join-Path $PSScriptRoot '.game-path')).Trim()
    }
    if (-not $GamePath) { $GamePath = (Read-Host 'People Playground game folder').Trim('"') }
    if (Get-Process -Name 'People Playground' -ErrorAction SilentlyContinue) { throw 'Close People Playground before updating the key.' }
    $configPath = Join-Path $GamePath 'BepInEx\config\AutoTranslatorConfig.ini'
    if (-not (Test-Path $configPath)) { throw 'Run Install.cmd first.' }
    Write-Host 'Paste your DeepL API key. Input is hidden.'
    $secureKey = Read-Host 'API key' -AsSecureString
    $pointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureKey)
    try { $apiKey = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($pointer).Trim() }
    finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($pointer) }
    if ([string]::IsNullOrWhiteSpace($apiKey) -or $apiKey -match '[\r\n]') { throw 'The API key is empty or invalid.' }
    $isFree = $apiKey.EndsWith(':fx')
    $baseUrl = if ($isFree) { 'https://api-free.deepl.com' } else { 'https://api.deepl.com' }
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    try {
        $null = Invoke-RestMethod -Uri "$baseUrl/v2/usage" -Headers @{ Authorization = "DeepL-Auth-Key $apiKey" } -TimeoutSec 20
    } catch { throw 'DeepL authentication failed. Check the API key and internet connection. No settings were changed.' }
    $config = [IO.File]::ReadAllText($configPath)
    $pattern = '(?ms)^\[DeepLLegitimate\]\r?\n.*?(?=^\[|\z)'
    if (-not [regex]::IsMatch($config, $pattern)) { throw 'DeepLLegitimate configuration section is missing.' }
    $replacement = "[DeepLLegitimate]`r`nApiKey=$apiKey`r`nFree=$isFree`r`n`r`n"
    $config = [regex]::Replace($config, $pattern, [Text.RegularExpressions.MatchEvaluator]{ param($match) $replacement })
    $config = [regex]::Replace($config, '(?m)^Endpoint=.*$', 'Endpoint=DeepLTranslateLegitimate')
    [IO.File]::WriteAllText($configPath, $config, (New-Object Text.UTF8Encoding($false)))
    $apiKey = $null
    Write-Host 'Key verified and saved in the game folder. English -> Korean is configured.' -ForegroundColor Green
    Write-Host 'Launch People Playground through Steam.'
} catch { Write-Host $_.Exception.Message -ForegroundColor Red }
$null = Read-Host 'Press Enter to close'
