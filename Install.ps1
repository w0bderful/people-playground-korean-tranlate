param([string]$GamePath)
$ErrorActionPreference = 'Stop'
try {
    if (-not $GamePath) {
        $steamPath = (Get-ItemProperty 'HKCU:\Software\Valve\Steam' -ErrorAction SilentlyContinue).SteamPath
        $libraries = @($steamPath)
        if ($steamPath -and (Test-Path "$steamPath\steamapps\libraryfolders.vdf")) {
            $vdf = [IO.File]::ReadAllText("$steamPath\steamapps\libraryfolders.vdf")
            $libraries += [regex]::Matches($vdf, '"path"\s+"([^"]+)"') | ForEach-Object { $_.Groups[1].Value.Replace('\\', '\') }
        }
        foreach ($library in $libraries | Where-Object { $_ } | Select-Object -Unique) {
            $candidate = Join-Path $library 'steamapps\common\People Playground'
            if (Test-Path "$candidate\People Playground.exe") { $GamePath = $candidate; break }
        }
    }
    if (-not $GamePath) { $GamePath = (Read-Host 'People Playground game folder').Trim('"') }
    $GamePath = [IO.Path]::GetFullPath($GamePath)
    if (-not (Test-Path "$GamePath\People Playground.exe")) { throw 'People Playground.exe was not found.' }
    if (-not (Test-Path "$GamePath\People Playground_Data\Managed\Assembly-CSharp.dll")) { throw 'This installer requires the Windows Mono version of the game.' }
    if (Get-Process -Name 'People Playground' -ErrorAction SilentlyContinue) { throw 'Close People Playground before installing.' }
    $configPath = Join-Path $GamePath 'BepInEx\config\AutoTranslatorConfig.ini'
    $oldKey = ''
    $oldFree = 'True'
    if (Test-Path $configPath) {
        $oldConfig = [IO.File]::ReadAllText($configPath)
        $section = [regex]::Match($oldConfig, '(?ms)^\[DeepLLegitimate\]\r?\n.*?(?=^\[|\z)').Value
        $oldKey = [regex]::Match($section, '(?m)^ApiKey=(.*)').Groups[1].Value.Trim()
        $freeMatch = [regex]::Match($section, '(?m)^Free=(.*)')
        if ($freeMatch.Success) { $oldFree = $freeMatch.Groups[1].Value.Trim() }
    }
    $tempPath = Join-Path ([IO.Path]::GetTempPath()) ('PPG-Korean-' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory $tempPath | Out-Null
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $downloads = @(
        @{ Name='BepInEx'; Url='https://github.com/BepInEx/BepInEx/releases/download/v5.4.23.5/BepInEx_win_x64_5.4.23.5.zip'; Hash='82F9878551030F54657792C0740D9D51A09500EEAE1FBA21106B0C441E6732C4' },
        @{ Name='AutoTranslator'; Url='https://github.com/bbepis/XUnity.AutoTranslator/releases/download/v5.6.2/XUnity.AutoTranslator-BepInEx-5.6.2.zip'; Hash='836A4066B9369B0D23DC1B0EF6336AD7FE7AE16880931259EC4D157AFF7A81C0' },
        @{ Name='Fonts'; Url='https://github.com/bbepis/XUnity.AutoTranslator/releases/download/v5.4.4/TMP_Font_AssetBundles.zip'; Hash='CD18628EA3BD1128FA172B910AE15685F89FF689B20C4836D42D42491C26DD39' }
    )
    foreach ($download in $downloads) {
        Write-Host ('Downloading ' + $download.Name)
        $zip = Join-Path $tempPath ($download.Name + '.zip')
        Invoke-WebRequest $download.Url -UseBasicParsing -OutFile $zip
        if ((Get-FileHash $zip -Algorithm SHA256).Hash -ne $download.Hash) { throw ('Checksum mismatch: ' + $download.Name) }
        Expand-Archive $zip (Join-Path $tempPath $download.Name)
    }
    $backupPath = Join-Path $GamePath ('BepInEx\KoreanTranslationBackups\' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '-' + [guid]::NewGuid().ToString('N').Substring(0,8))
    function Copy-WithBackup([string]$SourceRoot) {
        foreach ($file in Get-ChildItem $SourceRoot -File -Recurse -Force) {
            $relative = $file.FullName.Substring($SourceRoot.Length).TrimStart('\')
            $target = Join-Path $GamePath $relative
            if (Test-Path $target) {
                $backup = Join-Path $backupPath $relative
                if (-not (Test-Path $backup)) {
                    New-Item -ItemType Directory (Split-Path $backup) -Force | Out-Null
                    Copy-Item -LiteralPath $target -Destination $backup
                }
            }
            New-Item -ItemType Directory (Split-Path $target) -Force | Out-Null
            Copy-Item -LiteralPath $file.FullName -Destination $target -Force
        }
    }
    Copy-WithBackup (Join-Path $tempPath 'BepInEx')
    Copy-WithBackup (Join-Path $tempPath 'AutoTranslator')
    $fontStage = Join-Path $tempPath 'FontStage'
    New-Item -ItemType Directory $fontStage | Out-Null
    Copy-Item (Join-Path $tempPath 'Fonts\arialuni_sdf_u2018') $fontStage
    Copy-WithBackup $fontStage
    Copy-WithBackup (Join-Path $PSScriptRoot 'package')
    if ($oldKey) {
        $config = [IO.File]::ReadAllText($configPath)
        $config = [regex]::Replace($config, '(?m)^Endpoint=[^\S\r\n]*\r?$', 'Endpoint=DeepLTranslateLegitimate')
        $config = [regex]::Replace($config, '(?m)^ApiKey=.*$', [Text.RegularExpressions.MatchEvaluator]{ param($match) 'ApiKey=' + $oldKey })
        $config = [regex]::Replace($config, '(?m)^Free=.*$', 'Free=' + $oldFree)
        [IO.File]::WriteAllText($configPath, $config, (New-Object Text.UTF8Encoding($false)))
    }
    [IO.File]::WriteAllText((Join-Path $PSScriptRoot '.game-path'), $GamePath)
    Write-Host 'Installation complete. Existing DeepL API keys were preserved.' -ForegroundColor Green
    Write-Host 'Run DeepL-Key-Setup.cmd to enable DeepL, then launch the game through Steam.'
} catch {
    Write-Host $_.Exception.Message -ForegroundColor Red
}
$null = Read-Host 'Press Enter to close'
