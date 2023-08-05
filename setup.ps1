function InstallUpdateModule($moduleName) {

    if (Get-Module -ListAvailable -Name $moduleName) {
        Write-Output "Updating module '$moduleName'";
        Update-Module $moduleName;
    } 
    else {
        Write-Output "Installing module '$moduleName'";
        Install-Module $moduleName;
    }
}

Write-Output 'Setting up oh-my-posh....';
Write-Output 'Removing old Powershell module (if needed)';
# Cleanup old oh-my-posh if needed
Uninstall-Module oh-my-posh -AllVersions;

Write-Output 'Upgrading oh-my-posh';
# Upgrade oh-my-posh if needed
winget upgrade JanDeDobbeleer.OhMyPosh -s winget

Write-Output 'Installing modules...';
Write-Host 'Note: If any errors are raised during install, run Obsolete-Modules.ps1 to check for obsolete modules and uninstall' -foregroundcolor 'magenta'
InstallUpdateModule('posh-git');
InstallUpdateModule('Terminal-Icons');
InstallUpdateModule('PSReadLine');
InstallUpdateModule('Microsoft.WinGet.Client');

Write-Output 'Overwriting previous profile'
$profileDir = Split-Path -parent $profile;
Get-ChildItem -Path $profileDir -Filter * -Recurse | Where-Object { $_.Fullname -notlike "$profileDir\Modules*" } | Remove-Item -WarningAction Inquire;

Copy-Item * -Destination "$profileDir/" -Recurse -Exclude test, Modules

Write-Output 'Setup complete';