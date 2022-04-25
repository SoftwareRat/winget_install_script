# Install NtObjectManager module
Install-Module NtObjectManager -Force

# Getting links to download packages
$vclibs = Invoke-WebRequest -Uri "https://store.rg-adguard.net/api/GetFiles" -Method "POST" -ContentType "application/x-www-form-urlencoded" -Body "type=PackageFamilyName&url=Microsoft.VCLibs.140.00_8wekyb3d8bbwe&ring=RP&lang=en-US" -UseBasicParsing | Foreach-Object Links | Where-Object outerHTML -match "Microsoft.VCLibs.140.00_.+_x64__8wekyb3d8bbwe.appx" | Foreach-Object href
$vclibsuwp = Invoke-WebRequest -Uri "https://store.rg-adguard.net/api/GetFiles" -Method "POST" -ContentType "application/x-www-form-urlencoded" -Body "type=PackageFamilyName&url=Microsoft.VCLibs.140.00.UWPDesktop_8wekyb3d8bbwe&ring=RP&lang=en-US" -UseBasicParsing | Foreach-Object Links | Where-Object outerHTML -match "Microsoft.VCLibs.140.00.UWPDesktop_.+_x64__8wekyb3d8bbwe.appx" | Foreach-Object href
$winget = ((Invoke-RestMethod "https://api.github.com/repos/microsoft/winget-cli/releases/latest").assets.browser_download_url) -like "*.msixbundle"

# Downloading packages
Invoke-WebRequest $vclibsuwp -OutFile Microsoft.VCLibs.140.00.UWPDesktop_8wekyb3d8bbwe.appx
Invoke-WebRequest $vclibs -OutFile Microsoft.VCLibs.140.00_8wekyb3d8bbwe.appx
Invoke-WebRequest $winget -OutFile Microsoft.VCLibs.140.00_8wekyb3d8bbwe.appx

# Installing packages
Add-AppxPackage -Path .\Microsoft.VCLibs.140.00.UWPDesktop_8wekyb3d8bbwe.appx
Add-AppxPackage -Path .\Microsoft.VCLibs.140.00_8wekyb3d8bbwe.appx
Add-AppxPackage -Path .\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle

# Create reparse point 
$installationPath = (Get-AppxPackage Microsoft.DesktopAppInstaller).InstallLocation
Set-ExecutionAlias -Path "C:\Windows\System32\winget.exe" -PackageName "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe" -EntryPoint "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe!winget" -Target "$installationPath\AppInstallerCLI.exe" -AppType Desktop -Version 3
explorer.exe "shell:appsFolder\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe!winget"