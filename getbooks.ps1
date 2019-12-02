<#
**********************************************************************************                                                                          
*  This script is used for downlowding free ebooks from bestseller.md            *
*  Author: Marius Martin                                                         *
*  version: 20191203                                                             *
*  License: GNU GPL                                                              *   
**********************************************************************************
#>

$scriptPath = Split-Path $script:MyInvocation.MyCommand.Path

if (Test-Path "$scriptPath\invalid_links.txt") {
    Clear-Content "$scriptPath\invalid_links.txt"
}

$booksdir = "$scriptPath\books"

if (!(Test-Path $booksdir -PathType Container)){
           New-Item -ItemType Directory -Path $booksdir
}

Set-Location -Path $booksdir

$ErrorActionPreference = "SilentlyContinue"

$baseurl = "https://www.bestseller.md/freedownload/download/link/link_id/"

# Example: 
# Edit the values of $minlinks = 200 and $maxlinks = 300 in order to download files from links beging with 200 and ending with 300
# From https://www.bestseller.md/freedownload/download/link/link_id/200/  to  https://www.bestseller.md/freedownload/download/link/link_id/300/
$minlinks = 1           # edit the value in order to control the amount of downloaded books
$maxlinks = 5001        # edit the value in order to control the amount of downloaded books

for ($i=$minlinks; $i -le $maxlinks; $i++){
    $url = $baseurl+$i+"/"
    $webresponse = iwr -Uri $url -MaximumRedirection 0 -ErrorAction Ignore
    $filename = ($webresponse.headers["Content-Disposition"] | Select-String "filename").Line.Split('=')[1]
    $statusCode = $webresponse.StatusCode

    Write-Host $url  " ----- " $filename

    if ($statusCode -ne 200) {
        Clear-Variable filename
        Write-Host 'There is no valid file at the specified URL' -ForegroundColor Magenta
        Write-Output $url  | Out-File "$scriptPath\invalid_links.txt" -Append
    }
    elseif (Test-Path($filename))
    {
        Write-Host 'Skipping file, already downloaded' -ForegroundColor Yellow
    }
    else
    {
        Invoke-WebRequest $url -OutFile $(Split-Path $filename -Leaf)    # Download the ebook files
    }    
}
