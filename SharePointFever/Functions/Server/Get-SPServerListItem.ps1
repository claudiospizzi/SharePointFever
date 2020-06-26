<#
    .SYNOPSIS
    Get items from a SharePoint list.

    .DESCRIPTION
    This functions uses the SharePoint REST API to query items from a list. The
    default and metadata properties will be truncated from the result object.

    .PARAMETER SiteUrl
    The url to the target SharePoint site.

    .PARAMETER ListName
    The name of the target SharePoint list.

    .PARAMETER ItemId
    Optionally add one or multiple site ids, to filter the output.

    .PARAMETER Credential
    Optionally, the credentials for the REST query can be specified.

    .PARAMETER UseDefaultCredentials
    Optionally, the default use credentials can be used for the REST query.

    .INPUTS
    System.Int32. The item ids can be passed via pipeline.

    .OUTPUTS
    System.Management.Automation.PSCustomObject. The list item as custom object.

    .EXAMPLE
    C:\> Get-SPServerListItem -SiteUrl 'http://SP01/sites/mysite' -ListName 'List'
    Get all items from the demo list.

    .EXAMPLE
    C:\> Get-SPServerListItem -SiteUrl 'http://SP01/sites/mysite' -ListName 'List' -ItemId 1, 2
    Get the items with id 1 and 2 from the demo list.

    .NOTES
    Author     : Claudio Spizzi
    License    : MIT License

    .LINK
    https://github.com/claudiospizzi/SharePointFever
#>

function Get-SPServerListItem
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [Uri]
        $SiteUrl,

        [Parameter(Position = 1, Mandatory = $true)]
        [String] $ListName,

        [Parameter(Position = 2, Mandatory = $false, ValueFromPipeline = $true)]
        [Int32[]]
        $ItemId,

        [Parameter(Position = 3, Mandatory = $false)]
        [PSCredential]
        $Credential,

        [Parameter(Position = 4, Mandatory = $false)]
        [Switch]
        $UseDefaultCredentials
    )

    begin
    {
        # Define the alternate credentials hash table
        $CredentialParameters = @{}
        if ($Credential -ne $null) { $CredentialParameters['Credential'] = $Credential }
        if ($UseDefaultCredentials.IsPresent) { $CredentialParameters['UseDefaultCredentials'] = $true }

        # Defile the include and exclude filters
        $ItemIncludeFilter = '*', @{ N = 'ModifiedBy'; E = { $_.ModifiedBy.Account } }, @{ N = 'CreatedBy'; E = { $_.CreatedBy.Account } }
        $ItemExcludeFilter = '__metadata', 'ContentType', 'ContentTypeID', 'Path', 'OwsHiddenVersion', 'CreatedBy', 'CreatedById', 'ModifiedBy', 'ModifiedById'
    }

    process
    {
        # Define the REST API query parameters
        $InvokeRestMethodParameter = @{
            Method  = 'Get'
            Uri     = '{0}/_vti_bin/listdata.svc/{1}{{0}}?$expand=CreatedBy,ModifiedBy' -f $SiteUrl.AbsoluteUri.TrimEnd('/'), $ListName
            Headers = @{
                Accept = 'application/json; charset=utf-8; odata=verbose'
            }
        }

        # Check if all items or just a some are requested
        if ($PSBoundParameters.ContainsKey('ItemId'))
        {
            foreach ($CurrentItemId in $ItemId)
            {
                # Update the REST API query with target id
                $InvokeRestMethodParameter.Uri = $InvokeRestMethodParameter.Uri -f ('(' + $CurrentItemId + ')')

                try
                {
                    $Result = Invoke-RestMethod @InvokeRestMethodParameter @CredentialParameters -ErrorAction Stop

                    $Result.d |
                        Select-Object -Property $ItemIncludeFilter -ExcludeProperty $ItemExcludeFilter
                }
                catch
                {
                    Write-Error $_.Exception.Message
                }
            }
        }
        else
        {
            # Update the REST API query for all items
            $InvokeRestMethodParameter.Uri = $InvokeRestMethodParameter.Uri -f ''

            try
            {
                $Result = Invoke-RestMethod @InvokeRestMethodParameter @CredentialParameters -ErrorAction Stop

                $Result.d.results |
                    Select-Object -Property $ItemIncludeFilter -ExcludeProperty $ItemExcludeFilter
            }
            catch
            {
                Write-Error $_.Exception.Message
            }
        }
    }
}
