<#
 **************************************************************************
 * Scraping the web for pbinfo solutions (more then 2000).                *
 * Source: https://tutoriale-pe.net/rezolvari-pbinfo/                     *
 * Every solution is saved locally/offline in its own text file.          *
 * The file name is title of the problem/solution.                        *
 * The files are saved in a folder "solutions" in the root of the script. *
 * Author: Marius Martin                                                  *      
 * version: 20210923                                                      *           
 * License: GNU GPL                                                       *
 ************************************************************************** 
#>

$scriptPath = Split-Path $script:MyInvocation.MyCommand.Path
$soldir = "$scriptPath\solutions"
if (!(Test-Path $soldir -PathType Container)){       # check if solutions folder exists and if not, it is created        
           New-Item -ItemType Directory -Path $soldir -Force | Out-Null
}

$baseurl = 'https://tutoriale-pe.net/rezolvari-pbinfo/page/'
$minpg = 1           # https://tutoriale-pe.net/rezolvari-pbinfo/page/1          
$maxpg = 225         # https://tutoriale-pe.net/rezolvari-pbinfo/page/225   

for ($i=$minpg; $i -le $maxpg; $i++){                # loop for getting the links of solutions
    $url = $baseurl+$i
    $webr = iwr -URI $url -ErrorAction Ignore
    $links = $webr.Links | where href -like "*problema*" | Select-Object href -ExpandProperty href | sort-object href -Unique | Format-List href
    Write-Progress -Activity "Retrieving solutions links..." -Status "$([math]::ceiling($i/$maxpg*100))% Complete" -PercentComplete $($i/$maxpg*100)
    Write-Output $links  | Out-File "$scriptPath\sol_links.txt" -Append
}
$list = Get-Content $scriptPath/sol_links.txt -ErrorAction SilentlyContinue
$counter = 0
foreach ($item in $list) {                           # loop for getting the solution in its own text file  
    $counter++
    $req = $(iwr -URI $item)
    $title = $req.ParsedHtml.title
    $title = $title.Substring(0,$title.Length-38)
    $sol = $req.AllElements | where class -eq "inner-post-entry entry-content" | select innerText -ExpandProperty innerText
    $sol = $sol.Substring(0,$sol.Length-143)
    Write-Progress -Activity "Saving solutions..." -CurrentOperation $title  -PercentComplete (($counter/$list.count)*100)
    Start-Sleep -Milliseconds 200
    Write-Output "$title`n`r $sol"  | Out-File -PSPath "$soldir\$($title).txt"  # size of the solutions folder aprox. 10 MB
}
