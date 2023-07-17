Clear-HOST
#Parameters
$SourceSiteURL = "https://t6syv.sharepoint.com/sites/EsraaTeamSite"
$DestinationSiteURL = "https://t6syv.sharepoint.com/sites/TestCSVImport"

Function Copy-PnPAllLists {
    param (
        [parameter(Mandatory = $true, ValueFromPipeline = $true)][string]$SourceSiteURL,
        [parameter(Mandatory = $true, ValueFromPipeline = $true)][string]$DestinationSiteURL
    )
    $SourceConn = Connect-PnPOnline -Url $SourceSiteURL -Interactive -ReturnConnection
    $SourceLists = Get-PnPList -Connection $SourceConn | Where { $_.BaseType -eq "GenericList" -and $_.Hidden -eq $False } | Select Title, InternalName, Description, ItemCount
    $DestConn = Connect-PnPOnline -Url $DestinationSiteURL -Interactive -ReturnConnection
    $DestinationLists = Get-PnPList -Connection $DestConn
    ForEach ($SourceList in $SourceLists) {
        #Connect to the Source Site
        $ListName = $SourceList.title
        If($ListName -eq "NewRequest"){
        $TemplateFile = "$PSScriptRoot\Temp7\Template$ListName.xml"
        
        Get-PnPSiteTemplate -Out $TemplateFile -ListsToExtract $ListName -Handlers Lists -Connection $SourceConn
        <# Get-PnPSiteTemplate -Out $TemplateFile -ListsToExtract $ListName -Handlers Lists -Connection $SourceConn#>

        #Get Data from source List
        Add-PnPDataRowsToSiteTemplate -Path $TemplateFile -List $ListName -Connection $SourceConn
        
        If (($DestinationLists.Title -contains $SourceList.Title)) {
            Remove-PnPList -Identity $ListName -Force -Connection $DestConn
            Write-host "Previous List '$($ListName)'removed successfully!" -f Green
        }       
 
        #Apply the Template
        Invoke-PnPSiteTemplate -Path $TemplateFile -Connection $DestConn
        Write-Host $TemplateFile
    
    }
    }
}
Copy-PnPAllLists -SourceSiteURL $SourceSiteURL -DestinationSiteURL $DestinationSiteURL   