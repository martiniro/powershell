<#
*********************************************************************************************                                                                          
*  This script is used for downlowding CRL files (no validation)                            *
*  The source URLs of the CRL files are listed in crl.urls file (txt file)(1 URL per line)  *
*  Author: Marius Martin                                                                    *
*  version: 20191205                                                                        *
*  License: GNU GPL                                                                         *    
*********************************************************************************************
#>

$scriptPath = Split-Path $script:MyInvocation.MyCommand.Path
$urls = Get-Content $scriptPath/crl.urls -ErrorAction SilentlyContinue  # crl.urls and the script are in the same folder
$crldir = "$scriptPath\CRL"                                             # folder where CRL files are downloaded

if (!(Test-Path $crldir -PathType Container)){
      New-Item -ItemType Directory -Path $crldir                        # create the download destination folder if does not exist 
}

Set-Location $crldir

foreach($url in $urls)
{
    Invoke-WebRequest $url -OutFile $(Split-Path $url -Leaf)            # download CRL files from URLs specified in the source file crl.urls
}
