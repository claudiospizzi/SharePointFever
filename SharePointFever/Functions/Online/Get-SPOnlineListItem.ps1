<#
    .SYNOPSIS
        Get items from a SharePoint Online list.

    .DESCRIPTION
        Use the SharePoint Online Client Components SDK to retrieve the items
        within a list.
#>
function Get-SPOnlineListItem
{
    [CmdletBinding()]
    param
    (
        # Name of the target list for the file upload.
        [Parameter(Mandatory = $true)]
        [System.String]
        $ListName,

        # Name of the fields to return.
        [Parameter(Mandatory = $false)]
        [System.String[]]
        $FieldName,

        # Limit the number of items to retrieve.
        [Parameter(Mandatory = $false)]
        [System.Int32]
        $Limit = [System.Int32]::MaxValue
    )

    try
    {
        $clientContext = New-SPOnlineClientContext

        $library = $clientContext.Web.Lists.GetByTitle($ListName)

        $camlQuery = [Microsoft.SharePoint.Client.CamlQuery]::CreateAllItemsQuery($Limit)
        $items = $library.GetItems($camlQuery)

        $clientContext.Load($items);
        $clientContext.ExecuteQuery();

        foreach ($item in $items)
        {
            Convert-SPOnlineItem -Item $item -FieldName $FieldName
        }
    }
    catch
    {
        Write-Error "Failed to query the list '$ListName' with error: $_"
    }
    finally
    {
        if ($null -ne $clientContext)
        {
            $clientContext.Dispose()
        }
    }
}
