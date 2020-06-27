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
        # Name of the target library for the file upload.
        [Parameter(Mandatory = $true)]
        [System.String]
        $LibraryName,

        # Name of the file(s) to download.
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
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
        foreach ($currentFile in $File)
        {
            $currentPath = Join-Path -Path $Path -ChildPath $currentFile

            try
            {
                $clientContext = New-SPOnlineClientContext

                $fileInfo = [Microsoft.SharePoint.Client.File]::OpenBinaryDirect($clientContext, "/$LibraryName/$currentFile")
                $fileStream = [System.IO.File]::Open($currentPath, [System.IO.FileMode]::Create);
                $fileInfo.Stream.CopyTo($fileStream);
                $fileStream.Close()
                $fileStream.Dispose()
            }
            catch
            {
                Write-Error "Failed to download file '$currentFile' from library '$LibraryName' with error: $_"
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

    # begin
    # {
    #     $clientContext = Get-SPOnlineClientContext
    # }

    # process
    # {
    #     foreach ($currentFile in $File)
    #     {
    #         try
    #         {
    #             $library = $clientContext.Web.Lists.GetByTitle($LibraryName)

    #             try
    #             {


    #                 Write-Verbose "Download file '$currentFile' from library '$LibraryName'"


    #             }
    #             finally
    #             {
    #             }
    #         }
    #         catch
    #         {
    #
    #         }
    #     }
    # }
