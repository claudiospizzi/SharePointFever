<#
    .SYNOPSIS
    Update properties of an existing item inside a SharePoint list.

    .DESCRIPTION
    This functions uses the SharePoint REST API to update existing items with
    new properties. The value of the provided properties will always be
    replaced with the new values.

    .PARAMETER SiteUrl
    The url to the target SharePoint site.

    .PARAMETER ListName
    The name of the target SharePoint list.

    .PARAMETER ItemId
    The id of the target SharePoint item to update.

    .PARAMETER Property
    A hashtable for the item properties to update.

    .PARAMETER Credential
    Optionally, the credentials for the REST query can be specified.

    .PARAMETER UseDefaultCredentials
    Optionally, the default use credentials can be used for the REST query.

    .INPUTS
    None. No pipeline input defined.

    .OUTPUTS
    System.Management.Automation.PSCustomObject. The updated item as a custom object.

    .EXAMPLE
    C:\> $Property = @{ Data = 'My New Data' }
    C:\> Set-SPServerListItem -SiteUrl 'http://SP01/sites/mysite' -ListName 'List' -ItemId 1 -Property $Property
    Updates the specified item and returns the result to the pipeline.

    .NOTES
    Author     : Claudio Spizzi
    License    : MIT License

    .LINK
    https://github.com/claudiospizzi/SharePointFever
#>

function Set-SPServerListItem
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [Uri]
        $SiteUrl,

        [Parameter(Position = 1, Mandatory = $true)]
        [String]
        $ListName,

        [Parameter(Position = 2, Mandatory = $true)]
        [Int32[]]
        $ItemId,

        [Parameter(Position = 3, Mandatory = $true)]
        [Hashtable]
        $Property,

        [Parameter(Position = 4, Mandatory = $false)]
        [PSCredential]
        $Credential,

        [Parameter(Position = 5, Mandatory = $false)]
        [Switch]
        $UseDefaultCredentials
    )

    begin
    {
        # Define the alternate credentials hash table
        $CredentialParameters = @{}
        if ($Credential -ne $null) { $CredentialParameters['Credential'] = $Credential }
        if ($UseDefaultCredentials.IsPresent) { $CredentialParameters['UseDefaultCredentials'] = $true }
    }

    process
    {
        foreach ($CurrentItemId in $ItemId)
        {
            # Define the REST API query parameters
            $InvokeRestMethodParameter = @{
                Method      = 'Post'
                Uri         = '{0}/_vti_bin/listdata.svc/{1}({2})' -f $SiteUrl.AbsoluteUri.TrimEnd('/'), $ListName, $CurrentItemId
                Body        = [System.Text.Encoding]::UTF8.GetBytes(($Property | ConvertTo-Json))
                ContentType = 'application/json; charset=utf-8; odata=verbose'
                Headers     = @{
                    Accept          = 'application/json; charset=utf-8; odata=verbose'
                    'X-HTTP-Method' = 'MERGE'
                    'If-Match'      = '*'
                }
            }

            if ($PSCmdlet.ShouldProcess($InvokeRestMethodParameter.Uri, 'Invoke'))
            {
                try
                {
                    Invoke-RestMethod @InvokeRestMethodParameter @CredentialParameters -ErrorAction Stop | Out-Null

                    Get-SPServerListItem -SiteUrl $SiteUrl -ListName $ListName -ItemId $CurrentItemId @CredentialParameters
                }
                catch
                {
                    Write-Error $_.Exception.Message
                }
            }
        }
    }
}
