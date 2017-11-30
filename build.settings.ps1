
Properties {

    $ModuleNames = 'SharePointFever'

    $SourceNames = 'SharePointFever'

    $GalleryEnabled = $true
    $GalleryKey     = Get-VaultSecureString -TargetName 'PS-SecureString-GalleryKey'

    $GitHubEnabled  = $true
    $GitHubRepoName = 'claudiospizzi/SharePointFever'
    $GitHubToken    = Get-VaultSecureString -TargetName 'PS-SecureString-GitHubToken'
}
