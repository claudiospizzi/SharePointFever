<#
    .SYNOPSIS
        Set properties on a SharePoint Online list item.

    .DESCRIPTION
        Use the object received by the Get-SPOnlineItem command and set the
        properties specified by the hash table.
#>
function Set-SPOnlineItem
{
    [CmdletBinding()]
    param
    (
        # The item object to update.
        [Parameter(Mandatory = $true, ParameterSetName = 'InputObject', ValueFromPipeline = $true)]
        [PSTypeName('SharePointFever.Online.Item')]
        [System.Object[]]
        $InputObject,

        # Properties to set on the target item.
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $Property
    )

    process
    {
        foreach ($currentInputObject in $InputObject)
        {
            try
            {
                $clientContext = New-SPOnlineClientContext

                $list = $clientContext.Web.Lists.GetByTitle($currentInputObject.List)

                $item = $list.GetItemById($currentInputObject.Id)

                foreach ($propertyName in $Property.Keys)
                {
                    $propertyValue = $Property[$propertyName]

                    switch ($propertyValue)
                    {
                        # { $propertyValue -is [string] }
                        # {
                        #     throw
                        # }

                        default
                        {
                            $item[$propertyName] = $propertyValue
                        }
                    }
                }

                Write-Verbose "Update item with id '$($currentInputObject.Id)' in list '$($currentInputObject.List)' on '$Script:SharePointUrl'."

                $item.Update()
                $clientContext.ExecuteQuery()
            }
            catch
            {
                Write-Error "Failed to update the item '$($currentInputObject.Id)' with error: $_"
            }
            finally
            {
                if ($null -ne $clientContext)
                {
                    $clientContext.Dispose()
                }
            }
        }
    }
}
