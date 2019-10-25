# PS Core Profile
# Import modules to make PS better:
Import-Module posh-git
Import-Module oh-my-posh

# Tweaked version of standard Agnoster
Set-Theme AgnosterV2

# Default to short path view
$AgnosterV2_CustomThemeSettings.UseShortPath = $true

# Turn on Fuck :)
$env:PYTHONIOENCODING="utf-8";
Invoke-Expression "$(thefuck --alias)";

###########################################################################
# Custom Aliases:                                                         #
###########################################################################
Set-Alias gexps Get-ExplorerPaths;
Set-Alias sexps Set-ExplorerPaths;
Set-Alias ll Get-ChildItem -Force;
Set-Alias gitlog1 Show-GitLog1;
Set-Alias gitlog2 Show-GitLog2;

###########################################################################
# Custom functions:                                                       #
###########################################################################
function touch {
    Param(
      [Parameter(Mandatory=$true)]
      [string]$Path
    )
  
    if (Test-Path -LiteralPath $Path) {
      (Get-Item -Path $Path).LastWriteTime = Get-Date
    } else {
      New-Item -Type File -Path $Path
    }
}

function Show-GitLog1() {
    & git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all;
}

function Show-GitLog2() {
    & git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all;
}
function Release-Ref ($ref) {
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject([System.__ComObject]$ref) | out-null
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
}

function Set-ExplorerPaths {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [int]$id    
    )
    Get-ExplorerPaths | Where-Object { $_.ID -eq $id } | Select-Object -Expand LocationPath | Set-Location;
}
function Get-ExplorerPaths() {
    $app = New-Object -COM 'Shell.Application';
    $i = 0;
    $paths = $app.Windows() | 
                Select-Object @{ n = "LocationURL"; e = {[System.Uri]$_.LocationURL}} | 
                Select-Object LocationURL, @{ n = "LocationPath"; e = {$_.LocationURL.LocalPath}} | 
                Sort-Object -Property LocationURL | 
                Select-Object  @{ n = "ID" ; e= {(([ref]$i).Value++)} }, LocationURL, LocationPath;

    Release-Ref($app);
    return $paths;
}