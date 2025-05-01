#!/usr/bin/env pwsh

$ErrorActionPreference = "Stop"
$repoRoot = Resolve-Path "$PSScriptRoot"

Push-Location "$repoRoot"
try {
    Remove-Item -Recurse -Force "$repoRoot/.dist" -ErrorAction SilentlyContinue
    New-Item -ItemType Directory "$repoRoot/.dist" | Out-Null
    foreach ($package in @('package-a', 'package-b', 'package-c')) {
        $packageFolder = "$repoRoot/$package"
        if (!$IsWindows) {
            chmod +x "$packageFolder/index.js"
        }
        Write-Host "Packaging $packageFolder into $repoRoot/.dist"
        npm pack $packageFolder --pack-destination "$repoRoot/.dist"
    }
}
finally {
    Pop-Location
}