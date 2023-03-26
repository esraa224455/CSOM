
Clear-Host
$SourceSiteURL = "https://t6syv.sharepoint.com/sites/EsraaTeamSite"
$TargetSiteURL = "https://t6syv.sharepoint.com/sites/DestinationTeamSite"

 


#$TemplateFile ="$env:TEMP\Template.xml" 
 
#Connect to the Source Site
Connect-PnPOnline -Url $SourceSiteURL -Interactive
$SourceLists =  Get-PnPList | Where {$_.BaseType -eq "GenericList" -and $_.Hidden -eq $False} | Select Title, Description, ItemCount
ForEach($SourceList in $SourceLists)
{
Connect-PnPOnline -Url $SourceSiteURL -Interactive
$TemplateFile ="$env:TEMP\Template.xml" 
 
#Connect to the Source Site

$ListName= $SourceList.title
#Create the Template
Get-PnPSiteTemplate -Out $TemplateFile -ListsToExtract $ListName -Handlers Lists

#Get Data from source List
Add-PnPDataRowsToSiteTemplate -Path $TemplateFile -List $ListName 
#Connect to Target Site
Connect-PnPOnline -Url $TargetSiteURL -Interactive
 
#Apply the Template
Invoke-PnPSiteTemplate -Path $TemplateFile
 }