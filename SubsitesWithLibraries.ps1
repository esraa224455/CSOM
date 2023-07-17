Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"

$siteUrl = "https://t6syv.sharepoint.com/sites/SourceClientSite"
$DestinationURL = "https://t6syv.sharepoint.com/sites/RecordSite"
$UserName ="DiegoS@t6syv.onmicrosoft.com"
$Password = "PASo8543"
 
$sourceCtx = New-Object Microsoft.SharePoint.Client.ClientContext($siteUrl)

$sourceCtx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($UserName,(ConvertTo-SecureString $Password -AsPlainText -Force))

$SubSites = $sourceCtx.Web.Webs
$sourceCtx.Load($SubSites)
$sourceCtx.ExecuteQuery()
#$SubSites = @("First","second")
foreach ($SubSite in $SubSites) {
Try {
    $subSiteTitle = $SubSite.Title
    #Setup the context
    $Context = New-Object Microsoft.SharePoint.Client.ClientContext($DestinationURL)
    
    $Context.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($UserName,(ConvertTo-SecureString $Password -AsPlainText -Force))
    
    $WebSub = New-Object Microsoft.SharePoint.Client.WebCreationInformation
    $WebSub.Title = $subSiteTitle
    $WebSub.WebTemplate = "OFFILE#1" 
    $WebSub.Url = $subSiteTitle
    $SubWeb = $Context.Web.Webs.Add($WebSub)
    $Context.ExecuteQuery()
 
    Write-host $subSiteTitle "Subsite Created Successfully!" -ForegroundColor Green

    $SourceSiteURL = "https://t6syv.sharepoint.com/sites/SourceClientSite/$subSiteTitle"
    $DestinationSiteURL = "https://t6syv.sharepoint.com/sites/RecordSite/$subSiteTitle"
    #Copy-PnPAllLibraries -SourceSiteURL $SourceSiteURL -DestinationSiteURL $DestinationSiteURL
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
    #Start-Process $DestinationSiteURL
    #Connect to the source Site
    $SourceConn = Connect-PnPOnline -URL $SourceSiteURL -UseWebLogin -ReturnConnection
    $Web = Get-PnPWeb -Connection $SourceConn
    $ExcludedLibrary = @("Site Pages")
    #Get all document libraries
    $SourceLibraries = Get-PnPList -Includes RootFolder -Connection $SourceConn | Where { $_.BaseType -eq "DocumentLibrary" -and $_.Hidden -eq $False -and $_.Title -notin $ExcludedLibrary}
 
    #Connect to the destination site
    $DestinationConn = Connect-PnPOnline -URL $DestinationSiteURL -UseWebLogin -ReturnConnection
    
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
        $DestinationLibraryURL = (Get-PnPList $SourceLibrary.Title -Includes RootFolder -Connection $DestinationConn).RootFolder.ServerRelativeUrl
     
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
