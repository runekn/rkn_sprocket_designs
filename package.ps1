Param(
	[Parameter(Mandatory=$True)][string[]]$Sources,
	[Parameter(Mandatory=$True)]$TargetName
)

$DecalsRegex = [regex]'\"id\": \"asset\",\s+\"data\": \"{\\\"Data\\\":\\\"([^\\]+)'
$DecalsSeen = @{}
New-Item -Path $TargetName -ItemType Directory | Out-Null

$FactionRegex = [regex]'Factions\\(\w+)\\?'

foreach ($Source in $Sources) {
	$Faction = $FactionRegex.Match($Source).Groups[1].Value
	Write-Host "Detected faction $($Faction)"
	if (-not $Faction) {
		Write-Host "Could not detect faction in $($Source)"
		return
	}
	$isWholeFaction = $Source -match 'Factions\\\w+\\?$'
	if ($isWholeFaction) {
		Write-Host "Packaging entire faction"
		New-Item -ItemType Directory -Path "$($TargetName)\Factions" -Force | Out-Null
		Copy-Item $Source -Destination "$($TargetName)\Factions" -Recurse
		$Source = "$($Source)\Blueprints\Vehicles\*.blueprint"
	}
	foreach($file in Get-ChildItem $Source) {
		Write-Host "Checking $($file.FullName)"
		# Get all decals
		$Content = (Get-Content -Path $file.FullName)
		$Decals = $DecalsRegex.Matches($Content)
		Write-Host "Found $($Decals.Count) decal usages"
		foreach ($Match in $Decals) {
			$Decal = $Match.groups[1].Value
			if (-not $DecalsSeen.Contains($Decal)) {
				$DecalsSeen.Add($Decal, $true)
				# Move decal file
				Write-Host "Including decal $($Decal)"
				If (-not (Test-Path "$($TargetName)\Decals")) {
					New-Item -ItemType Directory -Path "$($TargetName)\Decals"
				} 
				Copy-Item "Decals\$($Decal)" -Destination "$($TargetName)\Decals"
			}
		}
		if (-not $isWholeFaction) {
		# Move blueprint file
			$Destination = "$($TargetName)\Factions\$($Faction)\Blueprints\Vehicles"
			If (-not (Test-Path $Destination)) {
				New-Item -ItemType Directory -Path $Destination -Force | Out-Null
				Copy-Item "Factions\$($Faction)\$($Faction).fdef" -Destination "$($TargetName)\Factions\$($Faction)"
			} 
			Copy-Item $file -Destination $Destination
			#Copy-Item "$($file.parent.FullName)\Profiles\$($file.Name)" -Destination $Destination\Profiles
		}
	}
}