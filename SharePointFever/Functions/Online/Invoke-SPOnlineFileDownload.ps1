<#
    .SYNOPSIS
        Download a file from the SharePoint Online library.

    .DESCRIPTION
        Use the SharePoint Online Client Components SDK to download a file from
        the SharePoint Online library to a local folder.
#>
function Invoke-SPOnlineFileDownload
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = 'InputObject', ValueFromPipeline = $true)]
        [PSTypeName('SharePointFever.Online.Item')]
        [System.Object[]]
        $InputObject,

        # Name of the target library for the file upload.
        [Parameter(Mandatory = $true, ParameterSetName = 'LibraryAndFile')]
        [System.String]
        $LibraryName,

        # Name of the file(s) to download.
        [Parameter(Mandatory = $true, ParameterSetName = 'LibraryAndFile')]
        [System.String[]]
        $File,

        # Local destination path for the file(s).
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path,

        # Overwrite file(s) in the local file system.
        [Parameter(Mandatory = $false)]
        [Switch]
        $Force
    )

    process
    {
        $files = @{}

        if ($PSCmdlet.ParameterSetName -eq 'InputObject')
        {
            foreach ($currentInputObject in $InputObject)
            {
                $remotePath = '/{0}/{1}' -f $currentInputObject.List, $currentInputObject.File
                $localPath  = Join-Path -Path $Path -ChildPath $currentInputObject.File
                $files[$remotePath] = $localPath
            }
        }

        if ($PSCmdlet.ParameterSetName -eq 'LibraryAndFile')
        {
            foreach ($currentFile in $File)
            {
                $remotePath = '/{0}/{1}' -f $LibraryName, $currentFile
                $localPath  = Join-Path -Path $Path -ChildPath $currentFile
                $files[$remotePath] = $localPath
            }
        }

        foreach ($remotePath in $files.Keys)
        {
            $localPath = $files[$remotePath]

            if ($Force.IsPresent -or -not (Test-Path -Path $localPath))
            {
                try
                {
                    $clientContext = New-SPOnlineClientContext

                    Write-Verbose "Download file '$remotePath' on '$Script:SharePointUrl' to '$localPath'."

                    $fileInfo = [Microsoft.SharePoint.Client.File]::OpenBinaryDirect($clientContext, $remotePath)
                    $fileStream = [System.IO.File]::Open($localPath, [System.IO.FileMode]::Create)
                    $fileInfo.Stream.CopyTo($fileStream)
                    $fileStream.Close()
                    $fileStream.Dispose()
                }
                catch
                {
                    Write-Error "Failed to download file '$remotePath' with error: $_"
                }
                finally
                {
                    if ($null -ne $clientContext)
                    {
                        $clientContext.Dispose()
                    }
                }
            }
            else
            {
                Write-Warning "Skip file' $remotePath' on '$Script:SharePointUrl' because it already exists at '$localPath'."
            }
        }
    }
}
