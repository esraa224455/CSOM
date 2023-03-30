#Parameters
$SourceSiteURL = "https://t6syv.sharepoint.com/sites/NewSite"
$DestinationSiteURL = "https://t6syv.sharepoint.com/sites/CreationTeamSite"
 
#Connect to the Source Site
Connect-PnPOnline -Url $SourceSiteURL -Interactive
 
#Export all pages from the source
$TempFile = [System.IO.Path]::GetTempFileName()
Get-PnPSiteTemplate -Out $TempFile -Handlers PageContents -IncludeAllClientSidePages -Force
 
#Import the page to the destination site
Connect-PnPOnline -Url $DestinationSiteURL -Interactive
Invoke-PnPSiteTemplate -Path $TempFile


#Read more: https://www.sharepointdiary.com/2020/07/sharepoint-online-copy-pages-to-another-site-using-powershell.html#ixzz7xL55mIel