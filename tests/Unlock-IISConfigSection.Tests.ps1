Describe 'Unlock-IISConfigSection' {
    
    BeforeAll {
        Unload-SUT
        Import-Module ($global:SUTPath)
    }

    AfterAll {
        Unload-SUT
    }

    $anonAuthSectionPath = 'system.webServer/security/authentication/anonymousAuthentication'

    AfterEach {
        # throw away local changes
        Reset-IISServerManager -Confirm:$false
    }

    It "Should unlock pipped section object in applicationHost.config" {
        # checking assumptions
        (Get-IISConfigSection $anonAuthSectionPath).OverrideMode | Should -Be 'Inherit'

        # when
        Get-IISConfigSection $anonAuthSectionPath | Unlock-CaccaIISConfigSection -Commit:$false

        # then
        (Get-IISConfigSection $anonAuthSectionPath).OverrideMode | Should -Be 'Allow'
    }

    It "Should unlock pipped section path in applicationHost.config" {
        # checking assumptions
        (Get-IISConfigSection $anonAuthSectionPath).OverrideMode | Should -Be 'Inherit'

        # when
        $anonAuthSectionPath | Unlock-CaccaIISConfigSection -Commit:$false

        # then
        (Get-IISConfigSection $anonAuthSectionPath).OverrideMode | Should -Be 'Allow'
    }
}