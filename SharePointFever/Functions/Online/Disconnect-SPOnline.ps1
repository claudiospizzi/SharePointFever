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

    if ($null -ne $Script:SharePointUrl)
    {
        Write-Verbose "Disconnect from SharePoint Online on $Script:SharePointUrl."

        $Script:SharePointUrl        = $null
        $Script:SharePointCredential = $null
    }
}
