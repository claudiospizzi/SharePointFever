<#
    .SYNOPSIS
        Convert an SharePoint Online Client Components SDK item to a PowerShell
        object.

    .DESCRIPTION
        Based on the property File_x0020_Size the function decides if it's just
        a simple item or if we have a file attached to the item.
#>
function Convert-SPOnlineItem
{
    [CmdletBinding()]
    param
    (
        # The item to convert.
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Item,

        # Name of the parent list for the item.
        [Parameter(Mandatory = $true)]
        [System.String]
        $ListName,

        # Name of the fields to return.
        [Parameter(Mandatory = $false)]
        [System.String[]]
        $FieldName
    )

    $itemFieldValues = $item.FieldValues

    # Basic field on all items.
    $data = [Ordered] @{
        PSTypeName = 'SharePointFever.Online.Item'
        Id         = $itemFieldValues['ID']
        Title      = $itemFieldValues['Title']
        List       = $ListName
        File       = $null
        Created    = $itemFieldValues['Created'] -as [System.DateTime]
        CreatedBy  = $itemFieldValues['Author']
        Modified   = $itemFieldValues['Modified'] -as [System.DateTime]
        ModifiedBy = $itemFieldValues['Editor']
    }

    # If we have a file, add the full file path itself. But trim the library
    # name at the beginning of the path.
    if ($itemFieldValues.Keys -contains 'File_x0020_Size')
    {
        $data['File'] = $itemFieldValues['FileRef']

        if ($data['File'] -like "/$ListName/*")
        {
            $data['File'] = $data['File'].Substring($ListName.Length + 1)
        }
    }

    # Now try to add all additonal fields. Based on the returned type, handle
    # the value.
    foreach ($currentFieldName in $FieldName)
    {
        if ($itemFieldValues.Keys -contains $currentFieldName -and $data.Keys -notcontains $currentFieldName)
        {
            $itemFieldValue = $itemFieldValues[$currentFieldName]

            if ($itemFieldValue -is [System.Collections.Generic.Dictionary`2[System.String, System.Object]] -and
                $itemFieldValue.Keys -contains '_ObjectType_' -and $itemFieldValue['_ObjectType_'] -eq 'SP.Taxonomy.TaxonomyFieldValue')
            {
                $data[$currentFieldName] = [PSCustomObject] @{
                    PSTypeName = 'SharePointFever.Online.TaxonomyFieldValue'
                    TermGuid   = $itemFieldValue['TermGuid']
                    WssId      = $itemFieldValue['WssId']
                    Label      = $itemFieldValue['Label']
                }
            }
            elseif ($itemFieldValue -is [System.DateTime])
            {
                $data[$currentFieldName] = $itemFieldValue.ToLocalTime()
            }
            else
            {
                $data[$currentFieldName] = $itemFieldValue
            }
        }
    }

    [PSCustomObject] $data
}
