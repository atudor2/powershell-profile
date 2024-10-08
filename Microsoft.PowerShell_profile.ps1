# PS Core Profile
# Import modules to make PS better:
Import-Module posh-git
Import-Module Terminal-Icons
Import-Module PSReadLine

oh-my-posh init pwsh --config (Join-Path (Split-Path "$PROFILE") .oh-my-posh.omp.json) | Invoke-Expression

Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows

###########################################################################
# Environment Variables:                                                  #
###########################################################################

###########################################################################
# Custom Aliases:                                                         #
###########################################################################
Set-Alias gexps Get-ExplorerPaths;
Set-Alias sexps Set-ExplorerPaths;
Set-Alias ll Get-ChildItem -Force;
Set-Alias gitlog1 Show-GitLog1;
Set-Alias gitlog2 Show-GitLog2;
Set-Alias touch Update-FileWriteTime;

###########################################################################
# Extension Methods                                                       #
###########################################################################
# ToTitleCase()
Update-TypeData -TypeName System.String -MemberType ScriptMethod -MemberName ToTitleCase -Value { (Get-Culture).TextInfo.ToTitleCase($this.ToLower()); }

###########################################################################
# Custom functions:                                                       #
###########################################################################

function Export-GitUserConfig {
    & git config --global --list;    
}

function Update-FileWriteTime {
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

function Show-GitBranchRemoteStatus() {
    & git for-each-ref --format="%(refname:short) %(upstream:track) %(upstream:remotename)" refs/heads;
}

function Show-GitLog1() {
    & git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all;
}

function Show-GitLog2() {
    & git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all;
}
function Close-Ref ($ref) {
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
                Where-Object { $_.LocationURL -ne "" } |
                Select-Object @{ n = "LocationURL"; e = {[System.Uri]$_.LocationURL}} | 
                Select-Object LocationURL, @{ n = "LocationPath"; e = {$_.LocationURL.LocalPath}} | 
                Sort-Object -Property LocationURL | 
                Select-Object  @{ n = "ID" ; e= {(([ref]$i).Value++)} }, LocationURL, LocationPath;

    Close-Ref($app);
    return $paths;
}

function Set-ClipboardToUppercase {
    Get-Clipboard | ForEach-Object { $_.ToString().ToUpper() } | Set-Clipboard;
}

function Get-FullHistoryFile {
    return (Get-PSReadLineOption).HistorySavePath;
}

function Edit-FullHistoryFile {
    code "$(Get-FullHistoryFile)";
}

function Start-HibernateAt {
    Param(
      [Parameter(Mandatory=$true)]
      [System.TimeOnly]$Time
    )
    
    $now = (Get-Date).TimeOfDay;
    $seconds = [int] $Time.ToTimeSpan().Subtract($now).TotalSeconds;

    Write-Output "Hibernation will start at $Time ($seconds seconds)"
    Start-Sleep -Seconds $seconds;
    shutdown.exe /h;
}