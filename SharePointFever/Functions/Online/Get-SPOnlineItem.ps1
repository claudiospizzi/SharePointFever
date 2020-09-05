<#
    .SYNOPSIS
        Get items from a SharePoint Online list.

    .DESCRIPTION
        Use the SharePoint Online Client Components SDK to retrieve the items
        within a list. By default, all items are returned. By specifing the Id,
        only one item can be returned.
#>
function Get-SPOnlineItem
{
    [CmdletBinding(DefaultParameterSetName = 'All')]
    param
    (
        # Name of the target list to get the items.
        [Parameter(Mandatory = $true)]
        [System.String]
        $ListName,

        # Name of the fields to return.
        [Parameter(Mandatory = $false)]
        [System.String[]]
        $FieldName,

        # Get only one item by id.
        [Parameter(Mandatory = $true, ParameterSetName = 'Id')]
        [System.Int32]
        $Id,

        # Limit the number of items to retrieve.
        [Parameter(Mandatory = $false)]
        [System.Int32]
        $Limit = [System.Int32]::MaxValue
    )

    try
    {
        $clientContext = New-SPOnlineClientContext

        $list = $clientContext.Web.Lists.GetByTitle($ListName)

        if ($PSCmdlet.ParameterSetName -eq 'All')
        {
            $camlQuery = [Microsoft.SharePoint.Client.CamlQuery]::CreateAllItemsQuery($Limit)
            $items = $list.GetItems($camlQuery)

            Write-Verbose "Get all items from list '$ListName' on '$Script:SharePointUrl'."

            $clientContext.Load($items)
            $clientContext.ExecuteQuery()

            foreach ($item in $items)
            {
                Convert-SPOnlineItem -Item $item -ListName $ListName -FieldName $FieldName
            }
        }
        else
        {
            $item = $list.GetItemById($currentInputObject.Id)

            Write-Verbose "Get item with id '$Id' from list '$ListName' on '$Script:SharePointUrl'."

            $clientContext.Load($item)
            $clientContext.ExecuteQuery()

            Convert-SPOnlineItem -Item $item -ListName $ListName -FieldName $FieldName
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
