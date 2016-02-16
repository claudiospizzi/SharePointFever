<#
.SYNOPSIS
    Create an item inside an SharePoint list.

.DESCRIPTION
    This functions uses the SharePoint REST API to create a new item inside a
    list. The created object will be returned to the pipeline, including the
    generated id. The default and metadata properties will be truncated from
    the result object.

.PARAMETER SiteUrl
    The url to the target SharePoint site.

.PARAMETER ListName
    The name of the target SharePoint list.

.PARAMETER Property
    A hashtable for the item properties to set.

.PARAMETER Credential
    Optionally, the credentials for the REST query can be specified.

.PARAMETER UseDefaultCredentials
    Optionally, the default use credentials can be used for the REST query.

.INPUTS
    None. No pipeline input defined.

.OUTPUTS
    System.Management.Automation.PSCustomObject. The new item as a custom object.

.EXAMPLE
    C:\> $Property = @{ Title = 'My Demo Item'; Data = 'Test Data' }
    C:\> Get-SPListItem -SiteUrl 'http://SP01/sites/mysite' -ListName 'List' -Property $Property
    Creates a new item and returns the result to the pipeline.

.NOTES
    Author     : Claudio Spizzi
    License    : MIT License

    Tested with SharePoint 2010.

.LINK
    https://github.com/claudiospizzi/Spizzi.SharePoint
#>

function New-SPListItem
{
    [CmdletBinding()]
    param
    (
        [Parameter(Position=0,
                   Mandatory=$true)]
        [Uri] $SiteUrl,

        [Parameter(Position=1,
                   Mandatory=$true)]
        [String] $ListName,

        [Parameter(Position=2,
                   Mandatory=$true)]
        [Hashtable] $Property,

        [Parameter(Position=3,
                   Mandatory=$false)]
        [PSCredential] $Credential,

        [Parameter(Position=4,
                   Mandatory=$false)]
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
        # Define the REST API query parameters
        $InvokeRestMethodParameter = @{
            Method      = 'Post'
            Uri         = '{0}/_vti_bin/listdata.svc/{1}' -f $SiteUrl.AbsoluteUri.TrimEnd('/'), $ListName
            Body        = [System.Text.Encoding]::UTF8.GetBytes(($Property | ConvertTo-Json))
            ContentType = 'application/json; charset=utf-8; odata=verbose'
            Headers     = @{
                Accept      = 'application/json; charset=utf-8; odata=verbose'
            }
        }

        try
        {
            $Result = Invoke-RestMethod @InvokeRestMethodParameter @CredentialParameters -ErrorAction Stop 

            Get-SPListItem -SiteUrl $SiteUrl -ListName $ListName -ItemId $Result.d.Id @CredentialParameters
        }
        catch
        {
            Write-Error $_.Exception.Message
        }
    }
}
