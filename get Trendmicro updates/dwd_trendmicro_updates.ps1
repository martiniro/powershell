<#
     *** Script for downloding updates for Trendmicro AV ***
     *** Version: 2023.05.19 *** 
     *** Marius Martin *** 
     *** License GNU GPL***   
#>

$scriptPath = Split-Path $script:MyInvocation.MyCommand.Path       # define the path where the script runs
$today = (Get-Date).ToString('yyyyMMdd')                           # today date
$downloadDirectory = $scriptPath+"\"+$today+"_updates"             # define the folder where updates are downloaded. Name is current-date_updates

# if the download directory does not exist it is created
if (!(Test-Path $downloadDirectory -PathType Container)){
           New-Item -ItemType Directory -Path $downloadDirectory
}

# parsing the content of INI file
$iniurl = "http://smid56-p.activeupdate.trendmicro.com/activeupdate/server.ini"
$content = Invoke-WebRequest -Uri $iniurl -UseBasicParsing | Select-Object -ExpandProperty Content

# extracting the values of interest from INI file
$httpsValue = [regex]::Match($content, "(?<=Https=).*").Value.Trim()
$pathVSAPIValue = [regex]::Match($content, "(?<=Path_VSAPI=).*?(?=,)").Value.Trim()
$antispam1 = [regex]::Match($content, "(?<=P.10001=).*?(?=,)").Value.Trim()
$antispam2 = [regex]::Match($content, "(?<=P.4000001=).*?(?=,)").Value.Trim()

# define the URLs for the update files Trendmicro
$vsapizipurl = "$httpsValue/$pathVSAPIValue"
$vasapisigurl = $vsapizipurl.Replace('zip','sig')
$antispam1url = "$httpsValue/$antispam1"
$antispam2url = "$httpsValue/$antispam2"
$antispam1sigurl = $antispam1url.Replace('zip','sig')
$antispam2sigurl = $antispam2url.Replace('zip','sig')

# download the files
$my_urls = @($vsapizipurl, $vasapisigurl, $antispam1url, $antispam1sigurl, $antispam2url, $antispam2sigurl, $iniurl)
$counter = 0
foreach ($url in $my_urls) {
    $fileName = [System.IO.Path]::GetFileName($url)
    $destinationPath = Join-Path -Path $downloadDirectory -ChildPath $fileName
    Invoke-WebRequest -Uri $url -OutFile $destinationPath 
    Write-Progress -Activity "Downloading files..." -CurrentOperation $title  -PercentComplete (($counter/$my_urls.count)*100)
    Start-Sleep -Milliseconds 500
    Write-Host "Downloaded file: $fileName"
}
