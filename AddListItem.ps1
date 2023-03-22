Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
Clear-Host
$SiteUrl = "https://t6syv.sharepoint.com/sites/EsraaTeamSite"
$Cred = Get-PnPStoredCredential -Name "CSOM"
 
$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteUrl)

$Ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($cred.UserName,$cred.Password)
 
$ListName="NewList"

#$SiteSecondColumnName="Location"
$List=$Ctx.Web.Lists.GetByTitle($ListName)
  

$ListItemInfo = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation 
$ListItem = $List.AddItem($ListItemInfo)
#$Field = $Web.Fields.GetByTitle($SiteFirstColumnName)   
#$Field = $Web.Fields.GetByTitle($SiteSecondColumnName)

$ListItem["Title"] = "Darwin"
 
$ListItem["Department"] = "Eng" 
$ListItem["Location"] = "Egy" 

$ListItem.Update()




$Ctx.ExecuteQuery()
Write-host -f Green "New Item has been added to the List!"