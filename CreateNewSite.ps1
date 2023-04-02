Clear-Host
#Define Variables
$AdminCenterURL = "https://t6syv-admin.sharepoint.com/"
$SiteURL = "https://t6syv.sharepoint.com/sites/TeamCopiedSite"
$SiteTitle = "TeamCopiedSite"
$SiteOwner = "AlexW@t6syv.onmicrosoft.com"
$Template = "STS#3" #Modern SharePoint Team Site
$Timezone = 49
  
Try {
    #Connect to Tenant Admin
    Connect-PnPOnline -URL $AdminCenterURL -Interactive
    #Check if site exists already
    $Site = Get-PnPTenantSite | Where { $_.Url -eq $SiteURL }
   
    If ($Site -eq $null) {
        #sharepoint online pnp powershell create a new team site collection
        New-PnPTenantSite -Url $SiteURL -Owner $SiteOwner -Title $SiteTitle -Template $Template -TimeZone $TimeZone -RemoveDeletedSite
        write-host "Site Collection $($SiteURL) Created Successfully!" -foregroundcolor Green
    }
    else {
        write-host "Site $($SiteURL) exists already!" -foregroundcolor Yellow
    }
}
catch {
    write-host "Error: $($_.Exception.Message)" -foregroundcolor Red
   
}