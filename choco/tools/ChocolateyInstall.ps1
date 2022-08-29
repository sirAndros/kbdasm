$idRus = "07430419"
$idEng = "07430409"

$dllRus = "kbd_ru-us_undead.dll"
$dllEng = "kbd_us-ru_undead.dll"

$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layouts"
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$srcPath = "$toolsDir\..\layouts"

function Test-LayoutId ($lid) {
    [bool]$exists = Get-ChildItem $regPath |
        Where-Object { $_.GetValue("Layout Id") -eq $lid }
    return $exists
}

function Register-Layout ([string]$name, [string]$id, [string]$text, [string]$file, [string]$dispName) {
    if (Test-LayoutId $id) {
        throw "Layout with ID $id already exists!"
    } else {
        New-Item -Path $regpath -Name $name |
            New-ItemProperty -Name "Layout Id"   -Value $id   |
            New-ItemProperty -Name "Layout Text" -Value $text |
            New-ItemProperty -Name "Layout File" -Value $file |
            New-ItemProperty -Name "Layout Display Name" -Value $dispName |
            Get-Item
        if ($?) {
            Write-Verbose "Layout `"$name`"($text) has been registered."
        }
    }
}

####


if (Test-Path "$regpath\$idRus") {
    Write-Verbose "Russian keyboard layout is already registered"
} else {
    Register-Layout $idRus -id "00d0" -text "RU+US" -file $dllRus -dispName "RU+US Extended"
}

if (Test-Path "$regpath\$idEng") {
    Write-Verbose "English keyboard layout is already registered"
} else {
    Register-Layout $idEng -id "00d1" -text "US+RU" -file $dllEng -dispName "US+RU Extended"
}

Copy-Item "$srcPath\$dllRus" C:\Windows\System32\ -Force
Copy-Item "$srcPath\$dllEng" C:\Windows\System32\ -Force

Write-Host "Keyboard layouts have been installed. Don't forget to change your windows keyboard settings: Language > Options > Add a keyboard > US+RU/RU+US"
