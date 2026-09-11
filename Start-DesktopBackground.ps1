param(
  [switch]$NoEmbed
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$html = Join-Path $root "index.html"
$profileDir = Join-Path $root ".wallpaper-chrome"
$pidFile = Join-Path $profileDir "wallpaper.pid"

if (!(Test-Path -LiteralPath $html)) {
  throw "Could not find index.html next to this script."
}

$chromeCandidates = @(
  "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
  "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
  "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
  "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
) | Where-Object { $_ -and (Test-Path -LiteralPath $_) }

if (!$chromeCandidates.Count) {
  throw "Chrome or Edge was not found. Install one of them, then run this again."
}

New-Item -ItemType Directory -Force -Path $profileDir | Out-Null
$url = ([System.Uri]$html).AbsoluteUri + "?wallpaper=1"
$browser = $chromeCandidates[0]
$args = @(
  "--new-window",
  "--app=$url",
  "--start-fullscreen",
  "--window-position=0,0",
  "--user-data-dir=$profileDir",
  "--no-first-run"
)

$proc = Start-Process -FilePath $browser -ArgumentList $args -PassThru
Set-Content -LiteralPath $pidFile -Value $proc.Id -Encoding ASCII

function Get-WallpaperProcess {
  param([string]$ProfileDir)
  $rows = Get-CimInstance Win32_Process -Filter "name = 'chrome.exe' or name = 'msedge.exe'" |
    Where-Object { $_.CommandLine -and $_.CommandLine.Contains($ProfileDir) }
  foreach ($row in $rows) {
    $p = Get-Process -Id $row.ProcessId -ErrorAction SilentlyContinue
    if ($p -and $p.MainWindowHandle -ne 0) { return $p }
  }
  return $null
}

$wallProc = $null
for ($i = 0; $i -lt 80 -and !$wallProc; $i++) {
  Start-Sleep -Milliseconds 125
  $wallProc = Get-WallpaperProcess -ProfileDir $profileDir
}

if (!$wallProc) {
  Write-Host "Started browser wallpaper mode, but could not find the window handle yet."
  exit 0
}

if (!$NoEmbed) {
  Add-Type @"
using System;
using System.Runtime.InteropServices;
public static class NativeDesktop {
  public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
  [DllImport("user32.dll", SetLastError=true)] public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
  [DllImport("user32.dll", SetLastError=true)] public static extern IntPtr FindWindowEx(IntPtr parent, IntPtr childAfter, string className, string windowName);
  [DllImport("user32.dll", SetLastError=true)] public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);
  [DllImport("user32.dll", SetLastError=true)] public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam, uint flags, uint timeout, out IntPtr result);
  [DllImport("user32.dll", SetLastError=true)] public static extern IntPtr SetParent(IntPtr hWndChild, IntPtr hWndNewParent);
  [DllImport("user32.dll", SetLastError=true)] public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);
  [DllImport("user32.dll")] public static extern int GetSystemMetrics(int nIndex);
}
"@

  $progman = [NativeDesktop]::FindWindow("Progman", $null)
  $result = [IntPtr]::Zero
  [NativeDesktop]::SendMessageTimeout($progman, 0x052C, [IntPtr]::Zero, [IntPtr]::Zero, 0, 1000, [ref]$result) | Out-Null

  $script:desktopWorker = [IntPtr]::Zero
  $cb = [NativeDesktop+EnumWindowsProc]{
    param([IntPtr]$top, [IntPtr]$param)
    $shell = [NativeDesktop]::FindWindowEx($top, [IntPtr]::Zero, "SHELLDLL_DefView", $null)
    if ($shell -ne [IntPtr]::Zero) {
      $script:desktopWorker = [NativeDesktop]::FindWindowEx([IntPtr]::Zero, $top, "WorkerW", $null)
    }
    return $true
  }
  [NativeDesktop]::EnumWindows($cb, [IntPtr]::Zero) | Out-Null
  if ($script:desktopWorker -eq [IntPtr]::Zero) { $script:desktopWorker = $progman }

  [NativeDesktop]::SetParent($wallProc.MainWindowHandle, $script:desktopWorker) | Out-Null
  $sw = [NativeDesktop]::GetSystemMetrics(0)
  $sh = [NativeDesktop]::GetSystemMetrics(1)
  [NativeDesktop]::SetWindowPos($wallProc.MainWindowHandle, [IntPtr]::Zero, 0, 0, $sw, $sh, 0x0040) | Out-Null
}

Write-Host "Incremental Survivors background mode is running."
Write-Host "Exit from inside the game with Esc or P, or run Stop-DesktopBackground.ps1."
