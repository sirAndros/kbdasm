#Requires -RunAsAdministrator

$idRus = "07430419"
$idEng = "07430409"

$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layouts"

function Test-LayoutId ($lid) {
    [bool]$exists = Get-ChildItem $regPath |
        Where-Object { $_.GetValue("Layout Id") -eq $lid }
    return $exists
}

function Register-Layout ([string]$name, [string]$id, [string]$text, [string]$file, [string]$dispName) {
    if (Test-LayoutId $id) {
        throw "Layout with ID $id already exists!"
    } else {
        New-Item -Path $regpath -Name $name
        New-ItemProperty -Path "$regpath\$name" -Name "Layout Id"   -Value $id
        New-ItemProperty -Path "$regpath\$name" -Name "Layout Text" -Value $text
        New-ItemProperty -Path "$regpath\$name" -Name "Layout File" -Value $file
        New-ItemProperty -Path "$regpath\$name" -Name "Layout Display Name" -Value $dispName
    }
}

if (Test-Path "$regpath\$idRus") {
    Write-Verbose "Russian keyboard layout is already registered"
} else {
    Register-Layout $idRus -id "00d0" -text "RU+EN" -file "kbdruen_undead.dll" -dispName "RUS Undead"
}

if (Test-Path "$regpath\$idEng") {
    Write-Verbose "English keyboard layout is already registered"
} else {
    Register-Layout $idEng -id "00d1" -text "EN+RU" -file "kbdusru_undead.dll" -dispName "US Undead"
}

Copy-Item "..\layouts\kbdruen_undead.dll" C:\Windows\System32\ -Force
Copy-Item "..\layouts\kbdusru_undead.dll" C:\Windows\System32\ -Force
