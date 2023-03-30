#Config Variable
$SiteURL = "https://t6syv.sharepoint.com/sites/NewSite"
  
#Connect to PpP Online
Connect-PnPOnline -Url $SiteURL -Interactive # -Credentials (Get-Credential)
  
#Create new page
$Page = Add-PnPPage -Name "News" -LayoutType Article
 
#Set Page properties
Set-PnPPage -Identity $Page -Title "News" -CommentsEnabled:$False -HeaderType Default
 
#Add Section to the Page
Add-PnPPageSection -Page $Page -SectionTemplate OneColumn
 
#Add Text to Page
Add-PnPPageTextPart -Page $Page -Text "Welcome To News Portal" -Section 1 -Column 1
 
#Add News web part to the section
Add-PnPPageWebPart -Page $Page -DefaultWebPartType News -Section 1 -Column 1
 
#Add List to Page
Add-PnPPageWebPart -Page $Page -DefaultWebPartType List -Section 1 -Column 1 -WebPartProperties @{ selectedListId = "21b99d39-834f-4991-b5f9-bd095fa0633c"}
 
#Publish the page
$Page.Publish()

