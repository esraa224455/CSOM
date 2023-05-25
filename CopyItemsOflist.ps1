  
#Function to copy list items from one list to another
Function Copy-SPOListItems()
{
    param
    (
        [Parameter(Mandatory=$true)] [Microsoft.SharePoint.Client.List] $SourceList,
        [Parameter(Mandatory=$true)] [Microsoft.SharePoint.Client.List] $DestinationList
    )
    Try {
        #Get All Items from the Source List in batches
        Write-Progress -Activity "Reading Source..." -Status "Getting Items from Source List. Please wait..."
        $SourceListItems = Get-PnPListItem -List $SourceList -PageSize 500 -Connection $SourceConn
        $SourceListItemsCount= $SourceListItems.count
        Write-host "Total Number of Items Found:"$SourceListItemsCount     
   
        #Get fields to Update from the Source List - Skip Read only, hidden fields, content type and attachments
        $SourceListFields = Get-PnPField -List $SourceList -Connection $SourceConn | Where { (-Not ($_.ReadOnlyField)) -and (-Not ($_.Hidden)) -and ($_.InternalName -ne  "ContentType") -and ($_.InternalName -ne  "Attachments") }
 
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
            $ItemValue.add("Created", $SourceItem["Created"]);
            $ItemValue.add("Modified", $SourceItem["Modified"]);
            $ItemValue.add("Author", $SourceItem["Author"].Email);
            $ItemValue.add("Editor", $SourceItem["Editor"].Email);
 
            Write-Progress -Activity "Copying List Items:" -Status "Copying Item ID '$($SourceItem.Id)' from Source List ($($Counter) of $($SourceListItemsCount))" -PercentComplete (($Counter / $SourceListItemsCount) * 100)
             
            #Copy column value from Source to Destination
            $NewItem = Add-PnPListItem -List $DestinationList -Values $ItemValue -Connection $DestinationConn
   
            #Copy Attachments
            
   
            Write-Host "Copied Item ID from Source to Destination List:$($SourceItem.Id) ($($Counter) of $($SourceListItemsCount))"
            $Counter++
        }
   }
    Catch {
        Write-host -f Red "Error:" $_.Exception.Message
    }
}


#Read more: https://www.sharepointdiary.com/2019/05/sharepoint-online-copy-list-items-between-sites-using-powershell.html#ixzz80NCoULWL
   
#Set Parameters
$SourceSiteURL = "https://t6syv.sharepoint.com/sites/EsraaTeamSite"
$SourceListName = "NewTasks"
  
$DestinationSiteURL = "https://t6syv.sharepoint.com/sites/LastNewTeam"
$DestinationListName = "NewTasks"
  
#Connect to Source and destination sites
$SourceConn = Connect-PnPOnline -Url $SourceSiteURL -Interactive -ReturnConnection
$SourceList = Get-PnPList -Identity $SourceListName -Connection $SourceConn
  
$DestinationConn = Connect-PnPOnline -Url $DestinationSiteURL -Interactive -ReturnConnection
$DestinationList = Get-PnPList -Identity $DestinationListName -Connection $DestinationConn
   
#Call the Function to Copy List Items between Lists
Copy-SPOListItems -SourceList $SourceList -DestinationList $DestinationList