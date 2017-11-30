
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
param ()

$modulePath = Resolve-Path -Path "$PSScriptRoot\..\..\.." | Select-Object -ExpandProperty Path
$moduleName = Resolve-Path -Path "$PSScriptRoot\..\.." | Get-Item | Select-Object -ExpandProperty BaseName

Remove-Module -Name $moduleName -Force -ErrorAction SilentlyContinue
Import-Module -Name "$modulePath\$moduleName" -Force

$Global:TestRoot = "$modulePath\$moduleName"

# Execute tests
Describe 'Get-SPListItem' {

    Context 'GetAll' {

        Mock Invoke-RestMethod -ModuleName 'SharePointFever' -ParameterFilter { $Method = 'Get'; $Uri -eq 'http://SP01.contoso.com/sites/mysite/_vti_bin/listdata.svc/MyList?$expand=CreatedBy,ModifiedBy' } {
            Get-Content -Path "$Global:TestRoot\Tests\Unit\TestData\ListItem.SP01.Get.All.json" | ConvertFrom-Json
        }

        It 'ShouldParseResult' {

            # Arrange
            $SiteUrl  = 'http://SP01.contoso.com/sites/mysite'
            $ListName = 'MyList'

            # Act
            $Result = Get-SPListItem -SiteUrl $SiteUrl -ListName $ListName

            # Assert
            $Result.Count | Should Be 3
            Assert-MockCalled -CommandName 'Invoke-RestMethod' -ModuleName 'SharePointFever' -Times 1 -Exactly

            # Assert Item 1
            $Result[0].Id          | Should Be 1
            $Result[0].Title       | Should Be 'Item A'
            $Result[0].Description | Should Be 'My item A description'
            $Result[0].Number      | Should Be 123
            $Result[0].Date        | Should Be ([DateTime] '2016-01-01 00:00:00')
            $Result[0].ChoiseValue | Should Be 'Option 1'
            $Result[0].Version     | Should Be '1.0'
            $Result[0].Created     | Should Be ([DateTime] '2016-02-16 12:54:34')
            $Result[0].Modified    | Should Be ([DateTime] '2016-02-16 14:46:10')
            $Result[0].CreatedBy   | Should Be 'CONTOSO\johndoe'
            $Result[0].ModifiedBy  | Should Be 'CONTOSO\johndoe'

            # Assert Item 1
            $Result[1].Id          | Should Be 2
            $Result[1].Title       | Should Be 'Item B'
            $Result[1].Description | Should Be 'My item B description'
            $Result[1].Number      | Should Be 456
            $Result[1].Date        | Should Be ([DateTime] '2016-12-31 23:59:59')
            $Result[1].ChoiseValue | Should Be 'Option 2'
            $Result[1].Version     | Should Be '2.0'
            $Result[1].Created     | Should Be ([DateTime] '2016-02-16 12:54:35')
            $Result[1].Modified    | Should Be ([DateTime] '2016-02-16 14:46:11')
            $Result[1].CreatedBy   | Should Be 'CONTOSO\johndoe'
            $Result[1].ModifiedBy  | Should Be 'CONTOSO\johndoe'

            # Assert Item 1
            $Result[2].Id          | Should Be 3
            $Result[2].Title       | Should Be 'Item C'
            $Result[2].Description | Should Be 'My item C description'
            $Result[2].Number      | Should Be 789
            $Result[2].Date        | Should Be ([DateTime] '2016-07-13 14:01:38')
            $Result[2].ChoiseValue | Should Be 'Option 3'
            $Result[2].Version     | Should Be '3.0'
            $Result[2].Created     | Should Be ([DateTime] '2016-02-16 12:54:36')
            $Result[2].Modified    | Should Be ([DateTime] '2016-02-16 14:46:12')
            $Result[2].CreatedBy   | Should Be 'CONTOSO\johndoe'
            $Result[2].ModifiedBy  | Should Be 'CONTOSO\johndoe'
        }
    }

    Context 'GetOne' {

        Mock Invoke-RestMethod -ModuleName 'SharePointFever' -ParameterFilter { $Method = 'Get'; $Uri -eq 'http://SP01.contoso.com/sites/mysite/_vti_bin/listdata.svc/MyList(1)?$expand=CreatedBy,ModifiedBy' } {
            Get-Content -Path "$Global:TestRoot\Tests\Unit\TestData\ListItem.SP01.Get.One.json" | ConvertFrom-Json
        }

        It 'ShouldParseResult' {

            # Arrange
            $SiteUrl  = 'http://SP01.contoso.com/sites/mysite'
            $ListName = 'MyList'
            $ItemId   = 1

            # Act
            $Result = Get-SPListItem -SiteUrl $SiteUrl -ListName $ListName -ItemId $ItemId

            # Assert
            Assert-MockCalled -CommandName 'Invoke-RestMethod' -ModuleName 'SharePointFever' -Times 1 -Exactly

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

    Context 'NotExist' {

        Mock Invoke-RestMethod -ModuleName 'SharePointFever' -ParameterFilter { $Method = 'Get'; $Uri -eq 'http://SP01.contoso.com/sites/mysite/_vti_bin/listdata.svc/MyList(4)?$expand=CreatedBy,ModifiedBy' } {
            throw "Resource not found for the segment 'Inventory'."
        }

        It 'ShouldThrowError' {

            # Arrange
            $SiteUrl  = 'http://SP01.contoso.com/sites/mysite'
            $ListName = 'MyList'
            $ItemId   = 4

            # Act
            { Get-SPListItem -SiteUrl $SiteUrl -ListName $ListName -ItemId $ItemId -ErrorAction Stop } | Should Throw

            # Assert
            Assert-MockCalled -CommandName 'Invoke-RestMethod' -ModuleName 'SharePointFever' -Times 1 -Exactly
        }
    }
}
