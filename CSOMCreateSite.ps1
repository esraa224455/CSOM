#Load SharePoint CSOM Assemblies
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
Add-Type -Path "C:\Program Files\SharePoint Online Management Shell\Microsoft.Online.SharePoint.PowerShell\Microsoft.Online.SharePoint.Client.Tenant.dll"
  
#Set Parameters
$AdminCenterURL = "https://t6syv-admin.sharepoint.com/"
$NewSiteURL = "https://t6syv.sharepoint.com/sites/CsomSite"
$SiteOwner = "DiegoS@t6syv.onmicrosoft.com"
$SiteTemplate= "SITEPAGEPUBLISHING#0" 
$UserName="DiegoS@t6syv.onmicrosoft.com"
$Password ="PASo8543"

#Setup Credentials to connect
$credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($UserName,(ConvertTo-SecureString $Password -AsPlainText -Force))
#Setup the Context
$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($AdminCenterURL)
$Ctx.Credentials = $credentials
Try {
    #Get the tenant object 
    $Tenant = New-Object Microsoft.Online.SharePoint.TenantAdministration.Tenant($Ctx)
    Write-Host $Tenant
    Write-Host -f Yellow "Creating site collection..."
    #Set the Site Creation Properties
    $SiteCreationProperties = New-Object Microsoft.Online.SharePoint.TenantAdministration.SiteCreationProperties
    $SiteCreationProperties.Url = $NewSiteURL
    $SiteCreationProperties.Template =  "STS#0" #Classic site
    $SiteCreationProperties.Owner = $SiteOwner
    $SiteCreationProperties.StorageMaximumLevel = 1000
    $SiteCreationProperties.UserCodeMaximumLevel = 300
  
    #powershell script to create site collection in sharepoint online
    $Tenant.CreateSite($SiteCreationProperties) | Out-Null
    $ctx.ExecuteQuery()
  
    #Create the site in the tennancy
    write-host "Site Collection Created Successfully!" -foregroundcolor Green
    Start-Process $NewSiteURL
}
catch {
    write-host "Error: $($_.Exception.Message)" -foregroundcolor Red
}