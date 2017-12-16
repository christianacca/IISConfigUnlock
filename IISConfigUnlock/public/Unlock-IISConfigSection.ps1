function Unlock-IISConfigSection {
    <#
    .SYNOPSIS
    Unlocks the specified web.config section so that a website/application can 
    include this section in it's own web.config
    
    .DESCRIPTION
    Unlocks the specified web.config section so that a website/application can
    include this section in it's own web.config
    
    .PARAMETER SectionPath
    The web.config section to unlock
    
    .PARAMETER Section
    The web.config section to unlock
    
    .PARAMETER Location
    The logic path of a website that can now include this section in it's web.config
    
    .PARAMETER Commit
    Save changes to IIS immediately? Defaults to true
    
    .EXAMPLE
    Unlock-CaccaIISAnonymousAuth -SectionPath 'system.webServer/security/authentication/anonymousAuthentication'

    Description
    -----------
    Unlock 'anonymousAuthentication' section for all websites. 
    Equivalent to: Unlock-CaccaIISAnonymousAuth

    .EXAMPLE
    New-CaccaIISWebsite MySite -Config {
        $params = @{
            SectionPath = 'system.webServer/security/authentication/anonymousAuthentication'
            Location    = $_.Name
            Commit      = $false
        }
        Unlock-CaccaIISAnonymousAuth @params
    }

    Description
    -----------
    Unlock 'anonymousAuthentication' section for the 'MySite' being created by the 
    New-CaccaIISWebsite command

    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ParameterSetName='Path', ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string] $SectionPath,

        [Parameter(Mandatory, ParameterSetName='Config', ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [Microsoft.Web.Administration.ConfigurationSection] $Section,

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

            if ($Commit) {
                Start-IISCommitDelay
            }

            $sectionConfig = if ($Section) { 
                $Section
            }
            else {
                Get-IISConfigSection $SectionPath -Location $Location
            }

            $sectionConfig.OverrideMode = 'Allow'
            
            if ($Commit) {
                Stop-IISCommitDelay
            }
            
        }
        catch {
            Write-Error -ErrorRecord $_ -EA $callerEA
        }
    }
}