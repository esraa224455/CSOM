Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"

$siteUrl = "https://t6syv.sharepoint.com/sites/SourceClientSite"
$DestinationURL = "https://t6syv.sharepoint.com/sites/RecordSite"
$UserName ="DiegoS@t6syv.onmicrosoft.com"
$Password = "PASo8543"
 
$sourceCtx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)

$sourceCtx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($UserName,(ConvertTo-SecureString $Password -AsPlainText -Force))

$SubSites = $sourceCtx.Web.Webs
$sourceCtx.Load($SubSites)
$sourceCtx.ExecuteQuery()
#$SubSites = @("First","second")
foreach ($SubSite in $SubSites) {
Try {
    $subSiteTitle = $SubSite.Title
    #Setup the context
    $Context = New-Object Microsoft.SharePoint.Client.ClientContext($DestinationURL)
    
    $Context.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($UserName,(ConvertTo-SecureString $Password -AsPlainText -Force))
    
    $WebSub = New-Object Microsoft.SharePoint.Client.WebCreationInformation
    $WebSub.Title = $subSiteTitle
    $WebSub.WebTemplate = "OFFILE#1" 
    $WebSub.Url = $subSiteTitle
    $SubWeb = $Context.Web.Webs.Add($WebSub)
    $Context.ExecuteQuery()
 
    Write-host $subSiteTitle "Subsite Created Successfully!" -ForegroundColor Green
}
catch {
    write-host "Error: $($_.Exception.Message)" -foregroundcolor Red
}
}