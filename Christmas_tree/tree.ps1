Foreach ($x in (1..11)){
    Write-Host (("o") * $x).PadLeft(11) -nonewline; (("o") * $x)
}
Foreach ($j in (1..3)){
    Write-Host ("||").PadLeft(12)
}
