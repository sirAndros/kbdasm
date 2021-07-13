#Requires -RunAsAdministrator

$idRus = "07430419"
$idEng = "07430409"

$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layouts"

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

if (Test-Path C:\Windows\System32\kbdruen_undead.dll) {
    Remove-Item C:\Windows\System32\kbdruen_undead.dll -Force
}
if (Test-Path C:\Windows\System32\kbdusru_undead.dll) {
    Remove-Item C:\Windows\System32\kbdusru_undead.dll -Force
}
