#Requires -RunAsAdministrator

$idRus = "07430419"
$idEng = "07430409"
$idClmk = "07440409"
$idRuClmk = "07440419"

$dllRus = "kbd_ru-us_undead.dll"
$dllEng = "kbd_us-ru_undead.dll"
$dllClmk = "kbd_us-ru_undead_colemak-dh.dll"
$dllRuClmk = "kbd_ru-us_undead_colemak-dh.dll"

$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layouts"
$srcPath = "$PSScriptRoot\..\layouts"

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

function Test-Dll([string] $path) {
    & "$PSScriptRoot\checkdll.bat" $path
    if (!$?) {
        throw "Keyboard layout binaries is invalid: $path"
    }
}

function Install-Layout([string]$systemId, [string]$id, [string]$text, [string]$file, [string]$dispName) {
    $physicalPath = Join-Path $srcPath $file
    Test-Dll $physicalPath

    if (Test-Path "$regpath\$systemId") {
        Write-Verbose "$dispName keyboard layout is already registered"
    } else {
        Register-Layout $systemId -id $id -text $text -file $file -dispName $dispName
    }

    Copy-Item $physicalPath C:\Windows\System32\ -Force
}

####

Install-Layout $idRus -id "00d0" -text "RU+US" -file $dllRus -dispName "RU+US Extended"
Install-Layout $idEng -id "00d1" -text "US+RU" -file $dllEng -dispName "US+RU Extended"
Install-Layout $idClmk -id "00d2" -text "Colmak+RU" -file $dllClmk -dispName "Colemak-DH+RU Extended"
Install-Layout $idRuClmk -id "00d3" -text "RU+Colmak" -file $dllRuClmk -dispName "RU+Colemak-DH Extended"
