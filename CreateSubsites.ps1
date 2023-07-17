clear
$SourceSiteURL = "https://t6syv.sharepoint.com/sites/MOH3"
$sourceConn = Connect-PnPOnline -Url $SourceSiteURL -useweblogin -ReturnConnection
$desConn = Connect-PnPOnline -Url "https://t6syv.sharepoint.com/sites/CopySitePermission" -useweblogin -ReturnConnection
#New-PnPWeb -Url "NewSsite" -Title "NewSsite" -Template "SITEPAGEPUBLISHING#0" -InheritNavigation -BreakInheritance -Connection $desConn

$SubSites = @("NewSsite","ddddddddddd")
foreach ($SubSite in $SubSites) {
    Write-Host "Copying sub-site $SubSiteTitle ($SubSiteURL)..."
    New-PnPWeb -Url $SubSite -Title $SubSite -Template "SITEPAGEPUBLISHING#0" -InheritNavigation -BreakInheritance -Connection $desConn
    Write-Host $SubSiteURL
}