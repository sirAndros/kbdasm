#Requires -RunAsAdministrator

@(
    @{
        Id = "07430419"
        Name = "RU+US"
        Dll = "kbd_ru-us_undead.dll"
    }
    @{
        Id = "07430409"
        Name = "US+RU"
        Dll = "kbd_us-ru_undead.dll"
    }
    @{
        Id = "07440409"
        Name = "Colemak+RU"
        Dll = "kbd_us-ru_undead_colemak-dh.dll"
    }
    @{
        Id = "07440419"
        Name = "RU+Colemak"
        Dll = "kbd_ru-us_undead_colemak-dh.dll"
    }
) | ForEach-Object {

    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Keyboard Layouts"
    $targetPath = "C:\Windows\System32"

    $id = $_.Id
    $dll = $_.Dll

    if (Test-Path "$regpath\$id") {
        Remove-Item "$regpath\$id" -Force
    } else {
        Write-Verbose "'$regpath\$id' does not exists"
    }

    if (Test-Path "$targetPath\$dll") {
        Remove-Item "$targetPath\$dll" -Force
    }
}
