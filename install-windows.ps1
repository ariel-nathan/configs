Clear-Host

# Check if script is running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Script must be run as administrator"
    Exit
}

### Set ExecutionPolicy ###
$currentPolicy = Get-ExecutionPolicy
if ($currentPolicy -eq "RemoteSigned") {
    # ExecutionPolicy is already set to RemoteSigned
    Write-Output "ExecutionPolicy is already set to RemoteSigned"
    Write-Output ""
} else {
    # Set ExecutionPolicy to RemoteSigned
    Write-Output "Setting ExecutionPolicy to RemoteSigned..."
    Set-ExecutionPolicy RemoteSigned -Force
    Write-Output "ExecutionPolicy set to RemoteSigned"
    Write-Output ""
}

# Install Hasklig Font
$fontPath = "./shared/hasklug-font/Hasklug Nerd Font Complete Mono.otf"
$fontName = (Get-ChildItem $fontPath).BaseName
Copy-Item $fontPath -Destination "C:\Windows\Fonts"
Write-Output "$fontName installed succesfully"
Write-Output ""

# Copy Windows Terminal config
$wingetConfigFile = "./windows/windows-terminal/settings.json"
$wingetConfigDestination = "C:\Users\$env:USERNAME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\"
Copy-Item -Path $wingetConfigFile -Destination $wingetConfigDestination -Force

### Install Winget Packages ###
Write-Output "Attempting to install winget packages..."
Write-Output ""

# Import list of packages from JSON file
$json = Get-Content -Path './software.json' -Raw | ConvertFrom-Json
$packages = $json.windows

# Install packages using winget
foreach ($package in $packages) {
    Write-Output "Trying to install $package..." 
    winget install $package
    Write-Output ""
}

### Setup Oh-My-Posh ###
# Copy Oh-My-Posh config to user folder
$poshConfigFile = "./shared/oh-my-posh/onedarkpro.omp.json"
$poshConfigDestination = "C:\Users\$env:USERNAME\"
Copy-Item -Path $poshConfigFile -Destination $poshConfigDestination -Force
Write-Output "Oh My Posh config copied to user folder"

# Check if the $PROFILE file exists
if (!(Test-Path $PROFILE)) {
    # Create the $PROFILE file
    New-Item -Type File -Path $PROFILE -Force
    Write-Output "Created PowerShell $PROFILE file"
    Write-Output ""
}

# Remove the default init command from the $PROFILE file if installing Oh-My-Posh inserted it
$lines = Get-Content -Path $PROFILE
$lines = $lines | Where-Object { $_ -notmatch "oh-my-posh init pwsh | Invoke-Expression" }
Set-Content -Path $PROFILE -Value $lines

# Add the new init command to the $PROFILE file
Add-Content -Path $PROFILE -Value "oh-my-posh init pwsh --config C:\Users\$env:USERNAME\onedarkpro.omp.json | Invoke-Expression"
Write-Output "Added Oh My Posh init command to PowerShell $PROFILE file"
Write-Output ""

# Source the $PROFILE file
. $PROFILE

### Copy FancyZones config ###
$zonesConfigFile = "./windows/fancy-zones/custom-layouts.json"
$zonesConfigDestination = "C:\Users\$env:USERNAME\AppData\Local\Microsoft\PowerToys\FancyZones\"
Copy-Item -Path $zonesConfigFile -Destination $zonesConfigDestination -Force
Write-Output "FancyZones config copied to user folder"

### Setup Dev Environment ###
Write-Output "Setting up dev environment..."
Write-Output ""

# Install latest node from nvm
Write-Output "Installing latest node..."
nvm install latest

# Set latest node as the installed version
Write-Output "Setting latest node as the installed version..."
nvm use latest

# Install latest yarn
Write-Output "Installing latest yarn..."
npm install -g yarn

### Finish ###
Clear-Host
Write-Output "Installation complete!"
Write-Output "node: "
node --version
Write-Output "npm: "
npm --version
Write-Output "yarn: "
yarn --version
Write-Output ""