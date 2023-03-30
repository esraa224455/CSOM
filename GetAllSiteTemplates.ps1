clear
#Config Variables
$SiteURL = "https://t6syv.sharepoint.com/"
 
#Connect to PnP Online
Connect-PnPOnline -Url $SiteURL -Interactive
 
#Get the Context & Web Objects
$ClientContext = Get-PnPContext
$Web = Get-PnPWeb
 
#Get All Web Templates
$WebTemplateCollection = $Web.GetAvailableWebTemplates(1033,0)
$ClientContext.Load($WebTemplateCollection)
$ClientContext.ExecuteQuery()
 
#Get the Template Name and Title
$WebTemplateCollection | Select ID, Name, Title