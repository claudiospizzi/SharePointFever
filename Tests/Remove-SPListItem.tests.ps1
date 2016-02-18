
# Load module
if ($Env:APPVEYOR -eq 'True')
{
    $Global:TestRoot = (Get-Module Spizzi.SharePoint -ListAvailable).ModuleBase

    Import-Module Spizzi.SharePoint -Force
}
else
{
    $Global:TestRoot = (Split-Path -Parent $MyInvocation.MyCommand.Path | Join-Path -ChildPath '..' | Resolve-Path).Path

    Import-Module "$Global:TestRoot\Spizzi.SharePoint.psd1" -Force
}

# Execute tests
Describe 'Remove-SPListItem' {

    Context 'RemoveOne' {

        Mock Invoke-RestMethod -ModuleName 'Spizzi.SharePoint' -ParameterFilter { $Method = 'Post'; $Uri -eq 'http://SP01.contoso.com/sites/mysite/_vti_bin/listdata.svc/MyList(1)' } {
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
            Assert-MockCalled -CommandName 'Invoke-RestMethod' -ModuleName 'Spizzi.SharePoint' -Times 1 -Exactly
        }
    }

    Context 'NotExist' {

        Mock Invoke-RestMethod -ModuleName 'Spizzi.SharePoint' -ParameterFilter { $Method = 'Post'; $Uri -eq 'http://SP01.contoso.com/sites/mysite/_vti_bin/listdata.svc/MyList(4)' } {
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
            Assert-MockCalled -CommandName 'Invoke-RestMethod' -ModuleName 'Spizzi.SharePoint' -Times 1 -Exactly
        }
    }
}
