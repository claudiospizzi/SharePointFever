<#
    .SYNOPSIS
    Remove an existing item from a SharePoint list.

    .DESCRIPTION
    This functions uses the SharePoint REST API to remove the specified item
    from the list. There will be no output, if the item was removed
    successfully.

    .PARAMETER SiteUrl
    The url to the target SharePoint site.

    .PARAMETER ListName
    The name of the target SharePoint list.

    .PARAMETER ItemId
    The id of the target SharePoint item to delete.

    .PARAMETER Credential
    Optionally, the credentials for the REST query can be specified.

    .PARAMETER UseDefaultCredentials
    Optionally, the default use credentials can be used for the REST query.

    .INPUTS
    None. No pipeline input defined.

    .OUTPUTS
    None. No pipline output will be provided.

    .EXAMPLE
    C:\> Set-SPServerListItem -SiteUrl 'http://SP01/sites/mysite' -ListName 'List' -ItemId 1
    Remove the specified item from the list.

    .NOTES
    Author     : Claudio Spizzi
    License    : MIT License

    .LINK
    https://github.com/claudiospizzi/SharePointFever
#>

function Remove-SPServerListItem
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [Uri] $SiteUrl,

        [Parameter(Position = 1, Mandatory = $true)]
        [String] $ListName,

        [Parameter(Position = 2, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Int32[]]
        $ItemId,

        [Parameter(Position = 3, Mandatory = $false)]
        [PSCredential]
        $Credential,

        [Parameter(Position = 4, Mandatory = $false)]
        [Switch] $UseDefaultCredentials
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
                Method  = 'Post'
                Uri     = '{0}/_vti_bin/listdata.svc/{1}({2})' -f $SiteUrl.AbsoluteUri.TrimEnd('/'), $ListName, $CurrentItemId
                Headers = @{
                    Accept          = 'application/json; charset=utf-8; odata=verbose'
                    'X-HTTP-Method' = 'DELETE'
                    'If-Match'      = '*'
                }
            }

            if ($PSCmdlet.ShouldProcess($InvokeRestMethodParameter.Uri, 'Invoke'))
            {
                try
                {
                    Invoke-RestMethod @InvokeRestMethodParameter @CredentialParameters -ErrorAction Stop | Out-Null
                }
                catch
                {
                    Write-Error $_.Exception.Message
                }
            }
        }
    }
}
