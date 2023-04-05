# SharePoint PowerShell - Run Code on your Windows PowerShell ISE
## HardCodeCredentials (You need valid credentials to connect to the SharePoint Online site.)
### To Hard Code Credentials go to file [HardCodeCredentials.ps1](https://github.com/esraa224455/CSOM/blob/master/HardCodeCredentials.ps1)
To avoid credential popups, you can store your credentials in the Windows credentials store and connect to SharePoint Online without a prompt! 
This is extremely useful for unattended PowerShell scripts! Here is how to create a stored credential: Open Control Panel >> Windows credential manager >> Select Windows Credentials >> Click on “Add a new Generic credential” >> Enter the credentials.
I’ve used “CSOM” instead of "SPO"

<img src="https://www.sharepointdiary.com/wp-content/uploads/2021/12/sharepoint-online-powershell-credential-manager.png" width ="600">
change site url & credential name then Run

```
$SiteUrl = "https://t6syv.sharepoint.com/sites/EsraaTeamSite"
$Cred = Get-PnPStoredCredential -Name "CSOM"
```
## To Create New Site
### Open file : [CreateNewSite.ps1](https://github.com/esraa224455/CSOM/blob/master/CreateNewSite.ps1) 
change AdminCenterURL ,SiteURL ,SiteTitle ,SiteOwner ,Template & Timezone then run
```
$AdminCenterURL = "https://t6syv-admin.sharepoint.com/"
$SiteURL = "https://t6syv.sharepoint.com/sites/TeamCopiedSite"
$SiteTitle = "TeamCopiedSite"
$SiteOwner = "AlexW@t6syv.onmicrosoft.com"
$Template = "STS#3" #Modern SharePoint Team Site
$Timezone = 49
```

## To Create List
### Open file : [createList.ps1](https://github.com/esraa224455/CSOM/blob/master/createList.ps1) 
Just change list Name then Run
```
$ListName="NewList"
```
## CRUD On List Items

### To Add New Item Go to file : [AddListItem.ps1](https://github.com/esraa224455/CSOM/blob/master/AddListItem.ps1)
change list Name Titles of columns then Run
```
$ListName="NewList"
$ListItem["Title"] = "Darwin"
 
$ListItem["Department"] = "Eng" 
$ListItem["Location"] = "Egy" 
```
### To Read Items of List Go to file : [ReadItemsOfList.ps1](https://github.com/esraa224455/CSOM/blob/master/ReadItemsOfList.ps1)
change list Name & Titles of columns then Run
```
$ListName="NewList"

ForEach($Item in $ListItems)
{
    Write-Host ("List Item ID:{0} - Title:{1}" -f $Item["ID"], $Item["Title"])
}
```
### To Update List Items Go to file : [UpdateListItems.ps1](https://github.com/esraa224455/CSOM/blob/master/UpdateListItems.ps1)
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
### To Copy Site To Another Site Go to file :[CopySiteToAnotherSite.ps1](https://github.com/esraa224455/CSOM/blob/master/CopySiteToAnotherSite.ps1)
change  SourceSiteURL , DestinationSiteURL, AdminCenterURL ,SiteTitle ,SiteOwner ,Template & Timezone then run
```
$SourceSiteURL = "https://t6syv.sharepoint.com/sites/EsraaTeamSite"
$DestinationSiteURL = "https://t6syv.sharepoint.com/sites/TeamCopiedSite"
$AdminCenterURL = "https://t6syv-admin.sharepoint.com/"
$SiteTitle = "TeamCopiedSite"
$SiteOwner = "AlexW@t6syv.onmicrosoft.com"
$Template = "STS#3" #Modern SharePoint Team Site
$Timezone = 49
```

And in Function  Copy-PnPAllLists change Template File path with the path you want to save in 
```
$TemplateFile = "$env:TEMP\Template$ListName.xml"
```
### To Import Site Template to another Site Url Go to file :[ImportSite.ps1](https://github.com/esraa224455/CSOM/blob/master/ImportSite.ps1)
change  SourceSiteURL , DestinationSiteURL &  Template 
```
$SourceSiteURL = "https://t6syv.sharepoint.com/sites/EsraaTeamSite"
$Template = "C:\Temp\SiteTemplate1.xml"
$SourceDestinationURL = "https://t6syv.sharepoint.com/sites/TestCopyTeamSite"
```

### To Copy One List To Another Site With Content Go to file : [CopyOneListToAnotherSiteWithContent.ps1](https://github.com/esraa224455/CSOM/blob/master/CopyOneListToAnotherSiteWithContent.ps1)
change  SourceSiteURL & TargetSiteURL & list Name then Run
```
$SourceSiteURL = "https://t6syv.sharepoint.com/sites/EsraaTeamSite"
$TargetSiteURL = "https://t6syv.sharepoint.com/sites/DestinationTeamSite"
$ListName= "Projects"
```
### To Copy All Lists From Site To Another Go to file : [CopyAllListsFromSiteToAnother.ps1](https://github.com/esraa224455/CSOM/blob/master/CopyAllListsFromSiteToAnother.ps1)
change  SourceSiteURL & TargetSiteURL then Run
```
$SourceSiteURL = "https://t6syv.sharepoint.com/sites/EsraaTeamSite"
$TargetSiteURL = "https://t6syv.sharepoint.com/sites/DestinationTeamSite"
```
### To Copy All Libraries Another Site Go to file : [CopyAllLibrariesToAnotherSite.ps1](https://github.com/esraa224455/CSOM/blob/master/CopyAllLibrariesToAnotherSite.ps1)
change  SourceSiteURL & TargetSiteURL then Run
```
$SourceSiteURL = "https://t6syv.sharepoint.com/sites/EsraaTeamSite"
$DestinationSiteURL = "https://t6syv.sharepoint.com/sites/DestinationTeamSite"
```
