#Parameters
$SourceSiteURL = "https://t6syv.sharepoint.com/sites/SourceClientSite/SourceSubSite"
$DestinationSiteURL = "https://t6syv.sharepoint.com/sites/RecordSite/SourceSubSite"

$AdminCenterURL = "https://t6syv-admin.sharepoint.com/"
$SiteTitle = "New225"
$SiteOwner = "DiegoS@t6syv.onmicrosoft.com"
$Template = "SITEPAGEPUBLISHING#0" 
$Timezone = 4

Function Copy-PnPAllLists {
    param (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)][string]$SourceSiteURL,
        [parameter(Mandatory = $true, ValueFromPipeline = $true)][string]$DestinationSiteURL
    )
    Connect-PnPOnline -Url $SourceSiteURL -Interactive
    $SourceLists = Get-PnPList | Where { $_.BaseType -eq "GenericList" -and $_.Hidden -eq $False } | Select Title, Description, ItemCount
     Start-Process $DestinationSiteURL
    ForEach ($SourceList in $SourceLists) {
        #Connect to the Source Site
        Connect-PnPOnline -Url $SourceSiteURL -Interactive
        $ListName = $SourceList.title
        
        $TemplateFile = "$PSScriptRoot\$SiteTitle\Template$ListName.xml"
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
        Write-Host $TemplateFile
    }
}

Function Copy-SPOListItems()
{
    param
    (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)][string]$SourceSiteURL,
        [parameter(Mandatory = $true, ValueFromPipeline = $true)][string]$DestinationSiteURL
    )
    Try {
        Start-Process $DestinationSiteURL
        #Get All Items from the Source List in batches
        Write-Progress -Activity "Reading Source..." -Status "Getting Items from Source List. Please wait..."
        $SourceConn = Connect-PnPOnline -Url $SourceSiteURL -Interactive -ReturnConnection
        $SourceLists = Get-PnPList -Connection $SourceConn | Where { $_.BaseType -eq "GenericList" -and $_.Hidden -eq $False } | Select Title, Description, ItemCount
        $DestinationConn = Connect-PnPOnline -Url $DestinationSiteURL -Interactive -ReturnConnection
        
        ForEach ($SourceList in $SourceLists) {
            $ListName = $SourceList.Title
            $TemplateFile = "$PSScriptRoot\$SiteTitle\Template$ListName.xml"
            Get-PnPSiteTemplate -Out $TemplateFile -ListsToExtract $ListName -Handlers Lists -Connection $SourceConn 
            Invoke-PnPSiteTemplate -Path $TemplateFile -Connection $DestinationConn
            $SourceListItems = Get-PnPListItem -List $ListName -Connection $SourceConn
            $Batch = New-PnPBatch -Connection $DestinationConn
            $SourceListItemsCount= $SourceListItems.count
            Write-host $ListName "Total Number of Items Found:"$SourceListItemsCount     
   
            #Get fields to Update from the Source List - Skip Read only, hidden fields, content type and attachments
            $SourceListFields = Get-PnPField -List $ListName -Connection $SourceConn | Where { (-Not ($_.ReadOnlyField)) -and (-Not ($_.Hidden)) -and ($_.InternalName -ne  "ContentType") -and ($_.InternalName -ne  "Attachments") }
        
            #Loop through each item in the source and Get column values, add them to Destination
            [int]$Counter = 1
            ForEach($SourceItem in $SourceListItems)
            { 
                $ItemValue = @{}
                #Map each field from source list to Destination list
                Foreach($SourceField in $SourceListFields)
                {
                    #Check if the Field value is not Null
                    If($SourceItem[$SourceField.InternalName] -ne $Null)
                    {
                        #Handle Special Fields
                        $FieldType  = $SourceField.TypeAsString                   
   
                        If($FieldType -eq "User" -or $FieldType -eq "UserMulti") #People Picker Field
                        {
                            $PeoplePickerValues = $SourceItem[$SourceField.InternalName] | ForEach-Object { $_.Email}
                            $ItemValue.add($SourceField.InternalName,$PeoplePickerValues)
                        }
                        ElseIf($FieldType -eq "Lookup" -or $FieldType -eq "LookupMulti") # Lookup Field
                        {
                            $LookupIDs = $SourceItem[$SourceField.InternalName] | ForEach-Object { $_.LookupID.ToString()}
                            $ItemValue.add($SourceField.InternalName,$LookupIDs)
                        }
                        ElseIf($FieldType -eq "URL") #Hyperlink
                        {
                            $URL = $SourceItem[$SourceField.InternalName].URL
                            $Description  = $SourceItem[$SourceField.InternalName].Description
                            $ItemValue.add($SourceField.InternalName,"$URL, $Description")
                        }
                        ElseIf($FieldType -eq "TaxonomyFieldType" -or $FieldType -eq "TaxonomyFieldTypeMulti") #MMS
                        {
                            $TermGUIDs = $SourceItem[$SourceField.InternalName] | ForEach-Object { $_.TermGuid.ToString()}                   
                            $ItemValue.add($SourceField.InternalName,$TermGUIDs)
                        }
                        Else
                        {
                            #Get Source Field Value and add to Hashtable                       
                            $ItemValue.add($SourceField.InternalName,$SourceItem[$SourceField.InternalName])
                        }
                    }
                }
                #Copy Created by, Modified by, Created, Modified Metadata values
                #$ItemValue.add("Created", $SourceItem["Created"]);
                #$ItemValue.add("Modified", $SourceItem["Modified"]);
                #$ItemValue.add("Author", $SourceItem["Author"].Email);
                #$ItemValue.add("Editor", $SourceItem["Editor"].Email);
 
                Write-Progress -Activity "Copying List Items:" -Status "Copying Item ID '$($SourceItem.Id)' from Source List ($($Counter) of $($SourceListItemsCount))" -PercentComplete (($Counter / $SourceListItemsCount) * 100)
                $DestinationLists = Get-PnPList -Connection $DestinationConn
                If (($DestinationLists.Title -contains $ListName)) {
                #Copy column value from Source to Destination
                    #Get-PnPList -Identity $ListName -Connection $DestinationConn

                    $NewItem = Add-PnPListItem -List $ListName -Values $ItemValue -Connection $DestinationConn -Batch $Batch
                 }
                 else{
                    Copy-PnPList -Identity $ListName -Connection $SourceConn -DestinationWebUrl $DestinationSiteURL
                    Write-Host "Copied Item ID from Source to Destination List"
                    Write-Host "$ListName Copied Item ID from Source to Destination List"
                    $NewItem = Add-PnPListItem -List $ListName -Values $ItemValue -Connection $DestinationConn -Batch $Batch
                 }
                #Copy Attachments
                Write-Host "Copied Item ID from Source to Destination List:$($SourceItem.Id) ($($Counter) of $($SourceListItemsCount))"
                $Counter++
            }
            Invoke-PnPBatch -Batch $Batch -Connection $DestinationConn
            Write-Host $ListName "Copied" -f Magenta
         
   }}
    Catch {
        Write-host -f Red "Error:" $_.Exception.Message
    }
}

Function Copy-PnPAllLibraries {
    param (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)][string]$SourceSiteURL,
        [parameter(Mandatory = $true, ValueFromPipeline = $true)][string]$DestinationSiteURL
    )
    Start-Process $DestinationSiteURL
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
Function Copy-PnPAllPages {
    param (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)][string]$SourceSiteURL,
        [parameter(Mandatory = $true, ValueFromPipeline = $true)][string]$DestinationSiteURL
    )
    Connect-PnPOnline -Url $SourceSiteURL -UseWebLogin
    Start-Process $DestinationSiteURL
    $Pages = Get-PnPListItem -List SitePages 

    ForEach($Page in $Pages)
        {
            #Get the page name
            $PageName = $Page.FieldValues.FileLeafRef
        
            Write-host "Converting Page:"$PageName
 
            #Check if the page is classic
            If($PageName -eq "Home.aspx")
            {
                Write-host "`tPage is already Exist:"$PageName -f Yellow
            }
            else
            {
               #Connect to Source Site
                Connect-PnPOnline -Url $SourceSiteURL -UseWebLogin
                $PageKey = $Page.FieldValues.FileRef

                Write-Host "Page key: $PageKey"
                #Export the Source page
                $TempFile = [System.IO.Path]::GetTempFileName()
                Export-PnPPage -Force -Identity $PageName -Out $TempFile
 
                #Import the page to the destination site
               $DestinationCon = Connect-PnPOnline -Url $DestinationSiteURL -UseWebLogin
                Invoke-PnPSiteTemplate -Path $TempFile -Connection $DestinationCon
            }
        }
        Remove-Item $TempFile
}

#CreateSite -AdminCenterURL $AdminCenterURL -DestinationSiteURL $DestinationSiteURL  -SiteTitle $SiteTitle -SiteOwner $SiteOwner -Template $Template -Timezone $Timezone 
#$job1 = Start-Job -ScriptBlock { CreateSite -AdminCenterURL $AdminCenterURL -DestinationSiteURL $DestinationSiteURL  -SiteTitle $SiteTitle -SiteOwner $SiteOwner -Template $Template -Timezone $Timezone  }
#Wait-Job $job1
#Copy-PnPAllLists -SourceSiteURL $SourceSiteURL -DestinationSiteURL $DestinationSiteURL
#Copy-SPOListItems -SourceSiteURL $SourceSiteURL -DestinationSiteURL $DestinationSiteURL
Copy-PnPAllLibraries -SourceSiteURL $SourceSiteURL -DestinationSiteURL $DestinationSiteURL
#Copy-PnPAllPages -SourceSiteURL $SourceSiteURL -DestinationSiteURL $DestinationSiteURL