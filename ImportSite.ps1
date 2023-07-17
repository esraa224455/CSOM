clear
$SourceSiteURL = "https://t6syv.sharepoint.com/sites/MOH3/ddddddddddd"

$SourceConn = Connect-PnPOnline -Url $SourceSiteURL -Interactive
$Template = "C:\Temp\SiteTemplate4.xml"
 #-Configuration "C:\Temp\Config.json"

Get-PnPSiteTemplate -Out $Template -Connection $SourceConn

$SourceDestinationURL = "https://t6syv.sharepoint.com/sites/EsraaTeamSite/NewSsite"
Connect-PnPOnline -Url $SourceDestinationURL -Interactive

Invoke-PnPSiteTemplate -Path $Template
#Get-PnPProvisioningTemplate