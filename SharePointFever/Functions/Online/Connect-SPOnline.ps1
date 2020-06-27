<#
    .SYNOPSIS
        Connect to the SharePoint Online tenant.

    .DESCRIPTION
        Use the SharePoint Online Client Components SDK to connect to the
        SharePoint Online tenant. The connection is stored in the module state.
#>
function Connect-SPOnline
{
    [CmdletBinding()]
    param
    (
        # Url to the SharePoint Online tenant.
        [Parameter(Mandatory = $true)]
        [System.String]
        $Url,

        # Username and password to connect to the tenant.
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Credential
    )

    try
    {
        $Script:SharePointUrl        = $Url
        $Script:SharePointCredential = $Credential

        try
        {
            $clientContext = New-SPOnlineClientContext

            # Invoke a simple query against the root web part.
            $web = $clientContext.Web
            $clientContext.Load($web) # [Func[object, object]] { param($w); $w.Title }
            $clientContext.ExecuteQuery()
        }
        finally
        {
            if ($null -ne $clientContext)
            {
                $clientContext.Dispose()
            }
        }
    }
    catch
    {
        $Script:SharePointUrl        = $null
        $Script:SharePointCredential = $null

        throw "Failed to connect to SharePoint Online on '$Url' with error: $_"
    }
}
