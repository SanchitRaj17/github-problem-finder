$Config = if ($env:CODEX_HOME) { Join-Path $env:CODEX_HOME 'config.toml' } else { Join-Path $HOME '.codex/config.toml' }
if (-not (Test-Path $Config)) {
  Write-Host "Codex config not found: $Config"
  Write-Host "Create it and enable:`n[features]`nmulti_agent = true"
  exit 1
}
$content = Get-Content $Config -Raw
$match = [regex]::Match($content, '(?ms)^\s*\[features\]\s*$([\s\S]*?)(?=^\s*\[|\z)')
if ($match.Success -and [regex]::IsMatch($match.Groups[1].Value, '(?m)^\s*multi_agent\s*=\s*true\s*(?:#.*)?$')) {
  Write-Host "OK: multi_agent = true in $Config"
  exit 0
}
Write-Host "NOT ENABLED: multi_agent = true was not found under [features] in $Config"
exit 1
