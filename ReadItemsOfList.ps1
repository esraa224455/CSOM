Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
Clear-Host
$SiteUrl = "https://t6syv.sharepoint.com/sites/Newtemplete"

 
$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteUrl)


$ListName = "NewRequest"
$List = $Ctx.Web.Lists.GetByTitle($ListName)
$ListItems = $List.GetItems([Microsoft.SharePoint.Client.CamlQuery]::CreateAllItemsQuery())
$Ctx.Load($ListItems)
$Ctx.ExecuteQuery()

ForEach ($Item in $ListItems) {
    Write-Host ("List Item ID:{0} - Title:{1}" -f $Item["ID"], $Item["Title"])
}

Write-host "Total Number of Items Found in the List:"$ListItems.Count