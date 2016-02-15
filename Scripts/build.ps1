
# Definition for build
$Module = 'Spizzi.SharePoint'
$Source = "C:\Projects\$Module"
$Target = "C:\Program Files\WindowsPowerShell\Modules\$Module"

# Create target module folder
New-Item -Path $Target -ItemType Directory | Out-Null

# Copy all module items
Copy-Item -Path "$Source\Examples"     -Destination $Target -Recurse
Copy-Item -Path "$Source\Functions"    -Destination $Target -Recurse
Copy-Item -Path "$Source\Resources"    -Destination $Target -Recurse
Copy-Item -Path "$Source\Tests"        -Destination $Target -Recurse
Copy-Item -Path "$Source\$Module.psd1" -Destination $Target
Copy-Item -Path "$Source\$Module.psm1" -Destination $Target

# Extract module version
$ModuleVersion = (Invoke-Expression -Command (Get-Content -Path "$Target\$Module.psd1" -Raw)).ModuleVersion

# Push appveyor artifacts
Compress-Archive -Path $Target -DestinationPath "$Source\$Module-$ModuleVersion-$env:APPVEYOR_BUILD_VERSION.zip"
Push-AppveyorArtifact -Path "$Source\$Module-$ModuleVersion-$env:APPVEYOR_BUILD_VERSION.zip" -DeploymentName $Module
