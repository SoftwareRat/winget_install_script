# Specify script that it require at least elevated PowerShell 5.1 
#Requires -RunAsAdministrator
#Requires -Version 5.1

# Checking if the Windows version is compatible with WinGet
## Checking if Windows version is Windows 10 or higher (Windows 11 currently use MajorNumber "10" also)
IF (($PSVersionTable.BuildVersion.Major) -eq "10") {
    IF (!($PSVersionTable.BuildVersion.Build) -ge "17763") {
        Write-Error -Message "Your Windows version is not supported" -RecommendedAction "Please upgrade your Windows version to Windows 10, version 1809 or higher"
        Pause
        throw "Windows version not supported"
    } elseif (!($PSVersionTable.BuildVersion.Major) -ge "11") {
        Write-Error -Message "Your Windows version is not supported" -RecommendedAction "Please upgrade your Windows version to Windows 10, version 1809 or higher"
        Pause
        throw "Windows version not supported"
    }
} else {
    Write-Error -Message "Your Windows version is not supported" -RecommendedAction "Please upgrade your Windows version to Windows 10, version 1809 or higher"
    Pause
    throw "Windows version not supported"
}

# Getting current process
$ProcessName = ([System.Diagnostics.Process]::GetCurrentProcess().ProcessName)
$ExeString = ".exe"
$ExcludeProcess = ($ProcessName,$ExeString -join(''))

# Addressing Microsoft Defender Antivirus blocking NtObjectManager (https://github.com/SoftwareRat/winget_install_script/issues/1)
## Checking is Microsoft Defender Antivirus is enabled
IF ((Get-MpComputerStatus).AntivirusEnabled) {
    # Microsoft Defender Antivirus is enabled, temporary whitelisting PowerShell process
    Add-MpPreference -ExclusionProcess $ExcludeProcess
}

# Install NtObjectManager module if not installed
if (!(Get-Module -ListAvailable -Name NtObjectManager)) {
Set-PSRepository -Name "PSGallery" -InstallationPolicy 'Trusted'
Install-PackageProvider -Name "NuGet" -Force
Set-PSRepository "PSGallery" -InstallationPolicy Trusted
Install-Module -Name 'NtObjectManager' -Force -Confirm:$False}

# Getting links to download packages
$vclibs = Invoke-WebRequest -Uri "https://store.rg-adguard.net/api/GetFiles" -Method "POST" -ContentType "application/x-www-form-urlencoded" -Body "type=PackageFamilyName&url=Microsoft.VCLibs.140.00_8wekyb3d8bbwe&ring=RP&lang=en-US" -UseBasicParsing | Foreach-Object Links | Where-Object outerHTML -match "Microsoft.VCLibs.140.00_.+_x64__8wekyb3d8bbwe.appx" | Foreach-Object href
$vclibsuwp = Invoke-WebRequest -Uri "https://store.rg-adguard.net/api/GetFiles" -Method "POST" -ContentType "application/x-www-form-urlencoded" -Body "type=PackageFamilyName&url=Microsoft.VCLibs.140.00.UWPDesktop_8wekyb3d8bbwe&ring=RP&lang=en-US" -UseBasicParsing | Foreach-Object Links | Where-Object outerHTML -match "Microsoft.VCLibs.140.00.UWPDesktop_.+_x64__8wekyb3d8bbwe.appx" | Foreach-Object href
$winget = ((Invoke-RestMethod 'https://api.github.com/repos/microsoft/winget-cli/releases/latest').assets.browser_download_url) -like "*.msixbundle"
$UIxaml = (Invoke-WebRequest -Uri "https://store.rg-adguard.net/api/GetFiles" -Method "POST" -ContentType "application/x-www-form-urlencoded" -Body "type=PackageFamilyName&url=Microsoft.UI.Xaml.2.7_8wekyb3d8bbwe&ring=RP&lang=en-US" -UseBasicParsing | Foreach-Object Links | Where-Object outerHTML -match "Microsoft.UI.Xaml.2.7_.+_x64__8wekyb3d8bbwe.appx" | Foreach-Object href)

# Downloading dependencies
Write-Host -Object "Downloading dependencies..."
Start-BitsTransfer -Source "$vclibs" -Destination $ENV:TEMP\Microsoft.VCLibs.140.00_8wekyb3d8bbwe.appx
Start-BitsTransfer -Source "$vclibsuwp" -Destination $ENV:TEMP\Microsoft.VCLibs.140.00.UWPDesktop_8wekyb3d8bbwe.appx
Start-BitsTransfer -Source "$UIxaml" -Destination $ENV:TEMP\Microsoft.UI.Xaml.2.7_8wekyb3d8bbwe.appx
Write-Host -Object "Downloading winget..."
Start-BitsTransfer -Source "$winget" -Destination $ENV:TEMP\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle

# Installing dependencies
Add-AppxPackage -Path $ENV:TEMP\Microsoft.VCLibs.140.00.UWPDesktop_8wekyb3d8bbwe.appx
Add-AppxPackage -Path $ENV:TEMP\Microsoft.VCLibs.140.00_8wekyb3d8bbwe.appx
Add-AppxPackage -Path $ENV:TEMP\Microsoft.UI.Xaml.2.7_8wekyb3d8bbwe.appx
# Installing winget
Add-AppxPackage -Path $ENV:TEMP\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle

# Create reparse point
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
Import-Module -Name NtObjectManager
$installationPath = (Get-AppxPackage Microsoft.DesktopAppInstaller).InstallLocation
Set-ExecutionAlias -Path "C:\Windows\System32\winget.exe" -PackageName "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe" -EntryPoint "Microsoft.DesktopAppInstaller_8wekyb3d8bbwe!winget" -Target "$installationPath\winget.exe" -AppType Desktop -Version 3
explorer.exe "shell:appsFolder\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe!winget"
Start-Sleep -Seconds 2
Stop-Process -Name explorer*

# Removing downloaded package installers
Remove-Item -Path $ENV:TEMP\*.appx, $ENV:TEMP\*.msixbundle

## Checking is Microsoft Defender Antivirus is enabled
IF ((Get-MpComputerStatus).AntivirusEnabled) {
    # Microsoft Defender Antivirus is enabled, removing temporary whitelisted PowerShell process
    Remove-MpPreference -ExclusionProcess $ExcludeProcess
}
