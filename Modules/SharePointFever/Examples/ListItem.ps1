
$SiteUrl  = 'http://SP01.contoso.com/sites/mysite'
$ListName = 'MyList'

# Get all list items
Get-SPListItem -SiteUrl $SiteUrl -ListName $ListName

# Create a new list item
$Data = @{ Title = 'My New Item' }
New-SPListItem -SiteUrl $SiteUrl -ListName $ListName -Property $Data

# Update an existing item
$Data = @{ Title = 'My Updated Item' }
Set-SPListItem -SiteUrl $SiteUrl -ListName $ListName -ItemId 1 -Property $Data

# Remove an existing item
Remove-SPListItem -SiteUrl $SiteUrl -ListName $ListName -ItemId 1
