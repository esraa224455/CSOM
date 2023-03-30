clear
#Parameters
$AdminCenterURL = "https://t6syv-admin.sharepoint.com/"
  
#Connect to PnP
Connect-PnPOnline -Url $AdminCenterURL -Interactive
 
#Get Tenant Settings
Get-PnPTenantSite -Identity "https://t6syv.sharepoint.com/sites/EsraaTeamSite"


