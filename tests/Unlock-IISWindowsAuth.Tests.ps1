Describe 'Unlock-IISWindowsAuth' {
    
    BeforeAll {
        Unload-SUT
        Import-Module ($global:SUTPath)
    }

    AfterAll {
        Unload-SUT
    }

    $winAuthSectionPath = 'system.webServer/security/authentication/windowsAuthentication'

    AfterEach {
        # throw away local changes
        Reset-IISServerManager -Confirm:$false
    }

    It "Should unlock the anonymousAuthentication section in applicationHost.config" {
        # checking assumptions
        (Get-IISConfigSection $winAuthSectionPath).OverrideMode | Should -Be 'Inherit'

        # when
        Unlock-CaccaIISWindowsAuth -Commit:$false

        # then
        (Get-IISConfigSection $winAuthSectionPath).OverrideMode | Should -Be 'Allow'
    }

    Context "Specific site" {
        $testSiteName = 'DeleteMeSite'
        $tempSitePath = "$Env:TEMP\$testSiteName"

        function CreateTestSite {
            New-Item $tempSitePath -ItemType Directory -EA Ignore
            New-IISSite $testSiteName $tempSitePath -BindingInformation "*:658:$($testSiteName)"
        }

        function Cleanup {
            Remove-IISSite $testSiteName -EA Ignore -Confirm:$false -WA SilentlyContinue
            Reset-IISServerManager -Confirm:$false
            Remove-Item $tempSitePath -Recurse -Confirm:$false -EA Ignore
        }

        BeforeEach {
            Cleanup
            CreateTestSite
        }
    
        AfterEach {
            Cleanup
        }

        It "Should lock section for site" {
            # checking assumptions
            (Get-IISConfigSection $winAuthSectionPath -Location $testSiteName).OverrideMode | Should -Be 'Inherit'

            # when
            Unlock-CaccaIISWindowsAuth -Location $testSiteName

            # then
            (Get-IISConfigSection $winAuthSectionPath -Location $testSiteName).OverrideMode | Should -Be 'Allow'
        }
        
    }
}