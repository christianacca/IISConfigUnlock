<#
.Description
Installs and loads all the required modules for the build.
Derived from scripts written by Warren F. (RamblingCookieMonster)
#>

[cmdletbinding()]
param ($Task = 'Default')
if ($Task -eq 'init')
{
    Write-Output "Starting build (init only)"
} 
else 
{
    Write-Output "Starting build"
}

if (-not (Get-PackageProvider -Name Nuget -EA SilentlyContinue))
{
    Write-Output "  Install Nuget PS package provider"
    Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null
}

# Register custom PS Repo (currently required for forked vs of PSDepend)
$customRepo = 'christianacca-ps'
if (-not(Get-PSRepository -Name $customRepo -EA SilentlyContinue))
{
    Write-Output "  Registering custom PS Repository '$customRepo'"    
    $repo = @{
        Name                  = $customRepo
        SourceLocation        = "https://www.myget.org/F/$customRepo/api/v2"
        ScriptSourceLocation  = "https://www.myget.org/F/$customRepo/api/v2/"
        PublishLocation       = "https://www.myget.org/F/$customRepo/api/v2/package"
        ScriptPublishLocation = "https://www.myget.org/F/$customRepo/api/v2/package/"
        InstallationPolicy    = 'Trusted'
    }
    Register-PSRepository @repo
}

# Grab nuget bits, install modules, set build variables, start build.
Write-Output "  Install And Import Dependent Modules"
Write-Output "    Build Modules"
$psDependVersion = '0.1.58.1'
if (-not(Get-InstalledModule PSDepend -RequiredVersion $psDependVersion -EA SilentlyContinue))
{
    # todo: remove -Repository parameter once module changes land on PSGallery
    Install-Module PSDepend -RequiredVersion $psDependVersion -Repository $customRepo -Scope CurrentUser
}
Import-Module PSDepend -RequiredVersion $psDependVersion
Invoke-PSDepend -Path "$PSScriptRoot\build.depend.psd1" -Install -Import -Force

Write-Output "    SUT Modules"
Invoke-PSDepend -Path "$PSScriptRoot\test.depend.psd1" -Install -Import -Force

if (-not (Get-Item env:\BH*)) 
{
    Set-BuildEnvironment
}
$global:SUTPath = $env:BHPSModuleManifest
. "$PSScriptRoot\tests\Unload-SUT.ps1"

if ($Task -eq 'init') 
{
    Write-Output "Build succeeded (init only)"
    return
}

Write-Output "  InvokeBuild"
Invoke-Build $Task -Result result
if ($Result.Error)
{
    exit 1
}
else 
{
    exit 0
}