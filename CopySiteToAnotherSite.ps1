clear
#Parameters
$SourceSiteURL = "https://t6syv.sharepoint.com/sites/MOH3"
$DestinationSiteURL = "https://t6syv.sharepoint.com/sites/CopySite"

$Password = "PASo8543"
$SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
$Cred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $SiteOwner, $SecurePassword
Connect-PnPOnline -Url $SourceSiteURL -Credentials $Cred

$AdminCenterURL = "https://t6syv-admin.sharepoint.com/"
$SiteTitle = "CopySite"
$SiteOwner = "DiegoS@t6syv.onmicrosoft.com"
$Template = "SITEPAGEPUBLISHING#0" #Modern SharePoint Team Site
$Timezone = 49
Function CreateSite {
    param (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)][string]$AdminCenterURL,
        [parameter(Mandatory = $true, ValueFromPipeline = $true)][string]$DestinationSiteURL,
        [parameter(Mandatory = $true, ValueFromPipeline = $true)][string]$SiteTitle,
        [parameter(Mandatory = $true, ValueFromPipeline = $true)][string]$SiteOwner,
        [parameter(Mandatory = $true, ValueFromPipeline = $true)][string]$Template,
        [parameter(Mandatory = $true, ValueFromPipeline = $true)][string]$Timezone

    )
    Try {
        #Connect to Tenant Admin
        Connect-PnPOnline -URL $AdminCenterURL -Interactive
        #Check if site exists already
        $Site = Get-PnPTenantSite | Where { $_.Url -eq $DestinationSiteURL }
   
        If ($Site -eq $null) {
            #sharepoint online pnp powershell create a new team site collection
            New-PnPTenantSite -Url $DestinationSiteURL -Owner $SiteOwner -Title $SiteTitle -Template $Template -TimeZone $TimeZone -RemoveDeletedSite
            write-host "Site Collection $($DestinationSiteURL) Created Successfully!" -foregroundcolor Green
        }
        else {
            write-host "Site $($DestinationSiteURL) exists already!" -foregroundcolor Yellow
        }
    }
    catch {
        write-host "Error: $($_.Exception.Message)" -foregroundcolor Red
   
    }
}
Function Copy-PnPAllLibraries {
    param (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)][string]$SourceSiteURL,
        [parameter(Mandatory = $true, ValueFromPipeline = $true)][string]$DestinationSiteURL
    )
    #Connect to the source Site
    $SourceConn = Connect-PnPOnline -URL $SourceSiteURL -Interactive -ReturnConnection
    $Web = Get-PnPWeb -Connection $SourceConn

    #Get all document libraries
    $SourceLibraries = Get-PnPList -Includes RootFolder -Connection $SourceConn | Where { $_.BaseType -eq "DocumentLibrary" -and $_.Hidden -eq $False }
 
    #Connect to the destination site
    $DestinationConn = Connect-PnPOnline -URL $DestinationSiteURL -Interactive -ReturnConnection
 
    #Get All Lists in the Destination site
    $DestinationLibraries = Get-PnPList -Connection $DestinationConn
 
    ForEach ($SourceLibrary in $SourceLibraries) {
   
        #Check if the library already exists in target
        If (!($DestinationLibraries.Title -contains $SourceLibrary.Title)) {
            #Create a document library
            $NewLibrary = New-PnPList -Title $SourceLibrary.Title -Template DocumentLibrary -Connection $DestinationConn
            Write-host "Document Library '$($SourceLibrary.Title)' created successfully!" -f Green
        }
        else {
            Write-host "Document Library '$($SourceLibrary.Title)' already exists!" -f Yellow
        }
 
        #Get the Destination Library
        $DestinationLibrary = Get-PnPList $SourceLibrary.Title -Includes RootFolder -Connection $DestinationConn
        $SourceLibraryURL = $SourceLibrary.RootFolder.ServerRelativeUrl
        $DestinationLibraryURL = $DestinationLibrary.RootFolder.ServerRelativeUrl
     
        #Calculate Site Relative URL of the Folder
        If ($Web.ServerRelativeURL -eq "/") {
            $FolderSiteRelativeUrl = $SourceLibrary.RootFolder.ServerRelativeUrl
        }
        Else {     
            $FolderSiteRelativeUrl = $SourceLibrary.RootFolder.ServerRelativeUrl.Replace($Web.ServerRelativeURL, [string]::Empty)
        }
 
        #Get All Content from Source Library's Root Folder
        $RootFolderItems = Get-PnPFolderItem -FolderSiteRelativeUrl $FolderSiteRelativeUrl -Connection $SourceConn | Where { ($_.Name -ne "Forms") -and (-Not($_.Name.StartsWith("_"))) }
         
        #Copy Items to the Destination
        $RootFolderItems | ForEach-Object {
            $DestinationURL = $DestinationLibrary.RootFolder.ServerRelativeUrl
            Copy-PnPFile -SourceUrl $_.ServerRelativeUrl -TargetUrl $DestinationLibraryURL -Force #-OverwriteIfAlreadyExists
            Write-host "`tCopied '$($_.ServerRelativeUrl)'" -f Green   
        }   
        Write-host "`tContent Copied from $SourceLibraryURL to  $DestinationLibraryURL Successfully!" -f Cyan
    }
}

Function Copy-PnPAllLists {
    param (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)][string]$SourceSiteURL,
        [parameter(Mandatory = $true, ValueFromPipeline = $true)][string]$DestinationSiteURL
    )
    Connect-PnPOnline -Url $SourceSiteURL -Interactive
    $SourceLists = Get-PnPList | Where { $_.BaseType -eq "GenericList" -and $_.Hidden -eq $False } | Select Title, Description, ItemCount
    ForEach ($SourceList in $SourceLists) {
        #Connect to the Source Site
        Connect-PnPOnline -Url $SourceSiteURL -Interactive
        $ListName = $SourceList.title
        
        $TemplateFile = "$PSScriptRoot\Temp7\Template$ListName.xml"
        Get-PnPSiteTemplate -Out $TemplateFile -ListsToExtract $ListName -Handlers Lists 

        #Get Data from source List
        Add-PnPDataRowsToSiteTemplate -Path $TemplateFile -List $ListName
        $DestConn = Connect-PnPOnline -Url $DestinationSiteURL -Interactive -ReturnConnection
        $DestinationLists = Get-PnPList -Connection $DestConn
        If (($DestinationLists.Title -contains $SourceList.Title)) {
            Connect-PnPOnline -Url $DestinationSiteURL -Interactive
            Remove-PnPList -Identity $ListName -Force
            Write-host "Previous List '$($ListName)'removed successfully!" -f Green
        }  
        #Connect to Target Site
        Connect-PnPOnline -Url $DestinationSiteURL -Interactive
 
        #Apply the Template
        Invoke-PnPSiteTemplate -Path $TemplateFile 
        Write-Host $TemplateFile
    }
}

CreateSite -AdminCenterURL $AdminCenterURL -DestinationSiteURL $DestinationSiteURL  -SiteTitle $SiteTitle -SiteOwner $SiteOwner -Template $Template -Timezone $Timezone 
Start-Sleep -Seconds 10
#Copy-PnPAllLibraries -SourceSiteURL $SourceSiteURL -DestinationSiteURL $DestinationSiteURL   
#Copy-PnPAllLists -SourceSiteURL $SourceSiteURL -DestinationSiteURL $DestinationSiteURL   
