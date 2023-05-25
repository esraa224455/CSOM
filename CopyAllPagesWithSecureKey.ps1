$SourceSiteURL = "https://t6syv.sharepoint.com/sites/Moh4"
$DestinationSiteURL = "https://t6syv.sharepoint.com/sites/CopySite"

#Connect to the Source Site
Connect-PnPOnline -Url $SourceSiteURL -Interactive

$Pages = Get-PnPListItem -List SitePages 

ForEach($Page in $Pages)
    {
        #Get the page name
        $PageName = $Page.FieldValues.FileLeafRef
        
        Write-host "Converting Page:"$PageName
 
        #Check if the page is classic
        If($PageName -eq "Home.aspx")
        {
            Write-host "`tPage is already Modern:"$PageName -f Yellow
        }
        else
        {
           #Connect to Source Site
            Connect-PnPOnline -Url $SourceSiteURL -Interactive
            $PageKey = $Page.FieldValues.FileRef

            Write-Host "Page key: $PageKey"
            #Export the Source page
            $TempFile = [System.IO.Path]::GetTempFileName()
            Export-PnPPage -Force -Identity $PageName -Out $TempFile
 
            #Import the page to the destination site
            Connect-PnPOnline -Url $DestinationSiteURL -Interactive
            Invoke-PnPSiteTemplate -Path $TempFile
        }
    }
    Remove-Item $TempFile