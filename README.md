# SharePoint PowerShell - Run Code on your Windows PowerShell ISE
## HardCodeCredentials (You need valid credentials to connect to the SharePoint Online site.)
### To Hard Code Credentials go to file [HardCodeCredentials.ps1](https://github.com/esraa224455/CSOM/blob/master/HardCodeCredentials.ps1)
To avoid credential popups, you can store your credentials in the Windows credentials store and connect to SharePoint Online without a prompt! 
This is extremely useful for unattended PowerShell scripts! Here is how to create a stored credential: Open Control Panel >> Windows credential manager >> Select Windows Credentials >> Click on “Add a new Generic credential” >> Enter the credentials.
I’ve used “CSOM” instead of "SPO"as the credential name here.

<img src="https://www.sharepointdiary.com/wp-content/uploads/2021/12/sharepoint-online-powershell-credential-manager.png" width ="600">
change site url & credential name then Run

```
$SiteUrl = "https://t6syv.sharepoint.com/sites/EsraaTeamSite"
$Cred = Get-PnPStoredCredential -Name "CSOM"
```

## To Create List
### Open file : [createList.ps1](https://github.com/esraa224455/CSOM/blob/master/createList.ps1) 
Just change list Name then Run
```
$ListName="NewList"
```
## CRUD On List Items

### To Add New Item Go to file : [AddListItem.ps1](https://github.com/esraa224455/CSOM/blob/master/AddListItem.ps1)
Just change list Name then Run
```
$ListName="NewList"
```
### To Add Read Items of List Go to file : [ReadItemsOfList.ps1](https://github.com/esraa224455/CSOM/blob/master/ReadItemsOfList.ps1)
change list Name & Titles of columns then Run
```
$ListName="NewList"

ForEach($Item in $ListItems)
{
    Write-Host ("List Item ID:{0} - Title:{1}" -f $Item["ID"], $Item["Title"])
}
```
### To Add Update List Items Go to file : [UpdateListItems.ps1](https://github.com/esraa224455/CSOM/blob/master/UpdateListItems.ps1)
change list Name , Id Value & select colunm you want to chang it's value give it new value then Run
```
$ListName="Projects"
$ListItem = $List.GetItemById(1) 
$ListItem["Title"] = "Project Esraa" 
```
### To Remove List Item Go to file : [RemoveListItem.ps1](https://github.com/esraa224455/CSOM/blob/master/RemoveListItem.ps1)
change list Name & ItemID with the values of The item that you Want to remove then Run
```
$ListName="NewList"
$ItemID="3"
```
### To Copy One List To Another Site With Content Go to file : [CopyOneListToAnotherSiteWithContent.ps1](https://github.com/esraa224455/CSOM/blob/master/CopyOneListToAnotherSiteWithContent.ps1)
change  SourceSiteURL & TargetSiteURL & list Name remove then Run
```
$SourceSiteURL = "https://t6syv.sharepoint.com/sites/EsraaTeamSite"
$TargetSiteURL = "https://t6syv.sharepoint.com/sites/DestinationTeamSite"
$ListName= "Projects"
```
