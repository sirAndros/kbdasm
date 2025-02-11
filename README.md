KBDASM
======

This repo holds my version of keyboard layout created by [Grom PE](https://github.com/grompe/kbdasm).
Original idea, examples, framework, asm and disasm of keyboard layouts - all by Grom PE.
[Check out his article.](https://habr.com/ru/post/301882)

My vision
---------

Idea of "UNDEAD" keys looks good to me, so I use original [kbdusru_undead](https://github.com/grompe/kbdasm/blob/master/kbdusru_undead.asm) with following modification:

1. Swap digits and symbols (see [notes section](#notes));
2. Add ability to use some dead-keys on `AltGr` layout in RU mode (CAPS ON);
3. Install as US keyboard, as default layout is US.

Than I use very same layout as RU keyboard with RUS keys as default (_EN_ when `CapsLock ON`).

So, my workflow looks like this:

- I preserve langs per window _(Win10 Settings -> Devices -> Typing -> Advanced keyboard settings -> Let me use a different input method for each app window)_
- I use caps to quickly switch in app as usually I need secondary lang only temporary (e.g. in messengers I use russian and only sometimes forced to use english words)
- Run at logon AutoHotKey script from utils to turn off CapsLock when I switch windows.

Installation
------------

If somebody wants to check out my approach - there are PowerShell scripts to setup layouts.

1. Run `.\make.bat`
2. Run `.\setup\install.ps1`
3. Run `.\utils\open_control_input.bat`
4. Add "EN+RU" to English language. _(In opened window in "Preferred languages" select "English"->Options->Add a keyboard")_
5. Remove previously used keyboard.
6. Add "RU+EN" to Russian language and remove previously used keyboard.
7. _Optionally:_ place a shortcut to `.\utils\turn-caps-off-on-win-switch.ahk` into your `shell:startup` folder
8. _Sign Out_ and then _Sign In_ or just _reboot_ your PC.

Notes
-----

I use "typewriter"-like (digits and symbols are swapped) layouts when CapsLock is OFF but prefer to have digits on alternative (caps) layout.
You can easily change both with `TYPEWRITER` and `TYPEWRITER_ON_CAPS` flags in [kbd_ru-us_undead.asm](https://github.com/sirAndros/kbdasm/blob/master/layouts/kbd_ru-us_undead.asm) and [kbd_us-ru_undead.asm](https://github.com/sirAndros/kbdasm/blob/master/layouts/kbd_us-ru_undead.asm).

Also I swapped `{`,`}` and `[`,`]` as well as `_` and `-` for english layout. This settings are controlled by `PROGRAMMER` and `UNDERSCORE_PRIORITY` correspondingly.

**UPD:** After a year, I decided that for me pressing `SHIFT`+`-` is easier in case of naming fields when I'm programming, than passing parameters to scripts in shell, so I've turned the `UNDERSCORE_PRIORITY` off. Also, looks like mine muscle memory is stronger then pinky load, so it's turns out that having  `TYPEWRITER_ON_CAPS` enabled along `TYPEWRITER` setting is less confusing. But I still like having `{`,`}` and `[`,`]` swapped.

Also, I moved to ortholinear keyboard and colmak-dh, so you can find version for this layout also in the repo.

To determine what you use often I recommend to use some keylogger for a week. For my-self I wrote own very basic bicycle: [simple-keypress-statistics](https://github.com/sirAndros/simple-keypress-statistics).
