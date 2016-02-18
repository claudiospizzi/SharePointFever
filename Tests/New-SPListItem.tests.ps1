
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
Describe 'New-SPListItem' {

    Context 'CreateOne' {

        Mock Invoke-RestMethod -ModuleName 'Spizzi.SharePoint' -ParameterFilter { $Method = 'Post'; $Uri -eq 'http://SP01.contoso.com/sites/mysite/_vti_bin/listdata.svc/MyList' } {
            Get-Content -Path "$Global:TestRoot\Tests\TestData\ListItem.SP01.New.json" | ConvertFrom-Json
        }

        Mock Invoke-RestMethod -ModuleName 'Spizzi.SharePoint' -ParameterFilter { $Method = 'Get'; $Uri -eq 'http://SP01.contoso.com/sites/mysite/_vti_bin/listdata.svc/MyList(1)?$expand=CreatedBy,ModifiedBy' } {
            Get-Content -Path "$Global:TestRoot\Tests\TestData\ListItem.SP01.Get.One.json" | ConvertFrom-Json
        }

        It 'ShouldParseResult' {

            # Arrange
            $SiteUrl  = 'http://SP01.contoso.com/sites/mysite'
            $ListName = 'MyList'
            $Property = @{
                Title       = 'Item A'
                Description = 'My item A description'
                Number      = 123
                Date        = [DateTime] '2016-01-01 00:00:00'
                ChoiseValue = 'Option 1'
            }

            # Act
            $Result = New-SPListItem -SiteUrl $SiteUrl -ListName $ListName -Property $Property

            # Assert
            Assert-MockCalled -CommandName 'Invoke-RestMethod' -ModuleName 'Spizzi.SharePoint' -Times 2 -Exactly

            # Assert Item
            $Result.Id          | Should Be 1
            $Result.Title       | Should Be 'Item A'
            $Result.Description | Should Be 'My item A description'
            $Result.Number      | Should Be 123
            $Result.Date        | Should Be ([DateTime] '2016-01-01 00:00:00')
            $Result.ChoiseValue | Should Be 'Option 1'
            $Result.Version     | Should Be '1.0'
            $Result.Created     | Should Be ([DateTime] '2016-02-16 12:54:34')
            $Result.Modified    | Should Be ([DateTime] '2016-02-16 14:46:10')
            $Result.CreatedBy   | Should Be 'CONTOSO\johndoe'
            $Result.ModifiedBy  | Should Be 'CONTOSO\johndoe'
        }
    }

    Context 'NotValid' {

        Mock Invoke-RestMethod -ModuleName 'Spizzi.SharePoint' -ParameterFilter { $Method = 'Post'; $Uri -eq 'http://SP01.contoso.com/sites/mysite/_vti_bin/listdata.svc/MyList' } {
            throw 'An error occurred while processing this request.'
        }

        It 'ShouldThrowError' {
        
            # Arrange
            $SiteUrl  = 'http://SP01.contoso.com/sites/mysite'
            $ListName = 'MyList'
            $Property = @{
                Title       = $null
                Description = 1
                Number      = 'This is not a number.'
                Date        = [DateTime] '2016-01-01 12:34:56'
                ChoiseValue = 'Unavailable Option'
            }

            # Act
            { New-SPListItem -SiteUrl $SiteUrl -ListName $ListName -Property $Property -ErrorAction Stop } | Should Throw

            # Assert
            Assert-MockCalled -CommandName 'Invoke-RestMethod' -ModuleName 'Spizzi.SharePoint' -Times 1 -Exactly
        }
    }
}
