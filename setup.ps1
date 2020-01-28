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

Write-Output 'Installing modules...';

InstallUpdateModule('posh-git');
InstallUpdateModule('oh-my-posh');

Write-Output 'Overwriting previous profile'
$profileDir = Split-Path -parent $profile;
Get-ChildItem -Path $profileDir -Filter * -Recurse | Where-Object {$_.Fullname -notlike "$profileDir\Modules*" } | Remove-Item -WarningAction Inquire;

Copy-Item * -Destination "$profileDir/" -Recurse -Exclude test,Modules

Write-Output 'Setup complete';