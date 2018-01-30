#Requires -RunAsAdministrator

$ErrorActionPreference = 'Stop'
$InformationPreference = 'Continue'

$currentDirectory = $args[0]

# cache module dependencies
$buildCachePath = Join-Path $PSScriptRoot '..\_build-cache'
if (-not(Test-Path $buildCachePath)) {
    Set-Location "$PSScriptRoot\..\"
    & .\build.ps1 'init'
}

# allow PS to see dependencies our module needs from the cache
$buildCachePath = Resolve-Path $buildCachePath
$originalPath = Get-Item -Path Env:\PSModulePath | Select -Exp Value
$psModulePaths = $originalPath -split ';' | Where {$_ -ne $Path}
$revisedPath = ( @($buildCachePath) + @($psModulePaths) | Select -Unique ) -join ';'
Set-Item -Path Env:\PSModulePath -Value $revisedPath  -EA Stop

# import module from source code into current PS session
$moduleName = 'IISConfigUnlock'
$modulePath = Join-Path $PSScriptRoot "..\$moduleName" -Resolve
Import-Module $modulePath -EA Stop

Set-Location $currentDirectory

# show that module loaded into PS session
Get-Module -Name $moduleName
