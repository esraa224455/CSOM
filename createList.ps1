Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"

$SiteUrl = "https://t6syv.sharepoint.com/sites/EsraaTeamSite"
$Cred = Get-PnPStoredCredential -Name "CSOM"
 
$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteUrl)

$Ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($cred.UserName,$cred.Password)
 
$ListName="NewList"
$ListCreationInfo = New-Object Microsoft.SharePoint.Client.ListCreationInformation
$ListCreationInfo.Title = $ListName
$ListCreationInfo.TemplateType = 100
$List = $Ctx.Web.Lists.Add($ListCreationInfo)
$List.Description = "Projects List"
$List.Update()
$Ctx.ExecuteQuery()


Write-host $List.Title