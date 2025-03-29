#!/usr/bin/env pwsh

$ErrorActionPreference = "Stop"
$repoRoot = Resolve-Path "$PSScriptRoot"

Push-Location $repoRoot
try {
    $packages = Get-ChildItem -Path "$repoRoot/.dist" -Filter "*.tgz"

    foreach ($package in $packages) {
        Write-Host "Publishing package: $package"
        npm publish $package --registry https://registry.npmjs.org/ --access public
    }
}
finally {
    Pop-Location
}