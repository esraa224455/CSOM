Clear-Host
$SourceSiteURL = "https://t6syv.sharepoint.com/sites/EsraaTeamSite"
$TargetSiteURL = "https://hajrnd.sharepoint.com/sites/Library"

 

$ListName = "Countries"

$TemplateFile = "$PSScriptRoot\Tempmeen\Template$ListName.xml"
 
#Connect to the Source Site
Connect-PnPOnline -Url $SourceSiteURL -Interactive

#Create the Template
Get-PnPSiteTemplate -Out $TemplateFile -ListsToExtract $ListName -Handlers Lists

#Get Data from source List
Add-PnPDataRowsToSiteTemplate -Path $TemplateFile -List $ListName 
 
#Connect to Target Site
Connect-PnPOnline -Url $TargetSiteURL -credentials
 
#Apply the Template
Invoke-PnPSiteTemplate -Path $TemplateFile

