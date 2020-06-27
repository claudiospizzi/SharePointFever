<#
    .SYNOPSIS
        Disconnect from the SharePoint Online tenant.

    .DESCRIPTION
        Dispose the existing connection to the SharePoint Online tenant.
#>
function Disconnect-SPOnline
{
    [CmdletBinding()]
    param ()

    $Script:SharePointUrl        = $null
    $Script:SharePointCredential = $null
}
