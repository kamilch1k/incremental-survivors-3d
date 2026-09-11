$ErrorActionPreference = "SilentlyContinue"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$profileDir = Join-Path $root ".wallpaper-chrome"
$pidFile = Join-Path $profileDir "wallpaper.pid"
$ids = @()

if (Test-Path -LiteralPath $pidFile) {
  $ids += Get-Content -LiteralPath $pidFile | ForEach-Object { [int]$_ }
}

$ids += Get-CimInstance Win32_Process -Filter "name = 'chrome.exe' or name = 'msedge.exe'" |
  Where-Object { $_.CommandLine -and $_.CommandLine.Contains($profileDir) } |
  Select-Object -ExpandProperty ProcessId

$ids | Sort-Object -Unique | ForEach-Object {
  Stop-Process -Id $_ -Force
}

Remove-Item -LiteralPath $pidFile -Force
Write-Host "Incremental Survivors background mode stopped."
