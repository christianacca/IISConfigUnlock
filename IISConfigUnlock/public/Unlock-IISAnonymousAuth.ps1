function Unlock-IISAnonymousAuth {
    <#
    .SYNOPSIS
    Unlocks the 'anonymousAuthentication' web.config section so that a website/application
    can include this section in it's own web.config
    
    .DESCRIPTION
    Unlocks the 'anonymousAuthentication' web.config section so that a website/application
    can include this section in it's own web.config

    Specific section unlocked: 
    'system.webServer/security/authentication/anonymousAuthentication'
    
    .PARAMETER Location
    The logic path of a website that can now include this section in it's web.config
    
    .PARAMETER Commit
    Save changes to IIS immediately? Defaults to true
    
    .EXAMPLE
    Unlock-CaccaIISAnonymousAuth

    Description
    -----------
    Unlock 'anonymousAuthentication' section for all websites

    .EXAMPLE
    Unlock-CaccaIISAnonymousAuth -Location MyWebsite

    Description
    -----------
    Unlock 'anonymousAuthentication' section specifically for 'MyWebsite' and all child 
    web application in this site

    .EXAMPLE
    Unlock-CaccaIISAnonymousAuth -Location MyWebsite/MyApp

    Description
    -----------
    Unlock 'anonymousAuthentication' section specifically for 'MyApp' web application within 
    'MyWebsite' site

    .EXAMPLE
    New-CaccaIISWebsite MySite -Config {
        Unlock-CaccaIISAnonymousAuth -Location $_.Name -Commit:$false
    }

    Description
    -----------
    Unlock 'anonymousAuthentication' section for the 'MySite' being created by the 
    New-CaccaIISWebsite command
    

    #>  
    [CmdletBinding()]
    param (
        [string] $Location,
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
            $sectionPath = 'system.webServer/security/authentication/anonymousAuthentication'
            $sectionPath | Unlock-IISConfigSection -Location $Location -Commit:$Commit
        }
        catch {
            Write-Error -ErrorRecord $_ -EA $callerEA
        }
    }
}