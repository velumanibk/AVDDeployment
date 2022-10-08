Connect-AzAccount
Select-AzSubscription -Subscription "Tollgroup - AVD AUE Non-Prod"
$listofRGNames = @(
    "RG-GIS-AUE-NONPRD-AVDOBJECTS",
    "RG-GIS-AUE-NONPRD-WORKLOAD",
    "RG-GIS-AUE-NONPRD-BUILD",
    "RG-GIS-AUE-NONPRD-STORAGE"
)

$rgLocation = "Australia East"
$masterTemplateLocation = "https://raw.githubusercontent.com/velumanibk/AVDDeployment/Production/ResourceGroup/rgMasterTemplate.json"
$MasterparameterLocation = "https://raw.githubusercontent.com/velumanibk/AVDDeployment/Production/ResourceGroup/rgMasterTemplate.parameters.json"
$Deploymentjsonlocation = "C:\Temp"

if (!(Test-Path -Path $Deploymentjsonlocation)) {

    New-Item -Path c:\ -Name "Temp" -ItemType Directory | Out-Null

}

$listofRGNames | ForEach-Object {

    Write-Host "started creating the resource group $"

    $Jsontempl = (Invoke-WebRequest -Uri $masterTemplateLocation).content | Out-String
    $Jsontempl | Out-File -FilePath "$Deploymentjsonlocation\$_.Template.json"

    $jsonparams = (Invoke-WebRequest -Uri $MasterparameterLocation).content | Out-String
    $psparams = $jsonparams | ConvertFrom-Json

    $psparams.parameters.rgName.value = $_
    $psparams.parameters.rgLocation.value = $rgLocation

    $jsonparamsnew = $psparams | ConvertTo-Json -Depth 32 
    $Jsonparamsnew | Out-File -FilePath "$Deploymentjsonlocation\$_.Template.Parameters.json"

    $deploymenttemplateLocation = "$Deploymentjsonlocation\$_.Template.json"
    $deploymentparamlocation = "$Deploymentjsonlocation\$_.Template.Parameters.json"

    New-AzSubscriptionDeployment -Name $_ -TemplateFile $deploymenttemplateLocation -TemplateParameterFile $deploymentparamlocation -AsJob


}