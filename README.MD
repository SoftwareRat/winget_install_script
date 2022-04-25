# Installation script for winget
The script makes installation of winget possible without using the Microsoft Store. Because of this, you can install winget on LTSC Editions of Windows 10 or Windows Server versions. Please be aware that winget can only be installed on 1809 or newer.

## Disclaimer
This project is NOT affiliated with, funded, or in any way associated with Microsoft.

## Installation
Open Windows PowerShell as Administrator and put this:

```powershell
Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://t1p.de/winget-installer')

# or shorter
iwr -useb 't1p.de/winget-installer' | iex
```
## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.
