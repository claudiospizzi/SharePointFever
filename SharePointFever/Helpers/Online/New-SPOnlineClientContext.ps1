<#
    .SYNOPSIS
        Get the client context object.

    .DESCRIPTION
        This command will return the client context object created with the
        SharePoint Online Client Components SDK. If no object is available,
        because no connection was found, throw an exception.
#>
function New-SPOnlineClientContext
{
    [CmdletBinding()]
    param ()

    if ([System.String]::IsNullOrEmpty($Script:SharePointUrl) -or [System.String]::IsNullOrEmpty($Script:SharePointCredential))
    {
        throw 'No connection to SharePoint Online available. Use Connect-SPOnline to create a new connection.'
    }
    else
    {
        $clientContext = [Microsoft.SharePoint.Client.ClientContext]::new($Script:SharePointUrl)
        $clientContext.Credentials = [Microsoft.SharePoint.Client.SharePointOnlineCredentials]::new($Script:SharePointCredential.Username, $Script:SharePointCredential.Password)
        Write-Output $clientContext
    }
}
