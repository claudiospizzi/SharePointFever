@{
    RootModule         = 'Spizzi.SharePoint.psm1'
    ModuleVersion      = '1.0.0'
    GUID               = 'DDC1E869-EF38-470C-B950-A737661537B5'
    Author             = 'Claudio Spizzi'
    Copyright          = 'Copyright (c) 2016 by Claudio Spizzi. Licensed under MIT license.'
    Description        = 'Personal PowerShell Module by Claudio Spizzi with independent functions and cmdlets for SharePoint.'
    PowerShellVersion  = '3.0'
    RequiredModules    = @()
    ScriptsToProcess   = @()
    TypesToProcess     = @(
        'Resources/SharePoint.Types.ps1xml'
    )
    FormatsToProcess   = @(
        'Resources/SharePoint.Formats.ps1xml'
    )
    FunctionsToExport  = @(
        'Get-SPListItem'
        'New-SPListItem'
        'Remove-SPListItem'
        'Set-SPListItem'
    )
    CmdletsToExport    = @()
    VariablesToExport  = @()
    AliasesToExport    = @()
    PrivateData        = @{
        PSData             = @{
            Tags               = @('PSModule', 'SharePoint')
            LicenseUri         = 'https://raw.githubusercontent.com/claudiospizzi/Spizzi.SharePoint/master/LICENSE'
            ProjectUri         = 'https://github.com/claudiospizzi/Spizzi.SharePoint'
        }
    }
}
