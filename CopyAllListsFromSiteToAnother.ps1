clear
#Parameters
$SourceSiteURL = "https://t6syv.sharepoint.com/sites/EsraaTeamSite"
$DestinationSiteURL = "https://t6syv.sharepoint.com/sites/LastTeam"

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
Copy-PnPAllLists -SourceSiteURL $SourceSiteURL -DestinationSiteURL $DestinationSiteURL   