Clear-Host
$SourceSiteURL = "https://t6syv.sharepoint.com/sites/MOH4"
$SiteTitle = "MOH4"
$SourceConn = Connect-PnPOnline -Url $SourceSiteURL -Interactive -ReturnConnection
$SourceLists = Get-PnPList -Connection $SourceConn | Where { $_.BaseType -eq "GenericList" -and $_.Hidden -eq $False } | Select Title, Description, ItemCount
        $DestinationConn = Connect-PnPOnline -Url $DestinationSiteURL -Interactive -ReturnConnection
        
        ForEach ($SourceList in $SourceLists) {
        $ListName = $SourceList.Title
        $CSVPath = "$PSScriptRoot\Data$ListName.csv"
        $ListDataCollection= @()
 
        #Connect to PnP Online
        Connect-PnPOnline -Url $SourceSiteURL -Interactive
        $Counter = 0
        $ListItems = Get-PnPListItem -List $ListName -PageSize 2000
 
        #Get all items from list
        $ListItems | ForEach-Object {
                $ListItem  = Get-PnPProperty -ClientObject $_ -Property FieldValuesAsText
                $ListRow = New-Object PSObject
                $Counter++
                
                Get-PnPField -List $ListName| Where { (-Not ($_.ReadOnlyField)) -and (-Not ($_.Hidden)) -and ($_.InternalName -ne  "ContentType") }| ForEach-Object {
                    $ListRow | Add-Member -MemberType NoteProperty -name $_.InternalName -Value $ListItem[$_.InternalName]
                    }
                Write-Progress -PercentComplete ($Counter / $($ListItems.Count)  * 100) -Activity "Exporting $ListName Items..." -Status  "Exporting Item $Counter of $($ListItems.Count)"
                $ListDataCollection += $ListRow
        }
        #Export the result Array to CSV file
        $ListDataCollection | Export-CSV $CSVPath -NoTypeInformation -Encoding UTF8

       
        }