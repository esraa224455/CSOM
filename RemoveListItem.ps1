Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
clear-Host
$SiteUrl = "https://t6syv.sharepoint.com/sites/EsraaTeamSite"
$Cred = Get-PnPStoredCredential -Name "CSOM"
 
$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteUrl)

$Ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($cred.UserName,$cred.Password)
$ListName="NewList"
$ItemID="3"
Function Delete-ListItem()
{
  param
    (
        [Parameter(Mandatory=$true)] [string] $SiteURL,
        [Parameter(Mandatory=$true)] [string] $ListName,
        [Parameter(Mandatory=$true)] [string] $ItemID
    )
 
    Try {

        $List = $Ctx.Web.Lists.GetByTitle($ListName)
        $ListItem = $List.GetItemById($ItemID)
        $ListItem.DeleteObject()
        $Ctx.ExecuteQuery()
 
        Write-Host "List Item Deleted successfully!" -ForegroundColor Green
 
    }
    Catch {
        write-host -f Red "Error Deleting List Item!" $_.Exception.Message
    }
}

Delete-ListItem -SiteURL $SiteURL -ListName $ListName -ItemID $ItemID

