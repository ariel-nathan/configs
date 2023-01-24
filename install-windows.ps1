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
    Write-Output "Attempting to install winget packages..."
} else {
    # Set ExecutionPolicy to RemoteSigned
    Write-Output "Setting ExecutionPolicy to RemoteSigned..."
    Set-ExecutionPolicy RemoteSigned -Force
    Write-Output "ExecutionPolicy  set to RemoteSigned"
    Write-Output "Attempting to install winget packages..."
}

# Install Hasklig Font
$fontPath = "./hasklig-font/Hasklug Nerd Font Complete Mono.otf"
$fontName = (Get-ChildItem $fontPath).BaseName
Copy-Item $fontPath -Destination "C:\Windows\Fonts"
Write-Host "Font $fontName installed succesfully"

# Copy Windows Terminal config
$wingetConfigFile = "./windows-terminal/settings.json"
$wingetConfigDestination = "C:\Users\$env:USERNAME\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\"
Copy-Item -Path $wingetConfigFile -Destination $wingetConfigDestination -Force

### Install Winget Packages ###
# Import list of packages from JSON file
$json = Get-Content -Path './software.json' -Raw | ConvertFrom-Json
$packages = $json.windows

# Install packages using winget
foreach ($package in $packages) {
    Write-Output "Trying to install $package..." 
    winget install $package
}

### Setup Oh-My-Posh ###
# Copy Oh-My-Posh config to user folder
$poshConfigFile = "./oh-my-posh/onedarkpro.omp.json"
$poshConfigDestination = "C:\Users\$env:USERNAME\"
Copy-Item -Path $poshConfigFile -Destination $poshConfigDestination -Force

# Check if the $PROFILE file exists
if (!(Test-Path $PROFILE)) {
    # Create the $PROFILE file
    New-Item -Type File -Path $PROFILE -Force
}

# Remove the default init command from the $PROFILE file if installing Oh-My-Posh inserted it
$lines = Get-Content -Path $PROFILE
$lines = $lines | Where-Object { $_ -notmatch "oh-my-posh init pwsh | Invoke-Expression" }
Set-Content -Path $PROFILE -Value $lines

# Add the new init command to the $PROFILE file
Add-Content -Path $PROFILE -Value "oh-my-posh init pwsh --config C:\Users\$env:USERNAME\onedarkpro.omp.json | Invoke-Expression"

# Source the $PROFILE file
. $PROFILE

### Setup Dev Environment ###
# Install latest node from nvm
nvm install latest

# Set latest node as the installed version
nvm use latest

# Install latest yarn
npm install -g yarn