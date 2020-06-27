<#
    .SYNOPSIS
        Update a file to the SharePoint Online library.

    .DESCRIPTION
        Use the SharePoint Online Client Components SDK to upload a local file
        into the SharePoint Online library.
#>
function Invoke-SPOnlineFileUpload
{
    [CmdletBinding()]
    param
    (
        # Name of the target library for the file upload.
        [Parameter(Mandatory = $true)]
        [System.String]
        $LibraryName,

        # Path to the files to upload.
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("PSPath")]
        [ValidateScript({Test-Path -Path $_})]
        [System.String[]]
        $Path,

        # Overwrite file in the target library.
        [Parameter(Mandatory = $false)]
        [Switch]
        $Force,

        # Return the created file as item.
        [Parameter(Mandatory = $false)]
        [Switch]
        $PassThru
    )

    process
    {
        foreach ($currentPath in $Path)
        {
            try
            {
                $clientContext = New-SPOnlineClientContext

                $library = $clientContext.Web.Lists.GetByTitle($LibraryName)

                try
                {
                    # Open a stream to the file, the stream is used to read the
                    # file content.
                    $fileStream = ([System.IO.FileInfo]::new($currentPath)).OpenRead()

                    $filePath = Split-Path -Path $currentPath -Leaf

                    # Local object with the upload definition.
                    $fileInfo = [Microsoft.SharePoint.Client.FileCreationInformation]::new()
                    $fileInfo.Overwrite = $Force.IsPresent
                    $fileInfo.ContentStream = $fileStream
                    $fileInfo.URL = $filePath

                    # Add the file to the root of the library. This uploaded
                    # object is then used with the client conext.
                    $fileUploader = $library.RootFolder.Files.Add($fileInfo)
                    $clientContext.Load($fileUploader)

                    Write-Verbose "Upload file '$currentPath' to library '$LibraryName'"

                    # Here we really upload the file itself.
                    $clientContext.ExecuteQuery()
                }
                finally
                {
                    if ($null -ne $fileStream)
                    {
                        $fileStream.Close()
                        $fileStream.Dispose()
                    }
                }

                if ($PassThru.IsPresent)
                {
                    Get-SPOnlineListItem -ListName $LibraryName | Where-Object { $_.File -eq "/$LibraryName/$filePath" }
                }
            }
            catch
            {
                Write-Error "Failed to upload file '$currentPath' to library '$LibraryName' with error: $_"
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
