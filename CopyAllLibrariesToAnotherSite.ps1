﻿clear
#Parameters
$SourceSiteURL = "https://t6syv.sharepoint.com/sites/EsraaTeamSite"
$DestinationSiteURL = "https://t6syv.sharepoint.com/sites/TestCopyTeamSite"
 
#Connect to the source Site
$SourceConn = Connect-PnPOnline -URL $SourceSiteURL -Interactive -ReturnConnection
$Web = Get-PnPWeb -Connection $SourceConn
#$ExcludedLibraries =  @("Style Library","Preservation Hold Library", "Site Pages", "Site Assets","Form Templates", "Site Collection Images","Site Collection Documents")
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

