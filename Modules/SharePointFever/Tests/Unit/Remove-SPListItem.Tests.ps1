
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
param ()

$modulePath = Resolve-Path -Path "$PSScriptRoot\..\..\.." | Select-Object -ExpandProperty Path
$moduleName = Resolve-Path -Path "$PSScriptRoot\..\.." | Get-Item | Select-Object -ExpandProperty BaseName

Remove-Module -Name $moduleName -Force -ErrorAction SilentlyContinue
Import-Module -Name "$modulePath\$moduleName" -Force

$Global:TestRoot = "$modulePath\$moduleName"

# Execute tests
Describe 'Remove-SPListItem' {

    Context 'RemoveOne' {

        Mock Invoke-RestMethod -ModuleName 'SharePointFever' -ParameterFilter { $Method = 'Post'; $Uri -eq 'http://SP01.contoso.com/sites/mysite/_vti_bin/listdata.svc/MyList(1)' } {
            return ''
        }

        It 'ShouldThrowError' {

            # Arrange
            $SiteUrl  = 'http://SP01.contoso.com/sites/mysite'
            $ListName = 'MyList'
            $ItemId   = 1

            # Act
            $Result = Remove-SPListItem -SiteUrl $SiteUrl -ListName $ListName -ItemId $ItemId

            # Assert
            $Result | Should Be $null
            Assert-MockCalled -CommandName 'Invoke-RestMethod' -ModuleName 'SharePointFever' -Times 1 -Exactly
        }
    }

    Context 'NotExist' {

        Mock Invoke-RestMethod -ModuleName 'SharePointFever' -ParameterFilter { $Method = 'Post'; $Uri -eq 'http://SP01.contoso.com/sites/mysite/_vti_bin/listdata.svc/MyList(4)' } {
            throw 'An error occurred while processing this request.'
        }

        It 'ShouldThrowError' {

            # Arrange
            $SiteUrl  = 'http://SP01.contoso.com/sites/mysite'
            $ListName = 'MyList'
            $ItemId   = 4

            # Act
            { Remove-SPListItem -SiteUrl $SiteUrl -ListName $ListName -ItemId $ItemId -ErrorAction Stop } | Should Throw

            # Assert
            Assert-MockCalled -CommandName 'Invoke-RestMethod' -ModuleName 'SharePointFever' -Times 1 -Exactly
        }
    }
}
