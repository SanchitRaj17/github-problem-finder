#!/usr/bin/env pwsh
# PowerShell version of install.sh for Windows users

$SKILL_NAME = "github-problem-finder"
$DEST = ".codex/skills/${SKILL_NAME}"

$REPO_URL = $args[0]
if ([string]::IsNullOrWhiteSpace($REPO_URL)) {
    Write-Host "Usage: .\scripts\install.ps1 <git-repo-url>"
    exit 1
}

$tmp_dir = New-TemporaryFile | ForEach-Object { Remove-Item $_; New-Item -ItemType Directory -Path $_.FullName }

try {
    New-Item -ItemType Directory -Path ".codex/skills" -Force | Out-Null

    Write-Host "Cloning skill from: $REPO_URL"
    git clone --depth 1 "$REPO_URL" "$tmp_dir" 2>&1 | Out-Null

    if (Test-Path "$DEST") {
        Remove-Item -Recurse -Force "$DEST"
    }
    New-Item -ItemType Directory -Path "$DEST" -Force | Out-Null

    Copy-Item "$tmp_dir/skill.md" "$DEST/skill.md" -Force
    if (Test-Path "$tmp_dir/references") {
        Copy-Item -Recurse "$tmp_dir/references" "$DEST/references" -Force
    }
    if (Test-Path "$tmp_dir/examples") {
        Copy-Item -Recurse "$tmp_dir/examples" "$DEST/examples" -Force
    }

    Write-Host "Installed skill at: $DEST/skill.md"
}
finally {
    Remove-Item -Recurse -Force "$tmp_dir" -ErrorAction SilentlyContinue
}
