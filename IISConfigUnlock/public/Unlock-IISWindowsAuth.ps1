function Unlock-IISWindowsAuth {
    <#
    .SYNOPSIS
    Unlocks the 'windowsAuthentication' web.config section so that a website/application
    can include this section in it's own web.config
    
    .DESCRIPTION
    Unlocks the 'windowsAuthentication' web.config section so that a website/application
    can include this section in it's own web.config

    Specific section unlocked: 
    'system.webServer/security/authentication/windowsAuthentication'
    
    .PARAMETER Location
    The logic path of a website that can now include this section in it's web.config
    
    .PARAMETER Minimum
    Only allow an application to configure:
    * whether Windows authentication is enable/disabled
    * extended protection
    
    .PARAMETER Commit
    Save changes to IIS immediately? Defaults to true
    
    .EXAMPLE
    Unlock-CaccaIISWindowsAuth

    Description
    -----------
    Unlock 'windowsAuthentication' section for all websites

    .EXAMPLE
    Unlock-CaccaIISWindowsAuth -Location MyWebsite

    Description
    -----------
    Unlock 'windowsAuthentication' section specifically for 'MyWebsite' and all child 
    web application in this site

    .EXAMPLE
    Unlock-CaccaIISWindowsAuth -Location MyWebsite/MyApp

    Description
    -----------
    Unlock 'windowsAuthentication' section specifically for 'MyApp' web application within 
    'MyWebsite' site

    .EXAMPLE
    New-CaccaIISWebsite MySite -Config {
        Unlock-CaccaIISWindowsAuth -Location $_.Name -Commit:$false
    }

    Description
    -----------
    Unlock 'windowsAuthentication' section for the 'MySite' being created by the 
    New-CaccaIISWebsite command

    #>
    [CmdletBinding()]
    param (
        [string] $Location,
        [switch] $Minimum,
        [switch] $Commit
    )
    
    begin {
        Set-StrictMode -Version Latest
        Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        $callerEA = $ErrorActionPreference
        $ErrorActionPreference = 'Stop'

        if (!$PSBoundParameters.ContainsKey('Commit')) {
            $Commit = $true
        }
    }
    
    process {
        try {

            if ($Commit) {
                Start-IISCommitDelay
            }

            $winAuthConfig = Get-IISConfigSection `
                'system.webServer/security/authentication/windowsAuthentication' `
                -Location $Location

            $winAuthConfig.OverrideMode = 'Allow'
            if ($Minimum) {
                $winAuthConfig.SetMetadata('lockAllAttributesExcept', 'enabled')
                $winAuthConfig.SetMetadata('lockAllElementsExcept', 'extendedProtection')
            }

            if ($Commit) {
                Stop-IISCommitDelay
            }
            
        }
        catch {
            Write-Error -ErrorRecord $_ -EA $callerEA
        }
    }
}