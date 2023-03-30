clear
$SourceSiteURL = "https://t6syv.sharepoint.com/sites/EsraaTeamSite"

Connect-PnPOnline -Url $SourceSiteURL -Interactive
$Template = "C:\Temp\SiteTemplate1.xml"

Get-PnPSiteTemplate  -Configuration "C:\Temp\Config.json" -Out $Template

$SourceDestinationURL = "https://t6syv.sharepoint.com/sites/TestCopyTeamSite"
Connect-PnPOnline -Url $SourceDestinationURL -Interactive

Invoke-PnPSiteTemplate -Path $Template