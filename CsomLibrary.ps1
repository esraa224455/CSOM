Function Copy-PnPAllLibraries
{
    param (
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$SourceSiteURL,
    [parameter(Mandatory=$true, ValueFromPipeline=$true)][string]$DestinationSiteURL
    )
  
    Try {
        #Connect to the Source Site
        $SourceConn = Connect-PnPOnline -URL $SourceSiteURL -Interactive -ReturnConnection
        $SourceCtx = $SourceConn.Context
        $SourceRootWeb = $SourceCtx.Site.RootWeb
        $SourceCtx.Load($SourceRootWeb)
        $SourceCtx.ExecuteQuery()
 
        #Connect to the Destination Site
        $DestinationConn = Connect-PnPOnline -URL $DestinationSiteURL -Interactive -ReturnConnection
        $DestinationCtx = $DestinationConn.Context
        $DestinationRootWeb = $DestinationCtx.Site.RootWeb
        $DestinationCtx.Load($DestinationRootWeb)
        $DestinationCtx.ExecuteQuery()    
  
        #Exclude certain libraries
        $ExcludedLibraries =  @("Style Library","Preservation Hold Library", "Site Pages", "Site Assets","Form Templates", "Site Collection Images","Site Collection Documents")
     
        #Get Libraries from Source site - Skip hidden and certain libraries
        $SourceLibraries =  Get-PnPList -Includes RootFolder -Connection $SourceConn | Where {$_.BaseType -eq "DocumentLibrary" -and $_.Hidden -eq $False -and $_.Title -notin $ExcludedLibraries}
         
        #region PrepareTemplates
        $SourceListTemplates = $SourceCtx.Site.GetCustomListTemplates($SourceRootWeb)
        $SourceCtx.Load($SourceListTemplates)
        $SourceCtx.ExecuteQuery()
        $DestinationListTemplates = $DestinationCtx.Site.GetCustomListTemplates($DestinationRootWeb)
        $DestinationCtx.Load($DestinationListTemplates)
        $DestinationCtx.ExecuteQuery()
 
        #Remove Document Library Templates from source and destination sites
        ForEach($Library in $SourceLibraries)
        {
            $SourceListTemplate = $SourceListTemplates | Where {$_.Name -eq $Library.id.Guid}
            $SourceListTemplateURL = $SourceRootWeb.ServerRelativeUrl+"/_catalogs/lt/"+$Library.id.Guid+".stp"  
  
            #Remove the List template if exists in source   
            If($SourceListTemplate)
            {
                $SourceListTemplateFile = Get-PnPFile -Url $SourceListTemplateURL -Connection $SourceConn
                $SourceListTemplateFile.DeleteObject()
                $SourceCtx.ExecuteQuery()
            }
        }
 
        Write-host "Creating List Templates..." -f Yellow -NoNewline
        #Create Templates
        $SourceLibraries | ForEach-Object {
            $_.SaveAsTemplate($_.id.Guid, $_.id.Guid, [string]::Empty, $False)
            $SourceCtx.ExecuteQuery()
   
            #Copy List Template from source to the destination site
            $SourceListTemplateURL = $SourceRootWeb.ServerRelativeUrl+"/_catalogs/lt/"+$_.id.Guid+".stp"  
            Copy-PnPFile -SourceUrl $SourceListTemplateURL -TargetUrl ($DestinationRootWeb.ServerRelativeUrl+"/_catalogs/lt") -Force -OverwriteIfAlreadyExists
        }
        Write-host "Done!" -f Green
        Start-Sleep 5
 
        #Reload the List Templates in the Destination Site
        $DestinationListTemplates = $DestinationCtx.Site.GetCustomListTemplates($DestinationRootWeb)
        $DestinationCtx.Load($DestinationListTemplates)
        $DestinationCtx.ExecuteQuery()
        #endregion
 
        #Iterate through each library in the source
        ForEach($SourceLibrary in $SourceLibraries)
        {
            Write-host "Copying library:"$SourceLibrary.Title -f Magenta
 
            #Get the Template
            $DestinationListTemplate = $DestinationListTemplates | Where {$_.Name -eq $SourceLibrary.id.Guid}
  
            #Create the destination library from the list template, if it doesn't exist
            Write-host "Creating New Library in the Destination Site..." -f Yellow -NoNewline
            If(!(Get-PnPList -Identity $SourceLibrary.Title -Connection $DestinationConn))
            {
                #Create the destination library
                $ListCreation = New-Object Microsoft.SharePoint.Client.ListCreationInformation
                $ListCreation.Title = $SourceLibrary.Title
                $ListCreation.ListTemplate = $DestinationListTemplate
                $DestinationList = $DestinationCtx.Web.Lists.Add($ListCreation)
                $DestinationCtx.ExecuteQuery()
                Write-host "Library '$($SourceLibrary.Title)' created successfully!" -f Green
            }
            Else
            {
                Write-host "Library '$($SourceLibrary.Title)' already exists!" -f Yellow
            }
 
            Write-host "Copying Files and Folders from the Source to Destination Site..." -f Yellow    
            $DestinationLibrary = Get-PnPList $SourceLibrary.Title -Includes RootFolder -Connection $DestinationConn
            #Copy All Content from Source Library's Root Folder to the Destination Library
            If($SourceLibrary.ItemCount -gt 0)
            {
                #Get All Items from the Root Folder of the Library
                $global:counter = 0
                $ListItems = Get-PnPListItem -List $SourceLibrary.Title -Connection $SourceConn -PageSize 500 -Fields ID -ScriptBlock {Param($items) $global:counter += $items.Count; Write-Progress -PercentComplete `
                    (($global:Counter / $SourceLibrary.ItemCount) * 100) -Activity "Getting Items from List" -Status "Getting Items $global:Counter of $($SourceLibrary.ItemCount)"}
                $RootFolderItems = $ListItems | Where { ($_.FieldValues.FileRef.Substring(0,$_.FieldValues.FileRef.LastIndexOf($_.FieldValues.FileLeafRef)-1)) -eq $SourceLibrary.RootFolder.ServerRelativeUrl}
                Write-Progress -Activity "Completed Getting Items from Library $($SourceLibrary.Title)" -Completed
         
                #Copy Items to the Destination
                $RootFolderItems | ForEach-Object {
                    $DestinationURL = $DestinationLibrary.RootFolder.ServerRelativeUrl
                    Copy-PnPFile -SourceUrl $_.FieldValues.FileRef -TargetUrl $DestinationLibrary.RootFolder.ServerRelativeUrl -Force -OverwriteIfAlreadyExists
                    Write-host "`tCopied $($_.FileSystemObjectType) '$($_.FieldValues.FileRef)' Successfully!" -f Green     
                }
            }
        }
 
        #Cleanup List Templates in source and destination sites
        ForEach($Library in $SourceLibraries)
        {
            $SourceListTemplate = $SourceListTemplates | Where {$_.Name -eq $Library.id.Guid}
            $SourceListTemplateURL = $SourceRootWeb.ServerRelativeUrl+"/_catalogs/lt/"+$Library.id.Guid+".stp"  
  
            #Remove the List template if exists in source   
            If($SourceListTemplate)
            {
                #Remove-PnPFile -ServerRelativeUrl $SourceListTemplateURL -Recycle -Force -Connection $SourceConn
                $SourceListTemplateFile = Get-PnPFile -Url $SourceListTemplateURL -Connection $SourceConn
                $SourceListTemplateFile.DeleteObject()
                $SourceCtx.ExecuteQuery()
            }
            #Remove the List template if exists in target 
            $DestinationListTemplate = $DestinationListTemplates | Where {$_.Name -eq $Library.id.Guid}
            $DestinationListTemplateURL = $DestinationRootWeb.ServerRelativeUrl+"/_catalogs/lt/"+$Library.id.Guid+".stp"
            #Remove the List template if exists    
            If($DestinationListTemplate)
            {
                #Remove-PnPFile -ServerRelativeUrl $DestinationListTemplateURL -Recycle -Force -Connection $DestinationConn
                $DestinationListTemplate = Get-PnPFile -Url $DestinationListTemplateURL -Connection $DestinationConn
                $DestinationListTemplate.DeleteObject()
                $DestinationCtx.ExecuteQuery()        
            }
        }
    }
    Catch {
        write-host -f Red "Error:" $_.Exception.Message
    }
}
 
#Parameters
$SourceSiteURL = "https://t6syv.sharepoint.com/sites/SourceClientSite/Csomlib"
$DestinationSiteURL = "https://t6syv.sharepoint.com/sites/RecordSite/Csomlib"
 
#Call the function to copy libraries to another site
Copy-PnPAllLibraries -SourceSiteURL $SourceSiteURL -DestinationSiteURL $DestinationSiteURL