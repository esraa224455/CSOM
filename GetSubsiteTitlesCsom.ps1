Clear-Host
# Load the SharePoint CSOM assemblies
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"

# Set the variables for the site collection URL and credentials
$siteUrl = "https://t6syv.sharepoint.com/sites/MOH3"
$UserName ="DiegoS@t6syv.onmicrosoft.com"
$Password = "PASo8543"
#$credentials = Get-Credential

$sourceCtx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)

$sourceCtx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($UserName,(ConvertTo-SecureString $Password -AsPlainText -Force))

$webs = $sourceCtx.Web.Webs
$sourceCtx.Load($webs)
$sourceCtx.ExecuteQuery()

foreach ($sourceWeb in $webs) {
    $subSiteTitle = $sourceWeb.Title
    $subSiteUrl = $sourceWeb.ServerRelativeUrl
    Write-Host $subSiteTitle
    Write-Host $subSiteUrl
    
}
$sourceCtx.Dispose()
