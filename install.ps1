# Apply opencode configuration from this repo (Windows / PowerShell).
# Copies opencode.jsonc, AGENTS.md and the agents into ~/.config/opencode.
[CmdletBinding()]
param(
  [string]$OpencodeDir = (Join-Path $HOME ".config\opencode")
)

$ErrorActionPreference = "Stop"
$Here = $PSScriptRoot

function Copy-File($Src, $Dest) {
  $destParent = Split-Path -Parent $Dest
  if (-not (Test-Path $destParent)) { New-Item -ItemType Directory -Path $destParent -Force | Out-Null }

  if (-not (Test-Path $Src)) {
    Write-Host "!! source missing: $Src" -ForegroundColor Red
    throw "source path does not exist: $Src"
  }
  $leaf = Split-Path -Leaf $Dest
  if (Test-Path $Dest) {
    if ((Get-FileHash $Src).Hash -eq (Get-FileHash $Dest).Hash) {
      Write-Host "    unchanged $leaf"
      return
    }
    $backup = "$Dest.bak.$([int][double]::Parse((Get-Date -UFormat %s)))"
    Move-Item $Dest $backup -Force
    Write-Host "    backed up existing $leaf"
  }
  Copy-Item $Src $Dest -Force
  Write-Host "    copied $leaf"
}

Write-Host "==> Applying opencode config from $Here -> $OpencodeDir"
if (-not (Test-Path $OpencodeDir)) { New-Item -ItemType Directory -Path $OpencodeDir -Force | Out-Null }
$agentsDest = Join-Path $OpencodeDir "agents"
if (-not (Test-Path $agentsDest)) { New-Item -ItemType Directory -Path $agentsDest -Force | Out-Null }

# opencode also reads a plain opencode.json and merges it with opencode.jsonc;
# retire it so this repo's opencode.jsonc is the only global config.
$legacy = Join-Path $OpencodeDir "opencode.json"
if (Test-Path $legacy) {
  $backup = "$legacy.bak.$([int][double]::Parse((Get-Date -UFormat %s)))"
  Move-Item $legacy $backup -Force
  Write-Host "    backed up legacy opencode.json (superseded by opencode.jsonc)"
}

Copy-File (Join-Path $Here "opencode.jsonc") (Join-Path $OpencodeDir "opencode.jsonc")
Copy-File (Join-Path $Here "AGENTS.md") (Join-Path $OpencodeDir "AGENTS.md")
$agentsDir = Join-Path $Here "agents"
if (Test-Path $agentsDir) {
  Get-ChildItem -Path $agentsDir -Filter *.md | ForEach-Object {
    Copy-File $_.FullName (Join-Path $agentsDest $_.Name)
  }
}

Write-Host ""
Write-Host "==> Done. Installed:"
Write-Host "    $OpencodeDir\opencode.jsonc   <- $Here\opencode.jsonc"
Write-Host "    $OpencodeDir\AGENTS.md        <- $Here\AGENTS.md"
Write-Host "    $OpencodeDir\agents\*.md      <- $Here\agents"
Write-Host ""
Write-Host "==> Notes:"
Write-Host "    Sign in to the Vercel AI Gateway with: opencode auth login"
Write-Host "    mobbin runs through mcp-remote: the first time opencode starts it, a browser opens"
Write-Host "    for the Mobbin login; the token is then shared by every agent via ~/.mcp-auth."
Write-Host "    Nothing is linked: re-run this script after editing files here."
Write-Host ""
Write-Host "==> Verify with:"
Write-Host "    opencode mcp list"
