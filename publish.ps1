$ErrorActionPreference = "Stop"
$repoRoot = Resolve-Path "$PSScriptRoot"

Push-Location "$repoRoot/dotnet"
try {
    $version = "1.0.0"

    $packages = Get-ChildItem -Path "$repoRoot/.dist" -Filter "*.tgz"

    foreach ($package in $packages) {
        Write-Host "Publishing package: $package"
        npm publish $package --registry https://registry.npmjs.org/ --access public
    }
}
finally {
    Pop-Location
}