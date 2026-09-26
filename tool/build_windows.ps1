# Run from PowerShell on Windows with Flutter and Visual Studio C++ tools.
$ErrorActionPreference = 'Stop'
if ($env:OS -ne 'Windows_NT') {
    throw 'Run this script on Windows.'
}
Push-Location (Join-Path $PSScriptRoot '..')
try {
    flutter pub get --enforce-lockfile
    if ($LASTEXITCODE -ne 0) { throw 'Dependency resolution failed.' }
    flutter build windows --release
    if ($LASTEXITCODE -ne 0) { throw 'Windows build failed.' }

    $bundle = 'build/windows/x64/runner/Release'
    if (-not (Test-Path "$bundle/doever.exe")) { throw 'doever.exe was not generated.' }
    Copy-Item LICENSE, THIRD_PARTY_NOTICES.md -Destination $bundle -Force
    New-Item -ItemType Directory -Path "$bundle/licenses" -Force | Out-Null
    Copy-Item assets/fonts/*LICENSE.txt -Destination "$bundle/licenses" -Force
    $output = 'build/releases'
    New-Item -ItemType Directory -Path $output -Force | Out-Null
    $archive = Join-Path $output 'doever-windows-x64.zip'
    Compress-Archive -Path "$bundle/*" -DestinationPath $archive -Force
    $hash = (Get-FileHash -Algorithm SHA256 $archive).Hash.ToLowerInvariant()
    "$hash  doever-windows-x64.zip" | Set-Content "$archive.sha256" -Encoding ascii
    Write-Output "Executable: $bundle/doever.exe"
    Write-Output "Archive: $archive"
} finally {
    Pop-Location
}
