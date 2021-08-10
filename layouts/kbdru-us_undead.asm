="utf8"
; kbdasm by Grom PE. Public domain.
; kbdru-us_undead - RU/US hybrid keyboard layout with Caps Lock set to switch
;                  languages and "undead keys" for additional symbols

include "includes/detect_%arch%.inc"

if SYSTEM_64BIT
  format PE64 DLL native 5.0 at 5ffffff0000h on "nul" as "dll" ; Build for 64-bit Windows
else
  format PE DLL native 5.0 at 5fff0000h on "nul" as "dll" ; Build for 32-bit Windows or WOW64
end if

TYPEWRITER = 1 ; Set to 1 to swap 1234567890 and !@#$%^&*() when CapsLock is OFF
TYPEWRITER_ON_CAPS = 0 ; Set to 1 to swap 1234567890 and !@#$%^&*() when CapsLock is ON

MAKE_DLL equ 1

include "includes/base.inc"

WOW64 = 0 ; Use when assembling for 32-bit subsystem for 64-bit OS (Is this ever needed?)
USE_LIGATURES = 1 ; There is a bug in Firefox, if ligatures contain more than
                  ; 4 characters, it won't start up if that layout is default;
                  ; if the layout is switched to, Firefox then hangs.
                  ; See also:
                  ; http://www.unicode.org/mail-arch/unicode-ml/y2015-m08/0012.html
DEBUG = 0

section ".data" readable executable

keynames:
    dp 01h, "ESC"
    dp 0Eh, "BACKSPACE"
    dp 0Fh, "TAB"
    dp 1Ch, "ENTER"
    dp 1Dh, "CTRL"
    dp 2Ah, "SHIFT"
    dp 36h, "RIGHT SHIFT"
    dp 37h, "NUMMULT"
    dp 38h, "ALT"
    dp 39h, "SPACE"
    dp 3Ah, "CAPSLOCK"
    dp 3Bh, "F1"
    dp 3Ch, "F2"
    dp 3Dh, "F3"
    dp 3Eh, "F4"
    dp 3Fh, "F5"
    dp 40h, "F6"
    dp 41h, "F7"
    dp 42h, "F8"
    dp 43h, "F9"
    dp 44h, "F10"
    dp 45h, "Pause"
    dp 46h, "SCROLL LOCK"
    dp 47h, "NUM 7"
    dp 48h, "NUM 8"
    dp 49h, "NUM 9"
    dp 4Ah, "NUM SUB"
    dp 4Bh, "NUM 4"
    dp 4Ch, "NUM 5"
    dp 4Dh, "NUM 6"
    dp 4Eh, "NUM PLUS"
    dp 4Fh, "NUM 1"
    dp 50h, "NUM 2"
    dp 51h, "NUM 3"
    dp 52h, "NUM 0"
    dp 53h, "NUM DECIMAL"
    dp 57h, "F11"
    dp 58h, "F12"
    dp 0, 0

palign

keynamesExt:
    dp 1Ch, "NUM ENTER"
    dp 1Dh, "Right Ctrl"
    dp 35h, "NUM DIVIDE"
    dp 37h, "Prnt Scrn"
    dp 38h, "RIGHT ALT"
    dp 45h, "Num Lock"
    dp 46h, "Break"
    dp 47h, "HOME"
    dp 48h, "UP"
    dp 49h, "PGUP"
    dp 4Bh, "LEFT"
    dp 4Dh, "RIGHT"
    dp 4Fh, "END"
    dp 50h, "DOWN"
    dp 51h, "PGDOWN"
    dp 52h, "INSERT"
    dp 53h, "DELETE"
    dp 54h, "<00>"
    dp 56h, "Help"
    dp 5Bh, "Left Windows"
    dp 5Ch, "Right Windows"
    dp 5Dh, "Application"
    dp 0, 0

palign

keynamesDead:
    dp "´ACUTE"
    dp "˝DOUBLE ACUTE"
    dp "`GRAVE"
    dp "^CIRCUMFLEX"
    dp '¨UMLAUT'
    dp "~TILDE"
    dp "ˇCARON"
    dp "°RING"
    dp "¸CEDILLA"
    dp "¯MACRON" 
    dp 0

palign

if used ligatures
ligatures: .:
    dw VK_SLASH ; VKey
    dw 3   ; Modifiers; Shift + AltGr; basically is the column number in vk2wchar* tables that contains WCH_LGTR
    du "\r\n" ; If less than max characters are used, the rest must be filled with WCH_NONE
ligature_size = $ - .
if DEBUG
    dw VK_CLEAR ; VKey
    dw 0        ; Modifiers
    du "v05."
end if
    db ligatureEntry dup 0

palign
end if

if USE_LIGATURES
  ligatureMaxChars = (ligature_size - 4) / 2
  if ligatureMaxChars > 4
    err "4 characters is max for a ligature on Windows XP or if you use Firefox"
  end if
;  if ligatureMaxChars > 16
;    err "16 characters is max for a ligature on Windows 7"
;  end if
  ligatureEntry = ligature_size
  ligatures_if_used = ligatures
else
  ligatureMaxChars = 0
  ligatureEntry = 0
  ligatures_if_used = 0
end if

KbdTables:
    dp modifiers
    dp vk2wchar
    dp deadkeys
    dp keynames         ; Names of keys
    dp keynamesExt
    dp keynamesDead
    dp scancode2vk      ; Scan codes to virtual keys
    db scancode2vk.size / 2
    palign
    dp e0scancode2vk
    dp e1scancode2vk
    dw KLLF_ALTGR       ; Locale flags
    dw KBD_VERSION
    db ligatureMaxChars ; Maximum ligature table characters
    db ligatureEntry    ; Count of bytes in each ligature row
    palign
    dp ligatures_if_used
    dd 0, 0             ; Type, subtype

palign

vk2bits:
    db VK_SHIFT,   KBDSHIFT
    db VK_CONTROL, KBDCTRL
    db VK_MENU,    KBDALT
    db 0, 0

palign

modifiers:
    dp vk2bits
    dw modifiers_max
.start:
    db 0            ; ---- --- ---- -----
    db 1            ; ---- --- ---- SHIFT
    db 4            ; ---- --- CTRL -----
    db 5            ; ---- --- CTRL SHIFT
    db SHFT_INVALID ; ---- ALT ---- -----
    db SHFT_INVALID ; ---- ALT ---- SHIFT
    db 2            ; ---- ALT CTRL ----- (Alt+Ctrl = AltGr)
    db 3            ; ---- ALT CTRL SHIFT
modifiers_max = $ - .start - 1

palign

vk2wchar1:
if DEBUG
    vkrow1 VK_CLEAR,   0, WCH_LGTR
end if
    vkrow1 VK_NUMPAD0, 0, "0"
    vkrow1 VK_NUMPAD1, 0, "1"
    vkrow1 VK_NUMPAD2, 0, "2"
    vkrow1 VK_NUMPAD3, 0, "3"
    vkrow1 VK_NUMPAD4, 0, "4"
    vkrow1 VK_NUMPAD5, 0, "5"
    vkrow1 VK_NUMPAD6, 0, "6"
    vkrow1 VK_NUMPAD7, 0, "7"
    vkrow1 VK_NUMPAD8, 0, "8"
    vkrow1 VK_NUMPAD9, 0, "9"
    dw 0, 0, 0

palign

vk2wchar2:
    vkrow2 VK_DECIMAL,  SGCAPS, ".", "."
    vkrow2 VK_DECIMAL,  0,      ",", ","
    vkrow2 VK_TAB,      0,      9,   9
    vkrow2 VK_ADD,      0,      "+", "+"
    vkrow2 VK_DIVIDE,   0,      "/", "/"
    vkrow2 VK_MULTIPLY, 0,      "*", "*"
    vkrow2 VK_SUBTRACT, 0,      "-", "-"
    dw 0, 0, 2 dup 0

palign

vk2wchar4:
    vkrow4 VK_GRAVE,      SGCAPS, "ё",      "Ё",      "`",      "≈"
    vkrow4 -1,            0,      "`",      "~",      WCH_NONE, WCH_NONE
if TYPEWRITER
    vkrow4 "1",           SGCAPS, "!",      "1",      "¡",      "¹"
else
    vkrow4 "1",           SGCAPS, "1",      "!",      "¡",      "¹"
end if
if TYPEWRITER_ON_CAPS
    vkrow4 "1",           0,      "!",      "1",      WCH_NONE, WCH_NONE
else
    vkrow4 "1",           0,      "1",      "!",      WCH_NONE, WCH_NONE
end if
if TYPEWRITER
    vkrow4 "2",           SGCAPS, '"',      "2",      "@",      "²"
else
    vkrow4 "2",           SGCAPS, "2",      '"',      "@",      "²"
end if
if TYPEWRITER_ON_CAPS
    vkrow4 "2",           0,      '@',      "2",      WCH_NONE, WCH_NONE
else
    vkrow4 "2",           0,      "2",      "@",      WCH_NONE, WCH_NONE
end if
if TYPEWRITER
    vkrow4 "3",           SGCAPS, "#",      "3",      "№",      "³"
else
    vkrow4 "3",           SGCAPS, "3",      "#",      "№",      "³"
end if
if TYPEWRITER_ON_CAPS
    vkrow4 "3",           0,      "#",      "3",      WCH_NONE, WCH_NONE
else
    vkrow4 "3",           0,      "3",      "#",      WCH_NONE, WCH_NONE
end if
if TYPEWRITER
    vkrow4 "4",           SGCAPS, ";",      "4",      "$",      "£"
else
    vkrow4 "4",           SGCAPS, "4",      ";",      "$",      "£"
end if
if TYPEWRITER_ON_CAPS
    vkrow4 "4",           0,      "$",      "4",      WCH_NONE, WCH_NONE
else
    vkrow4 "4",           0,      "4",      "$",      WCH_NONE, WCH_NONE
end if
if TYPEWRITER
    vkrow4 "5",           SGCAPS, "%",      "5",      "€",      "‰"
else
    vkrow4 "5",           SGCAPS, "5",      "%",      "€",      "‰"
end if
if TYPEWRITER_ON_CAPS
    vkrow4 "5",           0,      "%",      "5",      WCH_NONE, WCH_NONE
else
    vkrow4 "5",           0,      "5",      "%",      WCH_NONE, WCH_NONE
end if
if TYPEWRITER
    vkrow4 "6",           SGCAPS, ":",      "6",      "^",      "↑"
else
    vkrow4 "6",           SGCAPS, "6",      ":",      "^",      "↑"
end if
if TYPEWRITER_ON_CAPS
    vkrow4 -1,            0,      "^",      "6",      WCH_NONE, WCH_NONE
else
    vkrow4 -1,            0,      "6",      "^",      WCH_NONE, WCH_NONE
end if
if TYPEWRITER
    vkrow4 "7",           SGCAPS, "?",      "7",      "&",      "＆"
else
    vkrow4 "7",           SGCAPS, "7",      "?",      "&",      "＆"
end if
if TYPEWRITER_ON_CAPS
    vkrow4 "7",           0,      "&",      "7",      WCH_NONE, WCH_NONE
else
    vkrow4 "7",           0,      "7",      "&",      WCH_NONE, WCH_NONE
end if
if TYPEWRITER
    vkrow4 "8",           SGCAPS, "*",      "8",      "∞",      "×"
else
    vkrow4 "8",           SGCAPS, "8",      "*",      "∞",      "×"
end if
if TYPEWRITER_ON_CAPS
    vkrow4 "8",           0,      "*",      "8",      WCH_NONE, WCH_NONE
else
    vkrow4 "8",           0,      "8",      "*",      WCH_NONE, WCH_NONE
end if
if TYPEWRITER
    vkrow4 "9",           SGCAPS, "(",      "9",      "«",      "“"
else
    vkrow4 "9",           SGCAPS, "9",      "(",      "«",      "“"
end if
if TYPEWRITER_ON_CAPS
    vkrow4 "9",           0,      "(",      "9",      WCH_NONE, WCH_NONE
else
    vkrow4 "9",           0,      "9",      "(",      WCH_NONE, WCH_NONE
end if
if TYPEWRITER
    vkrow4 "0",           SGCAPS, ")",      "0",      "»",      "”"
else
    vkrow4 "0",           SGCAPS, "0",      ")",      "»",      "”"
end if
if TYPEWRITER_ON_CAPS
    vkrow4 "0",           0,      ")",      "0",      WCH_NONE, WCH_NONE
else
    vkrow4 "0",           0,      "0",      ")",      WCH_NONE, WCH_NONE
end if
    vkrow4 VK_MINUS,      0,      "-",      "_",      "–",      "—"
    vkrow4 VK_EQUALS,     0,      "=",      "+",      "≠",      "±"
    vkrow4 "Q",           SGCAPS, "й",      "Й",      WCH_DEAD, WCH_DEAD
    vkrow4 "Q",           0,      "q",      "Q",      "й",      "Й"
    vkrow4 "W",           SGCAPS, "ц",      "Ц",      WCH_DEAD, WCH_DEAD
    vkrow4 "W",           0,      "w",      "W",      "ц",      "Ц"
    vkrow4 "E",           SGCAPS, "у",      "У",      WCH_DEAD, WCH_DEAD
    vkrow4 "E",           0,      "e",      "E",      "у",      "У"
    vkrow4 "R",           SGCAPS, "к",      "К",      WCH_DEAD, WCH_DEAD
    vkrow4 "R",           0,      "r",      "R",      "к",      "К"
    vkrow4 "T",           SGCAPS, "е",      "Е",      WCH_DEAD, WCH_DEAD
    vkrow4 "T",           0,      "t",      "T",      "е",      "Е"
    vkrow4 "Y",           SGCAPS, "н",      "Н",      WCH_DEAD, WCH_DEAD
    vkrow4 "Y",           0,      "y",      "Y",      "н",      "Н"
    vkrow4 "U",           SGCAPS, "г",      "Г",      WCH_DEAD, WCH_DEAD
    vkrow4 "U",           0,      "u",      "U",      "г",      "Г"
    vkrow4 "I",           SGCAPS, "ш",      "Ш",      WCH_DEAD, WCH_DEAD
    vkrow4 "I",           0,      "i",      "I",      "ш",      "Ш"
    vkrow4 "O",           SGCAPS, "щ",      "Щ",      WCH_DEAD, WCH_DEAD
    vkrow4 "O",           0,      "o",      "O",      "щ",      "Щ"
    vkrow4 "P",           SGCAPS, "з",      "З",      WCH_DEAD, WCH_DEAD
    vkrow4 "P",           0,      "p",      "P",      "з",      "З"
    vkrow4 "A",           SGCAPS, "ф",      "Ф",      WCH_DEAD, WCH_DEAD
    vkrow4 "A",           0,      "a",      "A",      "ф",      "Ф"
    vkrow4 "S",           SGCAPS, "ы",      "Ы",      WCH_DEAD, WCH_DEAD
    vkrow4 "S",           0,      "s",      "S",      "ы",      "Ы"
    vkrow4 "D",           SGCAPS, "в",      "В",      WCH_DEAD, WCH_DEAD
    vkrow4 "D",           0,      "d",      "D",      "в",      "В"
    vkrow4 "F",           SGCAPS, "а",      "А",      WCH_DEAD, WCH_DEAD
    vkrow4 "F",           0,      "f",      "F",      "а",      "А"
    vkrow4 "G",           SGCAPS, "п",      "П",      WCH_DEAD, WCH_DEAD
    vkrow4 "G",           0,      "g",      "G",      "п",      "П"
    vkrow4 "H",           SGCAPS, "р",      "Р",      WCH_DEAD, WCH_DEAD
    vkrow4 "H",           0,      "h",      "H",      "р",      "Р"
    vkrow4 "J",           SGCAPS, "о",      "О",      WCH_DEAD, WCH_DEAD
    vkrow4 "J",           0,      "j",      "J",      "о",      "О"
    vkrow4 "K",           SGCAPS, "л",      "Л",      WCH_DEAD, WCH_DEAD
    vkrow4 "K",           0,      "k",      "K",      "л",      "Л"
    vkrow4 "L",           SGCAPS, "д",      "Д",      WCH_DEAD, WCH_DEAD
    vkrow4 "L",           0,      "l",      "L",      "д",      "Д"
    vkrow4 VK_SEMICOLON,  SGCAPS, "ж",      "Ж",      "°",      "¶"
    vkrow4 -1,            0,      ";",      ":",      WCH_NONE, WCH_NONE
    vkrow4 VK_APOSTROPHE, SGCAPS, "э",      'Э',      "'",      "́" ; combining acute
    vkrow4 -1,            0,      "'",      '"',      WCH_NONE, WCH_NONE
    vkrow4 "Z",           SGCAPS, "я",      "Я",      WCH_DEAD, WCH_DEAD
    vkrow4 "Z",           0,      "z",      "Z",      "я",      "Я"
    vkrow4 "X",           SGCAPS, "ч",      "Ч",      WCH_DEAD, WCH_DEAD
    vkrow4 "X",           0,      "x",      "X",      "ч",      "Ч"
    vkrow4 "C",           SGCAPS, "с",      "С",      WCH_DEAD, WCH_DEAD
    vkrow4 "C",           0,      "c",      "C",      "с",      "С"
    vkrow4 "V",           SGCAPS, "м",      "М",      WCH_DEAD, WCH_DEAD
    vkrow4 "V",           0,      "v",      "V",      "м",      "М"
    vkrow4 "B",           SGCAPS, "и",      "И",      WCH_DEAD, WCH_DEAD
    vkrow4 "B",           0,      "b",      "B",      "и",      "И"
    vkrow4 "N",           SGCAPS, "т",      "Т",      WCH_DEAD, WCH_DEAD
    vkrow4 "N",           0,      "n",      "N",      "т",      "Т"
    vkrow4 "M",           SGCAPS, "ь",      "Ь",      WCH_DEAD, WCH_DEAD
    vkrow4 "M",           0,      "m",      "M",      "ь",      "Ь"
    vkrow4 VK_COMMA,      SGCAPS, "б",      "Б",      "<",      "≤"
    vkrow4 -1,            0,      ",",      "<",      WCH_NONE, WCH_NONE
    vkrow4 VK_PERIOD,     SGCAPS, "ю",      "Ю",      ">",      "≥"
    vkrow4 -1,            0,      ".",      ">",      WCH_NONE, WCH_NONE
    vkrow4 VK_SLASH,      SGCAPS, ".",      ",",      "¿",      WCH_LGTR
    vkrow4 VK_SLASH,      0,      "/",      "?",      WCH_NONE, WCH_NONE
    dw 0, 0, 4 dup 0

palign

vk2wchar5:
    vkrow5 VK_LBRACKET,  SGCAPS, "х", "Х", "[",      "{",      01Bh
    vkrow5 VK_LBRACKET,  0,      "[", "{", WCH_NONE, WCH_NONE, WCH_NONE
    vkrow5 VK_RBRACKET,  SGCAPS, "ъ", "Ъ", "]",      "}",      01Dh
    vkrow5 VK_RBRACKET,  0,      "]", "}", WCH_NONE, WCH_NONE, WCH_NONE
    vkrow5 VK_BACKSLASH, SGCAPS, "\", "/", "|",      "¬",      01Ch
    vkrow5 VK_BACKSLASH, 0,      "\", "|", WCH_NONE, WCH_NONE, WCH_NONE
    vkrow5 VK_OEM_102,   0,      "\", "|", WCH_NONE, WCH_NONE, 01Ch
    vkrow5 VK_BACK,      0,      8,   8,   WCH_NONE, WCH_NONE, 07Fh
    vkrow5 VK_ESCAPE,    0,      27,  27,  WCH_NONE, WCH_NONE, 01Bh
    vkrow5 VK_RETURN,    0,      13,  13,  WCH_NONE, WCH_NONE, 10
    vkrow5 VK_SPACE,     0,      " ", " ", " ",      WCH_NONE, " "
    vkrow5 VK_CANCEL,    0,      3,   3,   WCH_NONE, WCH_NONE, 3
    dw 0, 0, 5 dup 0

palign

vk2wchar:
    dp vk2wchar1, 0401h
    dp vk2wchar2, 0602h
    dp vk2wchar4, 0A04h
    dp vk2wchar5, 0C05h
    dp 0, 0

palign

e1scancode2vk:
    dw 1Dh, VK_PAUSE
    dw 0, 0

palign

; On scancodes, see: https://www.win.tue.nl/~aeb/linux/kbd/scancodes.html

e0scancode2vk:
    dw 10h, KBDEXT + VK_MEDIA_PREV_TRACK
    dw 19h, KBDEXT + VK_MEDIA_NEXT_TRACK
    dw 1Ch, KBDEXT + VK_RETURN
    dw 1Dh, KBDEXT + VK_RCONTROL
    dw 20h, KBDEXT + VK_VOLUME_MUTE
    dw 21h, KBDEXT + VK_LAUNCH_APP2
    dw 22h, KBDEXT + VK_MEDIA_PLAY_PAUSE
    dw 24h, KBDEXT + VK_MEDIA_STOP
    dw 2Eh, KBDEXT + VK_VOLUME_DOWN
    dw 30h, KBDEXT + VK_VOLUME_UP
    dw 32h, KBDEXT + VK_BROWSER_HOME
    dw 35h, KBDEXT + VK_DIVIDE
    dw 37h, KBDEXT + VK_SNAPSHOT
    dw 38h, KBDEXT + VK_RMENU
    dw 46h, KBDEXT + VK_CANCEL
    dw 47h, KBDEXT + VK_HOME
    dw 48h, KBDEXT + VK_UP
    dw 49h, KBDEXT + VK_PGUP
    dw 4Bh, KBDEXT + VK_LEFT
    dw 4Dh, KBDEXT + VK_RIGHT
    dw 4Fh, KBDEXT + VK_END
    dw 50h, KBDEXT + VK_DOWN
    dw 51h, KBDEXT + VK_NEXT
    dw 52h, KBDEXT + VK_INSERT
    dw 53h, KBDEXT + VK_DELETE
    dw 5Bh, KBDEXT + VK_LWIN
    dw 5Ch, KBDEXT + VK_RWIN
    dw 5Dh, KBDEXT + VK_APPS
    dw 5Eh, KBDEXT + VK_POWER ; You can reassign these two, but they also do
    dw 5Fh, KBDEXT + VK_SLEEP ; their original action unless disabled elsewhere
;    dw 63h, 0FFh ; WakeUp button
    dw 65h, KBDEXT + VK_BROWSER_SEARCH
    dw 66h, KBDEXT + VK_BROWSER_FAVORITES
    dw 67h, KBDEXT + VK_BROWSER_REFRESH
    dw 68h, KBDEXT + VK_BROWSER_STOP
    dw 69h, KBDEXT + VK_BROWSER_FORWARD
    dw 6Ah, KBDEXT + VK_BROWSER_BACK
    dw 6Bh, KBDEXT + VK_LAUNCH_APP1
    dw 6Ch, KBDEXT + VK_LAUNCH_MAIL
    dw 6Dh, KBDEXT + VK_LAUNCH_MEDIA_SELECT
    dw 0, 0

palign

scancode2vk: .:
    du 0FFh, VK_ESCAPE, "1234567890", VK_MINUS, VK_EQUALS, VK_BACK
    du VK_TAB, "QWERTYUIOP", VK_LBRACKET, VK_RBRACKET, VK_RETURN
    du VK_LCONTROL, "ASDFGHJKL", VK_SEMICOLON, VK_APOSTROPHE, VK_GRAVE
    du VK_LSHIFT, VK_BACKSLASH, "ZXCVBNM", VK_COMMA, VK_PERIOD, VK_SLASH
    du KBDEXT+VK_RSHIFT, KBDMULTIVK+VK_MULTIPLY
    du VK_LMENU, " ", VK_CAPITAL
    du VK_F1, VK_F2, VK_F3, VK_F4, VK_F5, VK_F6, VK_F7, VK_F8, VK_F9, VK_F10
    du KBDEXT+KBDMULTIVK+VK_NUMLOCK, KBDMULTIVK+VK_SCROLL
    du KBDSPECIAL+KBDNUMPAD+VK_HOME, KBDSPECIAL+KBDNUMPAD+VK_UP, KBDSPECIAL+KBDNUMPAD+VK_PGUP, VK_SUBTRACT
    du KBDSPECIAL+KBDNUMPAD+VK_LEFT, KBDSPECIAL+KBDNUMPAD+VK_CLEAR, KBDSPECIAL+KBDNUMPAD+VK_RIGHT, VK_ADD
    du KBDSPECIAL+KBDNUMPAD+VK_END, KBDSPECIAL+KBDNUMPAD+VK_DOWN, KBDSPECIAL+KBDNUMPAD+VK_PGDN
    du KBDSPECIAL+KBDNUMPAD+VK_INSERT, KBDSPECIAL+KBDNUMPAD+VK_DELETE
    du VK_SNAPSHOT, 0FFh, VK_OEM_102, VK_F11, VK_F12, VK_CLEAR, VK_OEM_WSCTRL
    du VK_OEM_FINISH, VK_OEM_JUMP, VK_EREOF, VK_OEM_BACKTAB, VK_OEM_AUTO
    du 0FFh, 0FFh, VK_ZOOM, VK_HELP, VK_F13, VK_F14, VK_F15, VK_F16, VK_F17
    du VK_F18, VK_F19, VK_F20, VK_F21, VK_F22, VK_F23
    du VK_OEM_PA3, 0FFh, VK_OEM_RESET, 0FFh, VK_ABNT_C1, 0FFh, 0FFh, VK_F24
    du 0FFh, 0FFh, 0FFh, 0FFh, VK_OEM_PA1, VK_TAB, 0FFh, VK_ABNT_C2
.size = $ - .

palign

deadkeys:
    du "AФA", 0, "aфa", 0, "ФФA", 0, "ффa", 0
    du "BИB", 0, "bиb", 0, "ИИB", 0, "ииb", 0
    du "CСC", 0, "cсc", 0, "ССC", 0, "ссc", 0
    du "DВD", 0, "dвd", 0, "ВВD", 0, "ввd", 0
    du "EУE", 0, "eуe", 0, "УУE", 0, "ууe", 0
    du "FАF", 0, "fаf", 0, "ААF", 0, "ааf", 0
    du "GПG", 0, "gпg", 0, "ППG", 0, "ппg", 0
    du "HРH", 0, "hрh", 0, "РРH", 0, "ррh", 0
    du "IШI", 0, "iшi", 0, "ШШI", 0, "шшi", 0
    du "JОJ", 0, "jоj", 0, "ООJ", 0, "ооj", 0
    du "KЛK", 0, "kлk", 0, "ЛЛK", 0, "ллk", 0
    du "LДL", 0, "lдl", 0, "ДДL", 0, "ддl", 0
    du "MВM", 0, "mьm", 0, "ЬВM", 0, "ььm", 0
    du "NТN", 0, "nтn", 0, "ТТN", 0, "ттn", 0
    du "OЩO", 0, "oщo", 0, "ЩЩO", 0, "щщo", 0
    du "PЗP", 0, "pзp", 0, "ЗЗP", 0, "ззp", 0
    du "QЙQ", 0, "qйq", 0, "ЙЙQ", 0, "ййq", 0
    du "RКR", 0, "rкr", 0, "ККR", 0, "ккr", 0
    du "SЫS", 0, "sыs", 0, "ЫЫS", 0, "ыыs", 0
    du "TЕT", 0, "tеt", 0, "ЕЕT", 0, "ееt", 0
    du "UГU", 0, "uгu", 0, "ГГU", 0, "ггu", 0
    du "VМV", 0, "vмv", 0, "ММV", 0, "ммv", 0
    du "WЦW", 0, "wцw", 0, "ЦЦW", 0, "ццw", 0
    du "XЧX", 0, "xчx", 0, "ЧЧX", 0, "ччx", 0
    du "YНY", 0, "yнy", 0, "ННY", 0, "ннy", 0
    du "ZЯZ", 0, "zяz", 0, "ЯЯZ", 0, "яяz", 0
    du "'ФÁ", 0, "'фá", 0
    du "'ÆǼ", 0, "'æǽ", 0
    du "'СĆ", 0, "'сć", 0
    du "'УÉ", 0, "'уé", 0
    du "'ПǴ", 0, "'пǵ", 0
    du "'ШÍ", 0, "'шí", 0
    du "'ЛḰ", 0, "'лḱ", 0
    du "'ДĹ", 0, "'дĺ", 0
    du "'ЬḾ", 0, "'ьḿ", 0
    du "'ТŃ", 0, "'тń", 0
    du "'ЩÓ", 0, "'щó", 0
    du "'ØǾ", 0, "'øǿ", 0
    du "'ЗṔ", 0, "'зṕ", 0
    du "'КŔ", 0, "'кŕ", 0
    du "'ЫŚ", 0, "'ыś", 0
    du "'ГÚ", 0, "'гú", 0
    du "'ЦẂ", 0, "'цẃ", 0
    du "'НÝ", 0, "'нý", 0
    du "'ЯŹ", 0, "'яź", 0
    du "эФÁ", 0, "эфá", 0
    du "эÆǼ", 0, "эæǽ", 0
    du "эСĆ", 0, "эсć", 0
    du "эУÉ", 0, "эуé", 0
    du "эПǴ", 0, "эпǵ", 0
    du "эШÍ", 0, "эшí", 0
    du "эЛḰ", 0, "элḱ", 0
    du "эДĹ", 0, "эдĺ", 0
    du "эЬḾ", 0, "эьḿ", 0
    du "эТŃ", 0, "этń", 0
    du "эЩÓ", 0, "эщó", 0
    du "эØǾ", 0, "эøǿ", 0
    du "эЗṔ", 0, "эзṕ", 0
    du "эКŔ", 0, "экŕ", 0
    du "эЫŚ", 0, "эыś", 0
    du "эГÚ", 0, "эгú", 0
    du "эЦẂ", 0, "эцẃ", 0
    du "эНÝ", 0, "энý", 0
    du "эЯŹ", 0, "эяź", 0
    du '"ЩŐ', 0, '"щő', 0
    du '"ГŰ', 0, '"гű', 0
    du 'ЭЩŐ', 0, 'Эщő', 0
    du 'ЭГŰ', 0, 'Эгű', 0
    du "oФÅ", 0, "oфå", 0
    du "oГŮ", 0, "oгů", 0
    du "щФÅ", 0, "щфå", 0
    du "щГŮ", 0, "щгů", 0
    du ".ФȦ", 0, ".фȧ", 0
    du ".ИḂ", 0, ".иḃ", 0
    du ".СĊ", 0, ".сċ", 0
    du ".ВḊ", 0, ".вḋ", 0
    du ".УĖ", 0, ".уė", 0
    du ".АḞ", 0, ".аḟ", 0
    du ".ПĠ", 0, ".пġ", 0
    du ".РḢ", 0, ".рḣ", 0
    du ".Шİ", 0, ".шı", 0
    du ".ЬṀ", 0, ".ьṁ", 0
    du ".ТṄ", 0, ".тṅ", 0
    du ".ЩȮ", 0, ".щȯ", 0
    du ".ЗṖ", 0, ".зṗ", 0
    du ".КṘ", 0, ".кṙ", 0
    du ".ЫṠ", 0, ".ыṡ", 0
    du ".ЕṪ", 0, ".еṫ", 0
    du ".ЦẆ", 0, ".цẇ", 0
    du ".ЧẊ", 0, ".чẋ", 0
    du ".НẎ", 0, ".нẏ", 0
    du ".ЯŻ", 0, ".яż", 0
    du ':ФÄ', 0, ':фä', 0
    du ':УË', 0, ':уë', 0
    du ':ЕЁ', 0, ':её', 0 ; rus
    du ':РḦ', 0, ':рḧ', 0
    du ':ШÏ', 0, ':шï', 0
    du ':ЩÖ', 0, ':щö', 0
    du ':ГÜ', 0, ':гü', 0
    du ':ЦẄ', 0, ':цẅ', 0
    du ':ЧẌ', 0, ':чẍ', 0
    du ':НŸ', 0, ':нÿ', 0
    du 'ЖФÄ', 0, 'Жфä', 0
    du 'ЖУË', 0, 'Жуë', 0
    du 'ЖЕЁ', 0, 'Жеё', 0 ; rus
    du 'ЖРḦ', 0, 'Жрḧ', 0
    du 'ЖШÏ', 0, 'Жшï', 0
    du 'ЖЩÖ', 0, 'Жщö', 0
    du 'ЖГÜ', 0, 'Жгü', 0
    du 'ЖЦẄ', 0, 'Жцẅ', 0
    du 'ЖЧẌ', 0, 'Жчẍ', 0
    du 'ЖНŸ', 0, 'Жнÿ', 0
    du "^ФÂ", 0, "^фâ", 0
    du "^СĈ", 0, "^сĉ", 0
    du "^УÊ", 0, "^уê", 0
    du "^ПĜ", 0, "^пĝ", 0
    du "^РĤ", 0, "^рĥ", 0
    du "^ШÎ", 0, "^шî", 0
    du "^ОĴ", 0, "^оĵ", 0
    du "^ЩÔ", 0, "^щô", 0
    du "^ЫŜ", 0, "^ыŝ", 0
    du "^ГÛ", 0, "^гû", 0
    du "^ЦŴ", 0, "^цŵ", 0
    du "^НŶ", 0, "^нŷ", 0
    du "^ЯẐ", 0, "^яẑ", 0
    du "vФǍ", 0, "vфǎ", 0
    du "vСČ", 0, "vсč", 0
    du "vВĎ", 0, "vвď", 0
    du "vУĚ", 0, "vуě", 0
    du "vПǦ", 0, "vпǧ", 0
    du "vРȞ", 0, "vрȟ", 0
    du "vШǏ", 0, "vшǐ", 0
    du "vЛǨ", 0, "vлǩ", 0
    du "vДĽ", 0, "vдľ", 0
    du "vТŇ", 0, "vтň", 0
    du "vЩǑ", 0, "vщǒ", 0
    du "vКŘ", 0, "vкř", 0
    du "vЫŠ", 0, "vыš", 0
    du "vЕŤ", 0, "vеť", 0
    du "vГǓ", 0, "vгǔ", 0
    du "vЯŽ", 0, "vяž", 0
    du "мФǍ", 0, "мфǎ", 0
    du "мСČ", 0, "мсč", 0
    du "мВĎ", 0, "мвď", 0
    du "мУĚ", 0, "муě", 0
    du "мПǦ", 0, "мпǧ", 0
    du "мРȞ", 0, "мрȟ", 0
    du "мШǏ", 0, "мшǐ", 0
    du "мЛǨ", 0, "млǩ", 0
    du "мДĽ", 0, "мдľ", 0
    du "мТŇ", 0, "мтň", 0
    du "мЩǑ", 0, "мщǒ", 0
    du "мКŘ", 0, "мкř", 0
    du "мЫŠ", 0, "мыš", 0
    du "мЕŤ", 0, "меť", 0
    du "мГǓ", 0, "мгǔ", 0
    du "мЯŽ", 0, "мяž", 0
    du "uAĂ", 0, "uaă", 0
    du "uEĔ", 0, "ueĕ", 0
    du "uGĞ", 0, "ugğ", 0
    du "uIĬ", 0, "uiĭ", 0
    du "uOŎ", 0, "uoŏ", 0
    du "uUŬ", 0, "uuŭ", 0
    du "`ФÀ", 0, "`фà", 0
    du "`УÈ", 0, "`уè", 0
    du "`ШÌ", 0, "`шì", 0
    du "`ТǸ", 0, "`тǹ", 0
    du "`ЩÒ", 0, "`щò", 0
    du "`ГÙ", 0, "`гù", 0
    du "`ЦẀ", 0, "`цẁ", 0
    du "`НỲ", 0, "`нỳ", 0
    du "~ФÃ", 0, "~фã", 0
    du "~УẼ", 0, "~уẽ", 0
    du "~ШĨ", 0, "~шĩ", 0
    du "~ТÑ", 0, "~тñ", 0
    du "~ЩÕ", 0, "~щõ", 0
    du "~ГŨ", 0, "~гũ", 0
    du "~МṼ", 0, "~мṽ", 0
    du "~НỸ", 0, "~нỹ", 0
; ogonek:  ˛ Ąą    Ęę    Įį      Ǫǫ      Ųų
; cedilla: ¸   ÇçḐḑ  ĢģḨḩ  ĶķĻļŅņ  ŖŗŞşŢţ
    du ",ФĄ", 0, ",фą", 0
    du ",СÇ", 0, ",сç", 0
    du ",ВḐ", 0, ",вḑ", 0
    du ",УĘ", 0, ",уę", 0
    du ",ПĢ", 0, ",пģ", 0
    du ",РḨ", 0, ",рḩ", 0
    du ",ШĮ", 0, ",шį", 0
    du ",ЛĶ", 0, ",лķ", 0
    du ",ДĻ", 0, ",дļ", 0
    du ",ТŅ", 0, ",тņ", 0
    du ",ЩǪ", 0, ",щǫ", 0
    du ",КŖ", 0, ",кŗ", 0
    du ",ЫŞ", 0, ",ыş", 0
    du ",ЕŢ", 0, ",еţ", 0
    du ",ГŲ", 0, ",гų", 0
    du "/ФȺ", 0, "/фⱥ", 0
    du "/ИɃ", 0, "/иƀ", 0
    du "/СȻ", 0, "/сȼ", 0
    du "/ВĐ", 0, "/вđ", 0
    du "/УɆ", 0, "/уɇ", 0
    du "/АꞘ", 0, "/аꞙ", 0
    du "/ПǤ", 0, "/пǥ", 0
    du "/РĦ", 0, "/рħ", 0
    du "/ШƗ", 0, "/шɨ", 0
    du "/ОɈ", 0, "/оɉ", 0
    du "/ЛꝀ", 0, "/лꝁ", 0
    du "/ДŁ", 0, "/дł", 0
    du "/ЩØ", 1, "/щø", 1, " ØØ", 0, " øø", 0
    du "\ЩØ", 0, "\щø", 0
    du "/ЗⱣ", 0, "/зᵽ", 0
    du "/КɌ", 0, "/кɍ", 0
    du "/ЕŦ", 0, "/еŧ", 0
    du "/НɎ", 0, "/нɏ", 0
    du "/ЯƵ", 0, "/яƶ", 0
    du "mФĀ", 0, "mфā", 0
    du "mÆǢ", 0, "mæǣ", 0
    du "mУĒ", 0, "mуē", 0
    du "mПḠ", 0, "mпḡ", 0
    du "mШĪ", 0, "mшī", 0
    du "mНȲ", 0, "mнȳ", 0
    du "уФÆ", 1, "уфæ", 1, "УФÆ", 1, " ÆÆ", 0, " ææ", 0
    du "уЩŒ", 0, "ущœ", 0, "УЩŒ", 0
    du "щс©", 0
    du "щк®", 0
    du "ье™", 0
    du "рЕÞ", 0, "реþ", 0, "РЕÞ", 0
    du "ыЫẞ", 0, "ыыß", 0, "ЫЫẞ", 0
    du "еУÐ", 0, "еуð", 0, "ЕУÐ", 0
    du "гьµ", 0
    du "ьЩΩ", 0, "ьщω", 0, "ЬЩΩ", 0, "ЬщΩ", 0
    du "дФΑ", 0, "дфα", 0, "ДФΑ", 0, "ДфΑ", 0
    du "уИΒ", 0, "уиβ", 0, "УИΒ", 0, "УиΒ", 0
    du "уВΔ", 0, "увδ", 0, "УВΔ", 0, "УвΔ", 0
    du "шЫΣ", 0, "шыς", 0, "ШЫΣ", 0, "ШыΣ", 0
    du "шАΦ", 0, "шаφ", 0, "ШАΦ", 0, "ШаΦ", 0
    du "щз£", 0
    du "ус¢", 0
    du "ун¥", 0
    du "уу€", 0
    du "$у€", 0
    du "гк₽", 0
    du "шаﬁ", 0
    du "ааﬀ", 0
    du "даﬂ", 0
    du "тш∫", 0
    du "гаƒ", 0
    du "щщ•", 0
    du "уы§", 0
	du "фз¶", 0
    du "шзπ", 0
	du "йы√", 0
    du "ры", 0ADh, 0 ; soft hyphen
    du "дк", 202Eh, 0 ; right-to-left override
    du "кд", 202Dh, 0 ; left-to-right override
    du "ыр☭", 0
	du "лы☠", 0
	du "фк☢", 0
	du "ши☣", 0
	du "уз☮", 0
	du "шн☯", 0
	du "ты❄", 0
    du "фц⚠", 0
    du "ур♥", 0
	du "еы★", 0
    du "ьь¯", 0
    du "0щಠ", 0

    du "`й̀", 0 ; combining grave
    du "ёй̀", 0 ; combining grave (RU layout)
    du "'й́", 0 ; combining acute
    du "эй́", 0 ; combining acute (RU layout)
    du "^й̂", 0 ; combining circumflex
    du "6й̂", 0 ; combining circumflex (RU layout)
    du "~й̃", 0 ; combining tilde
    du "Ёй̃", 0 ; combining tilde (RU layout)
    du "mй̄", 0 ; combining macron
    du "ьй̄", 0 ; combining macron (RU layout)
    du "uй̆", 0 ; combining breve
    du "гй̆", 0 ; combining breve (RU layout)
    du ".й̇", 0 ; combining dot above
    du "юй̇", 0 ; combining dot above (RU layout)
    du ":й̈", 0 ; combining diaeresis
    du "жй̈", 0 ; combining diaeresis (RU layout)
    du "oй̊", 0 ; combining ring
    du "щй̊", 0 ; combining ring (RU layout)
    du '"й̋', 0 ; combining double acute
    du 'Эй̋', 0 ; combining double acute (RU layout)
    du "vй̌", 0 ; combining caron
    du "мй̌", 0 ; combining caron (RU layout)
    du ",й̧", 0 ; combining cedilla
    du "бй̧", 0 ; combining cedilla (RU layout)
    du "-й̶", 0 ; combining long stroke overlay
    du "/й̸", 0 ; combining solidus
    du "\й̸", 0 ; combining solidus

    du "2а½", 0
    du "3а⅓", 0
    du "4а¼", 0
    du "5а⅕", 0
    du "6а⅙", 0
    du "7а⅐", 0
    du "8а⅛", 0
    du "9а⅑", 0
    du "0а⅒", 0

    du "аи█", 0, "Аи▓", 0, "АИ▓", 0
    du "пи░", 0, "Пи▒", 0, "ПИ▒", 0
    du "ви▀", 0, "Ви▌", 0, "ВИ▌", 0
    du "ои▄", 0, "Ои▐", 0, "ОИ▐", 0
	du "*и✱", 0

    du "ми│", 0, "ри─", 0, "Ми┴", 0, "Ри┬", 0
    du "ди┘", 0, "ки└", 0, "Ди┤", 0, "Ки├", 0
    du "мИ║", 0, "рИ═", 0, "МИ╩", 0, "РИ╦", 0
    du "дИ╝", 0, "кИ╚", 0, "ДИ╣", 0, "КИ╠", 0
    du "чи┼", 0, "чИ╬", 0

    du "Бф←", 0, "Юф→", 0
    du "-ф↓", 0, "+ф↑", 0

    du "си", 20BFh, 0 ; Bitcoin sign

    dw 4 dup 0

palign

data export
export "kbdru-us_undead.dll", KbdLayerDescriptor, "KbdLayerDescriptor"
end data

palign

KbdLayerDescriptor:
if detected_32bit
    mov    eax,KbdTables
    cdq
else
    lea    rax,[KbdTables]
end if
    ret

palign

store_strings

section '.rsrc' data readable resource

directory RT_VERSION,versions
resource versions,1,LANG_NEUTRAL,version
versioninfo version,VOS_NT_WINDOWS32,VFT_DLL,VFT2_DRV_KEYBOARD,0,1200,\
    'CompanyName','by Grom PE. Adopted by sir_Andros',\
    'FileDescription','RU+US Customized Keyboard Layout',\
    'FileVersion','1.0',\
    'InternalName','kbdru-us_undead',\
    'LegalCopyright','Public domain. No rights reserved.',\
    'OriginalFilename','kbdru-us_undead.dll',\
    'ProductName','kbdasm',\
    'ProductVersion','1.0'

section '.reloc' data readable discardable fixups
