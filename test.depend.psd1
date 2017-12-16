@{ 
    PSDependOptions     = @{ 
        Target    = '$DependencyPath/_build-cache/'
        AddToPath = $true
    }
    # Add the *exact versions* of any dependencies of your module...
    IISAdministration   = '1.1.0.0'
    PreferenceVariables = '1.0'
}