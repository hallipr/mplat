#!/usr/bin/env pwsh

param(
    [string] $PreRelease
)

$ErrorActionPreference = "Stop"
$repoRoot = Resolve-Path "$PSScriptRoot"

$Version = (node -p "require('./npm-module/package.json').version")

if ($PreRelease) {
    $Version = $Version + "-$PreRelease"
}

Push-Location "$repoRoot/dotnet"
try {
    Remove-Item -Recurse -Force "$repoRoot/.work" -ErrorAction SilentlyContinue
    Remove-Item -Recurse -Force "$repoRoot/.dist" -ErrorAction SilentlyContinue
    New-Item -ItemType Directory "$repoRoot/.dist" | Out-Null
    New-Item -ItemType Directory "$repoRoot/.work" | Out-Null

    $platforms = @(
        @{ os = "linux"; arch = "x64" },
        @{ os = "linux"; arch = "arm64" },
        @{ os = "osx"; arch = "x64"; node_os = "darwin" },
        @{ os = "osx"; arch = "arm64"; node_os = "darwin" },
        @{ os = "win"; arch = "x64"; node_os = "win32" }
    )

    $wrapperPackageJson = Get-Content "$repoRoot/npm-module/package.json" -Raw | ConvertFrom-Json -AsHashtable
    $wrapperPackageJson.version = $Version

    foreach ($platform in $platforms) {
        $os = $platform.os
        $arch = $platform.arch
        $node_os = $platform.node_os ?? $platform.os

        $outputDir = "$repoRoot/.work/$node_os-$arch/bin"
        $extension = $os -eq "win" ? ".exe" : ""

        dotnet publish -r "$os-$arch" `
            -p:SelfContained=true `
            -p:PublishReadyToRun=true `
            -p:PublishSingleFile=true `
            -p:PublishTrimmed=true `
            -p:AssemblyName="mplat-cli" `
            -c Release `
            -o $outputDir
        
        chmod +x "$outputDir/mplat-cli$extension"

        # create a package.json in the output directory with a bin entry for the executable
        $packageJson = [ordered]@{
            name = "@hallipr/mplat-$node_os-$arch"
            version = $Version
            description = "A .NET application"
            os = $node_os
            arch = $arch
            'directories.bin' = 'bin'
        }
        
        $packageFolder = "$repoRoot/.work/$node_os-$arch"

        $packageJson
          | ConvertTo-Json -Depth 10
          | Out-File -FilePath "$packageFolder/package.json" -Encoding utf8

        Write-Host "Created package.json in $packageFolder"

        Write-Host "Packaging $packageFolder into $repoRoot/.dist"
        npm pack $packageFolder --pack-destination "$repoRoot/.dist"

        $wrapperPackageJson.optionalDependencies["@hallipr/mplat-$node_os-$arch"] = $version
    }

    $wrapperFolder = "$repoRoot/.work/mplat"
    New-Item -ItemType Directory $wrapperFolder | Out-Null
    Copy-Item -Path "$repoRoot/npm-module/*" -Destination $wrapperFolder -Recurse -Force
    chmod +x "$wrapperFolder/bin/mplat.js"
    $wrapperPackageJson | ConvertTo-Json -Depth 10 | Out-File -FilePath "$wrapperFolder/package.json" -Encoding utf8
    Write-Host "Created package.json in $wrapperFolder"

    Write-Host "Packaging $wrapperFolder into $repoRoot/.dist"
    npm pack $wrapperFolder --pack-destination "$repoRoot/.dist"
}
finally {
    Pop-Location
}