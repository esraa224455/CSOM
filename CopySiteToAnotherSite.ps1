clear
#Parameters
$SourceSiteURL = "https://t6syv.sharepoint.com/sites/EsraaTeamSite"
$DestinationSiteURL = "https://t6syv.sharepoint.com/sites/TeamNewSite"

Function ExportImportSite {
    param (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)][string]$SourceSiteURL,
        [parameter(Mandatory = $true, ValueFromPipeline = $true)][string]$DestinationSiteURL
    )
    Connect-PnPOnline -Url $SourceSiteURL -Interactive
    $Template = "C:\Temp\SiteTemplate1.xml"

    Get-PnPSiteTemplate  -Configuration "C:\Temp\Config.json" -Out $Template

    Connect-PnPOnline -Url $DestinationSiteURL -Interactive

    Invoke-PnPSiteTemplate -Path $Template
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
    $SourceLibraries =  Get-PnPList -Includes RootFolder -Connection $SourceConn | Where {$_.BaseType -eq "DocumentLibrary" -and $_.Hidden -eq $False}
 
    #Connect to the destination site
    $DestinationConn = Connect-PnPOnline -URL $DestinationSiteURL -Interactive -ReturnConnection
 
    #Get All Lists in the Destination site
    $DestinationLibraries = Get-PnPList -Connection $DestinationConn
 
    ForEach($SourceLibrary in $SourceLibraries)
    {
   
        #Check if the library already exists in target
        If(!($DestinationLibraries.Title -contains $SourceLibrary.Title))
        {
            #Create a document library
        
            $NewLibrary  = New-PnPList -Title $SourceLibrary.Title -Template DocumentLibrary -Connection $DestinationConn
            Write-host "Document Library '$($SourceLibrary.Title)' created successfully!" -f Green
        }
        else
        {
            #Remove-PnPList -Identity $SourceLibrary.Title -Force -Recycle -Connection $DestinationConn
            #$NewLibrary  = New-PnPList -Title $SourceLibrary.Title -Template DocumentLibrary -Connection $DestinationConn
            Write-host "Document Library '$($SourceLibrary.Title)' already exists!" -f Yellow
        }
 
        #Get the Destination Library
        $DestinationLibrary = Get-PnPList $SourceLibrary.Title -Includes RootFolder -Connection $DestinationConn
        $SourceLibraryURL = $SourceLibrary.RootFolder.ServerRelativeUrl
        $DestinationLibraryURL = $DestinationLibrary.RootFolder.ServerRelativeUrl
     
        #Calculate Site Relative URL of the Folder
        If($Web.ServerRelativeURL -eq "/")
        {
            $FolderSiteRelativeUrl = $SourceLibrary.RootFolder.ServerRelativeUrl
        }
        Else
        {     
            $FolderSiteRelativeUrl = $SourceLibrary.RootFolder.ServerRelativeUrl.Replace($Web.ServerRelativeURL,[string]::Empty)
        }
 
        #Get All Content from Source Library's Root Folder
        $RootFolderItems = Get-PnPFolderItem -FolderSiteRelativeUrl $FolderSiteRelativeUrl -Connection $SourceConn | Where {($_.Name -ne "Forms") -and (-Not($_.Name.StartsWith("_")))}
         
        #Copy Items to the Destination
        $RootFolderItems | ForEach-Object {
            $DestinationURL = $DestinationLibrary.RootFolder.ServerRelativeUrl
            Copy-PnPFile -SourceUrl $_.ServerRelativeUrl -TargetUrl $DestinationLibraryURL -Force -OverwriteIfAlreadyExists
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
        $TemplateFile = "$env:TEMP\Template$ListName.xml" 

        $ListName = $SourceList.title

        Get-PnPSiteTemplate -Out $TemplateFile -ListsToExtract $ListName -Handlers Lists 

        #Get Data from source List
        Add-PnPDataRowsToSiteTemplate -Path $TemplateFile -List $ListName
        $DestConn = Connect-PnPOnline -Url $DestinationSiteURL -Interactive -ReturnConnection
        $DestinationLists = Get-PnPList -Connection $DestConn
        If(($DestinationLists.Title -contains $SourceList.Title))
        {
            Connect-PnPOnline -Url $DestinationSiteURL -Interactive
            Remove-PnPList -Identity $ListName -Force
            Write-host "Previous List '$($ListName)'removed successfully!" -f Green
        }  
        #Connect to Target Site
        Connect-PnPOnline -Url $DestinationSiteURL -Interactive
 
        #Apply the Template
        Invoke-PnPSiteTemplate -Path $TemplateFile 
    }
}
ExportImportSite -SourceSiteURL $SourceSiteURL -DestinationSiteURL $DestinationSiteURL
Copy-PnPAllLibraries -SourceSiteURL $SourceSiteURL -DestinationSiteURL $DestinationSiteURL   
Copy-PnPAllLists -SourceSiteURL $SourceSiteURL -DestinationSiteURL $DestinationSiteURL   
