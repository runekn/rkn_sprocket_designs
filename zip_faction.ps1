param (
    [Parameter(Mandatory=$true, Position = 0)][string[]]$Factions
)

$Decals = @()
foreach ($faction in $Factions)
{
	$folder = "Factions/$($faction)"
	Write-Output "Zipping $($folder)"
	& "C:\Program Files\7-Zip\7z.exe" a -tzip "$($faction).zip" $folder
	
	$Matches = (Select-String -Pattern '"imageURL": ?"Sprocket\/Decals\/((?!").*)"' -Path "$($folder)/Blueprints/Vehicles/*.blueprint").Matches
	foreach ($match in $Matches)
	{
		$decal = $match.Groups[1].Value
		$Decals += $decal
	}
}


foreach ($decal in $Decals)
{
	$file = "Decals/$($decal)"
	Write-Output "Zipping $($file)"
	& "C:\Program Files\7-Zip\7z.exe" a -tzip "decals.zip" $file
}
