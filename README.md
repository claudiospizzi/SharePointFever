[![PowerShell Gallery - SharePointFever](https://img.shields.io/badge/PowerShell_Gallery-SharePointFever-0072C6.svg)](https://www.powershellgallery.com/packages/SharePointFever)
[![GitHub - Release](https://img.shields.io/github/release/claudiospizzi/SharePointFever.svg)](https://github.com/claudiospizzi/SharePointFever/releases)
[![AppVeyor - master](https://img.shields.io/appveyor/ci/claudiospizzi/SharePointFever/master.svg)](https://ci.appveyor.com/project/claudiospizzi/SharePointFever/branch/master)

# SharePointFever PowerShell Module

Personal PowerShell Module by Claudio Spizzi with independent functions and
cmdlets for SharePoint.

## Introduction

tbd

## Features

### SharePoint Online

ToDo

### SharePoint Server 2010 Legacy

* **Get-SPServerListItem**  
  Get items from a SharePoint list. This command uses the old web api based on
  the _VTI_BIN endpoint.

* **New-SPServerListItem**  
  Create an item inside an SharePoint list. This command uses the old web api
  based on the _VTI_BIN endpoint.

* **Remove-SPServerListItem**  
  Remove an existing item from a SharePoint list. This command uses the old web
  api based on the _VTI_BIN endpoint.

* **Set-SPServerListItem**  
  Update properties of an existing item inside a SharePoint list. This command
  uses the old web api based on the _VTI_BIN endpoint.

## Examples

### SharePoint Online Examples

ToDo

### SharePoint Server 2010 Legacy Examples

Script showing the legacy SharePoint Server cmdlets.

```powershell
$SiteUrl  = 'http://SP01.contoso.com/sites/mysite'
$ListName = 'MyList'

# Get all list items
Get-SPServerListItem -SiteUrl $SiteUrl -ListName $ListName

# Create a new list item
$Data = @{ Title = 'My New Item' }
New-SPServerListItem -SiteUrl $SiteUrl -ListName $ListName -Property $Data

# Update an existing item
$Data = @{ Title = 'My Updated Item' }
Set-SPServerListItem -SiteUrl $SiteUrl -ListName $ListName -ItemId 1 -Property $Data

# Remove an existing item
Remove-SPServerListItem -SiteUrl $SiteUrl -ListName $ListName -ItemId 1
```

## Versions

Please find all versions in the [GitHub Releases] section and the release notes
in the [CHANGELOG.md] file.

## Installation

Use the following command to install the module from the [PowerShell Gallery],
if the PackageManagement and PowerShellGet modules are available:

```powershell
# Download and install the module
Install-Module -Name 'SharePointFever'
```

Alternatively, download the latest release from GitHub and install the module
manually on your local system:

1. Download the latest release from GitHub as a ZIP file: [GitHub Releases]
2. Extract the module and install it: [Installing a PowerShell Module]

## Requirements

The following minimum requirements are necessary to use this module, or in other
words are used to test this module:

* Windows PowerShell 5.1
* Windows 10
* SharePoint Server 2010 or SharePoint Online

## Contribute

Please feel free to contribute by opening new issues or providing pull requests.
For the best development experience, open this project as a folder in Visual
Studio Code and ensure that the PowerShell extension is installed.

* [Visual Studio Code] with the [PowerShell Extension]
* [Pester], [PSScriptAnalyzer] and [psake] PowerShell Modules



[PowerShell Gallery]: https://www.powershellgallery.com/packages/SharePointFever
[GitHub Releases]: https://github.com/claudiospizzi/SharePointFever/releases
[Installing a PowerShell Module]: https://msdn.microsoft.com/en-us/library/dd878350

[CHANGELOG.md]: CHANGELOG.md

[Visual Studio Code]: https://code.visualstudio.com/
[PowerShell Extension]: https://marketplace.visualstudio.com/items?itemName=ms-vscode.PowerShell
[Pester]: https://www.powershellgallery.com/packages/Pester
[PSScriptAnalyzer]: https://www.powershellgallery.com/packages/PSScriptAnalyzer
[psake]: https://www.powershellgallery.com/packages/psake
