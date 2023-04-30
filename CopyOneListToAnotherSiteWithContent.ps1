Clear-Host
$SourceSiteURL = "https://t6syv.sharepoint.com/sites/EsraaTeamSite"
$TargetSiteURL = "https://t6syv.sharepoint.com/sites/LastNewTeam"

 

$ListName = "Tasks"

$TemplateFile = "$PSScriptRoot\Temp5\Template$ListName.xml"
 
#Connect to the Source Site
Connect-PnPOnline -Url $SourceSiteURL -Interactive

#Create the Template
Get-PnPSiteTemplate -Out $TemplateFile -ListsToExtract $ListName -Handlers Lists

#Get Data from source List
Add-PnPDataRowsToSiteTemplate -Path $TemplateFile -List $ListName 
 
#Connect to Target Site
Connect-PnPOnline -Url $TargetSiteURL -Interactive
 
#Apply the Template
Invoke-PnPSiteTemplate -Path $TemplateFile

