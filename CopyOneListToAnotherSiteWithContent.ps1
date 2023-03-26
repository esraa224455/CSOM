<<<<<<< HEAD
﻿
=======

>>>>>>> e355de3382b277ebc23e52ba38b98a7ace14960f
Clear-Host
$SourceSiteURL = "https://t6syv.sharepoint.com/sites/EsraaTeamSite"
$TargetSiteURL = "https://t6syv.sharepoint.com/sites/DestinationTeamSite"

 

$ListName= "Projects"
$TemplateFile ="$env:TEMP\Template.xml"
 
#Connect to the Source Site
Connect-PnPOnline -Url $SourceSiteURL -Interactive
$SourceLists =  Get-PnPList
#Create the Template
Get-PnPSiteTemplate -Out $TemplateFile -ListsToExtract $ListName -Handlers Lists

#Get Data from source List
Add-PnPDataRowsToSiteTemplate -Path $TemplateFile -List $ListName
 
#Connect to Target Site
Connect-PnPOnline -Url $TargetSiteURL -Interactive
 
#Apply the Template
Invoke-PnPSiteTemplate -Path $TemplateFile
<<<<<<< HEAD


=======
>>>>>>> e355de3382b277ebc23e52ba38b98a7ace14960f
