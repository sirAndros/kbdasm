$idRus = "07430419"
$idEng = "07430409"

$dllRus = "kbd_ru-us_undead.dll"
$dllEng = "kbd_us-ru_undead.dll"

$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layouts"
$targetPath = "C:\Windows\System32"

if (Test-Path "$regpath\$idRus") {
    Remove-Item "$regpath\$idRus" -Force
} else {
    Write-Verbose "'$regpath\$idRus' does not exists"
}

if (Test-Path "$regpath\$idEng") {
    Remove-Item "$regpath\$idEng" -Force
} else {
    Write-Verbose "'$regpath\$idEng' does not exists"
}

if (Test-Path "$targetPath\$dllRus") {
    Remove-Item "$targetPath\$dllRus" -Force
}
if (Test-Path "$targetPath\$dllEng") {
    Remove-Item "$targetPath\$dllEng" -Force
}
