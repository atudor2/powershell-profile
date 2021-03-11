# http://sharepointjack.com/2017/powershell-script-to-remove-duplicate-old-modules/

write-host "The will report all modules with duplicate (older and newer) versions installed"

$mods = get-installedmodule

foreach ($Mod in $mods)
{
  write-host "Checking $($mod.name)"
  $latest = get-installedmodule $mod.name
  $specificmods = get-installedmodule $mod.name -allversions
  write-host "$($specificmods.count) versions of this module found [ $($mod.name) ]"
 
  foreach ($sm in $specificmods)
  {
     if ($sm.version -eq $latest.version) 
	 { $color = "green"}
	 else
	 { $color = "magenta"}
     write-host " $($sm.name) - $($sm.version) [highest installed is $($latest.version)]" -foregroundcolor $color
	
  }
  write-host "------------------------"
}

write-host "Done"