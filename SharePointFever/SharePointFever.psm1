<#
    .SYNOPSIS
        Root module file.

    .DESCRIPTION
        The root module file loads all classes, helpers and functions into the
        module context.
#>


## Module loader

# Get and dot source all model classes (internal)
Split-Path -Path $PSCommandPath |
    Get-ChildItem -Filter 'Classes' -Directory |
        Get-ChildItem -Include '*.ps1' -File -Recurse |
            ForEach-Object { . $_.FullName }

# Get and dot source all helper functions (internal)
Split-Path -Path $PSCommandPath |
    Get-ChildItem -Filter 'Helpers' -Directory |
        Get-ChildItem -Include '*.ps1' -File -Recurse |
            ForEach-Object { . $_.FullName }

# Get and dot source all external functions (public)
Split-Path -Path $PSCommandPath |
    Get-ChildItem -Filter 'Functions' -Directory |
        Get-ChildItem -Include '*.ps1' -File -Recurse |
            ForEach-Object { . $_.FullName }


## SharePoint Online library loader

$libraryFiles = 'C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll',
                'C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll'

foreach ($libraryFile in $libraryFiles)
{
    if (Test-Path -Path $libraryFile)
    {
        Add-Type -Path $libraryFile
    }
    else
    {
        throw "Required library file not found. Please install the SharePoint Online Client Components SDK: https://www.microsoft.com/en-us/download/details.aspx?id=42038"
    }
}


## Module Behaviour

Set-StrictMode -Version 'Latest'
$ErrorActionPreference = 'Stop'


## Module Context

$Script:SharePointUrl        = $null
$Script:SharePointCredential = $null
