="utf8"
; kbdasm by Grom PE. Public domain.
; kbd_us-ru_undead_colemak-dh - US Colemak-DH/RU hybrid keyboard layout with Caps Lock set to switch
;                  languages and "undead keys" for additional symbols

include "includes/detect_%arch%.inc"

if SYSTEM_64BIT
  format PE64 DLL native 5.0 at 5ffffff0000h on "nul" as "dll" ; Build for 64-bit Windows
else
  format PE DLL native 5.0 at 5fff0000h on "nul" as "dll" ; Build for 32-bit Windows or WOW64
end if

TYPEWRITER = 1 ; Set to 1 to swap 1234567890 and !@#$%^&*() when CapsLock is OFF
TYPEWRITER_ON_CAPS = 1 ; Set to 1 to swap 1234567890 and !@#$%^&*() when CapsLock is ON
PROGRAMMER = 1 ; Swap "[","]" with "{","}"
UNDERSCORE_PRIORITY = 0 ; Swap "-" with "_"

MAKE_DLL equ 1

include "includes/base.inc"

WOW64 = 0 ; Use when assembling for 32-bit subsystem for 64-bit OS (Is this ever needed?)
USE_LIGATURES = 0 ; There is a bug in Firefox, if ligatures contain more than
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
    vkrow4 VK_GRAVE,      SGCAPS, "`",      "~",      "`",      "≈"
    vkrow4 -1,            0,      "ё",      "Ё",      WCH_NONE, WCH_NONE
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
    vkrow4 "2",           SGCAPS, "@",      "2",      "@",      "²"
else
    vkrow4 "2",           SGCAPS, "2",      "@",      "@",      "²"
end if
if TYPEWRITER_ON_CAPS
    vkrow4 "2",           0,      '"',      '2',      WCH_NONE, WCH_NONE
else
    vkrow4 "2",           0,      '2',      '"',      WCH_NONE, WCH_NONE
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
    vkrow4 "4",           SGCAPS, "$",      "4",      "$",      "£"
else
    vkrow4 "4",           SGCAPS, "4",      "$",      "$",      "£"
end if
if TYPEWRITER_ON_CAPS
    vkrow4 "4",           0,      ";",      "4",      WCH_NONE, "₽"
else
    vkrow4 "4",           0,      "4",      ";",      WCH_NONE, "₽"
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
    vkrow4 "6",           SGCAPS, "^",      "6",      "^",      "↑"
else
    vkrow4 "6",           SGCAPS, "6",      "^",      "^",      "↑"
end if
if TYPEWRITER_ON_CAPS
    vkrow4 -1,            0,      ":",      "6",      WCH_NONE, WCH_NONE
else
    vkrow4 -1,            0,      "6",      ":",      WCH_NONE, WCH_NONE
end if
if TYPEWRITER
    vkrow4 "7",           SGCAPS, "&",      "7",      "&",      "＆"
else
    vkrow4 "7",           SGCAPS, "7",      "&",      "&",      "＆"
end if
if TYPEWRITER_ON_CAPS
    vkrow4 "7",           0,      "?",      "7",      WCH_NONE, WCH_NONE
else
    vkrow4 "7",           0,      "7",      "?",      WCH_NONE, WCH_NONE
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
if UNDERSCORE_PRIORITY
    vkrow4 VK_MINUS,      SGCAPS, "_",      "-",      "–",      "—"
else
    vkrow4 VK_MINUS,      SGCAPS, "-",      "_",      "–",      "—"
end if
    vkrow4 VK_MINUS,      0,      "-",      "_",      "–",      "—"
    vkrow4 VK_EQUALS,     0,      "=",      "+",      "≠",      "±"
    vkrow4 "Q",           SGCAPS, "q",      "Q",      WCH_DEAD, WCH_DEAD
    vkrow4 "Q",           0,      "й",      "Й",      "q",      "Q"
    vkrow4 "W",           SGCAPS, "w",      "W",      WCH_DEAD, WCH_DEAD
    vkrow4 "W",           0,      "ц",      "Ц",      "w",      "W"
    vkrow4 "E",           SGCAPS, "f",      "F",      WCH_DEAD, WCH_DEAD
    vkrow4 "E",           0,      "у",      "У",      "e",      "E"
    vkrow4 "R",           SGCAPS, "p",      "P",      WCH_DEAD, WCH_DEAD
    vkrow4 "R",           0,      "к",      "К",      "r",      "R"
    vkrow4 "T",           SGCAPS, "b",      "B",      WCH_DEAD, WCH_DEAD
    vkrow4 "T",           0,      "е",      "Е",      "t",      "T"
    vkrow4 "Y",           SGCAPS, "j",      "J",      WCH_DEAD, WCH_DEAD
    vkrow4 "Y",           0,      "н",      "Н",      "y",      "Y"
    vkrow4 "U",           SGCAPS, "l",      "L",      WCH_DEAD, WCH_DEAD
    vkrow4 "U",           0,      "г",      "Г",      "u",      "U"
    vkrow4 "I",           SGCAPS, "u",      "U",      WCH_DEAD, WCH_DEAD
    vkrow4 "I",           0,      "ш",      "Ш",      "i",      "I"
    vkrow4 "O",           SGCAPS, "y",      "Y",      WCH_DEAD, WCH_DEAD
    vkrow4 "O",           0,      "щ",      "Щ",      "o",      "O"
    vkrow4 "P",           SGCAPS, ";",      ":",      WCH_DEAD, WCH_DEAD
    vkrow4 "P",           0,      "з",      "З",      "p",      "P"
    vkrow4 "A",           SGCAPS, "a",      "A",      WCH_DEAD, WCH_DEAD
    vkrow4 "A",           0,      "ф",      "Ф",      "a",      "A"
    vkrow4 "S",           SGCAPS, "r",      "R",      WCH_DEAD, WCH_DEAD
    vkrow4 "S",           0,      "ы",      "Ы",      "s",      "S"
    vkrow4 "D",           SGCAPS, "s",      "S",      WCH_DEAD, WCH_DEAD
    vkrow4 "D",           0,      "в",      "В",      "d",      "D"
    vkrow4 "F",           SGCAPS, "t",      "T",      WCH_DEAD, WCH_DEAD
    vkrow4 "F",           0,      "а",      "А",      "f",      "F"
    vkrow4 "G",           SGCAPS, "g",      "G",      WCH_DEAD, WCH_DEAD
    vkrow4 "G",           0,      "п",      "П",      "g",      "G"
    vkrow4 "H",           SGCAPS, "m",      "M",      WCH_DEAD, WCH_DEAD
    vkrow4 "H",           0,      "р",      "Р",      "h",      "H"
    vkrow4 "J",           SGCAPS, "n",      "N",      WCH_DEAD, WCH_DEAD
    vkrow4 "J",           0,      "о",      "О",      "j",      "J"
    vkrow4 "K",           SGCAPS, "e",      "E",      WCH_DEAD, WCH_DEAD
    vkrow4 "K",           0,      "л",      "Л",      "k",      "K"
    vkrow4 "L",           SGCAPS, "i",      "I",      WCH_DEAD, WCH_DEAD
    vkrow4 "L",           0,      "д",      "Д",      "l",      "L"
    vkrow4 VK_SEMICOLON,  SGCAPS, "o",      "O",      "°",      "¶"
    vkrow4 -1,            0,      "ж",      "Ж",      WCH_NONE, WCH_NONE
    vkrow4 VK_APOSTROPHE, SGCAPS, "'",      '"',      "'",      "́" ; combining acute
    vkrow4 -1,            0,      "э",      'Э',      WCH_NONE, WCH_NONE
    vkrow4 "Z",           SGCAPS, "z",      "Z",      WCH_DEAD, WCH_DEAD
    vkrow4 "Z",           0,      "я",      "Я",      "z",      "Z"
    vkrow4 "X",           SGCAPS, "x",      "X",      WCH_DEAD, WCH_DEAD
    vkrow4 "X",           0,      "ч",      "Ч",      "x",      "X"
    vkrow4 "C",           SGCAPS, "c",      "C",      WCH_DEAD, WCH_DEAD
    vkrow4 "C",           0,      "с",      "С",      "c",      "C"
    vkrow4 "V",           SGCAPS, "d",      "D",      WCH_DEAD, WCH_DEAD
    vkrow4 "V",           0,      "м",      "М",      "v",      "V"
    vkrow4 "B",           SGCAPS, "v",      "V",      WCH_DEAD, WCH_DEAD
    vkrow4 "B",           0,      "и",      "И",      "b",      "B"
    vkrow4 "N",           SGCAPS, "k",      "K",      WCH_DEAD, WCH_DEAD
    vkrow4 "N",           0,      "т",      "Т",      "n",      "N"
    vkrow4 "M",           SGCAPS, "h",      "H",      WCH_DEAD, WCH_DEAD
    vkrow4 "M",           0,      "ь",      "Ь",      "m",      "M"
    vkrow4 VK_COMMA,      SGCAPS, ",",      "<",      "<",      "≤"
    vkrow4 -1,            0,      "б",      "Б",      WCH_NONE, WCH_NONE
    vkrow4 VK_PERIOD,     SGCAPS, ".",      ">",      ">",      "≥"
    vkrow4 -1,            0,      "ю",      "Ю",      WCH_NONE, WCH_NONE
    vkrow4 VK_SLASH,      SGCAPS, "/",      "?",      "¿",      WCH_LGTR
    vkrow4 VK_SLASH,      0,      ".",      ",",      WCH_NONE, WCH_NONE
    dw 0, 0, 4 dup 0

palign

vk2wchar5:
if PROGRAMMER
    vkrow5 VK_LBRACKET,  SGCAPS, "{", "[", "[",      "{",      01Bh
else
    vkrow5 VK_LBRACKET,  SGCAPS, "[", "{", "[",      "{",      01Bh
end if
    vkrow5 VK_LBRACKET,  0,      "х", "Х", WCH_NONE, WCH_NONE, WCH_NONE

if PROGRAMMER
    vkrow5 VK_RBRACKET,  SGCAPS, "}", "]", "]",      "}",      01Dh
else
    vkrow5 VK_RBRACKET,  SGCAPS, "]", "}", "]",      "}",      01Dh
end if
    vkrow5 VK_RBRACKET,  0,      "ъ", "Ъ", WCH_NONE, WCH_NONE, WCH_NONE

    vkrow5 VK_BACKSLASH, SGCAPS, "\", "|", "|",      "¬",      01Ch
    vkrow5 VK_BACKSLASH, 0,      "\", "/", WCH_NONE, WCH_NONE, WCH_NONE
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
    du "'AÁ", 0, "'aá", 0
    du "'ÆǼ", 0, "'æǽ", 0
    du "'CĆ", 0, "'cć", 0
    du "'KÉ", 0, "'ké", 0
    du "'EÉ", 0, "'eé", 0
    du "'GǴ", 0, "'gǵ", 0
    du "'LÍ", 0, "'lí", 0
    du "'NḰ", 0, "'nḱ", 0
    du "'UĹ", 0, "'uĺ", 0
    du "'HḾ", 0, "'hḿ", 0
    du "'JŃ", 0, "'jń", 0
    du "':Ó", 0, "';ó", 0
    du "'ØǾ", 0, "'øǿ", 0
    du "'RṔ", 0, "'rṕ", 0
    du "'SŔ", 0, "'sŕ", 0
    du "'DŚ", 0, "'dś", 0
    du "'IÚ", 0, "'iú", 0
    du "'WẂ", 0, "'wẃ", 0
    du "'OÝ", 0, "'oý", 0
    du "'ZŹ", 0, "'zź", 0
    du "эAÁ", 0, "эaá", 0
    du "эÆǼ", 0, "эæǽ", 0
    du "эCĆ", 0, "эcć", 0
    du "эEÉ", 0, "эeé", 0
    du "эGǴ", 0, "эgǵ", 0
    du "эIÍ", 0, "эií", 0
    du "эKḰ", 0, "эkḱ", 0
    du "эLĹ", 0, "эlĺ", 0
    du "эMḾ", 0, "эmḿ", 0
    du "эNŃ", 0, "эnń", 0
    du "эOÓ", 0, "эoó", 0
    du "эØǾ", 0, "эøǿ", 0
    du "эPṔ", 0, "эpṕ", 0
    du "эRŔ", 0, "эrŕ", 0
    du "эSŚ", 0, "эsś", 0
    du "эUÚ", 0, "эuú", 0
    du "эWẂ", 0, "эwẃ", 0
    du "эYÝ", 0, "эyý", 0
    du "эZŹ", 0, "эzź", 0
    du '"OŐ', 0, '"oő', 0
    du '"UŰ', 0, '"uű', 0
    du 'ЭOŐ', 0, 'Эoő', 0
    du 'ЭUŰ', 0, 'Эuű', 0
    du "oAÅ", 0, "oaå", 0
    du "oIŮ", 0, "oiů", 0
    du "щAÅ", 0, "щaå", 0
    du "щUŮ", 0, "щuů", 0
    du ".AȦ", 0, ".aȧ", 0
    du ".TḂ", 0, ".tḃ", 0
    du ".CĊ", 0, ".cċ", 0
    du ".VḊ", 0, ".vḋ", 0
    du ".KĖ", 0, ".kė", 0
    du ".EḞ", 0, ".eḟ", 0
    du ".GĠ", 0, ".gġ", 0
    du ".MḢ", 0, ".mḣ", 0
    du ".Lİ", 0, ".lı", 0
    du ".HṀ", 0, ".hṁ", 0
    du ".JṄ", 0, ".jṅ", 0
    du ".:Ȯ", 0, ".;ȯ", 0
    du ".RṖ", 0, ".rṗ", 0
    du ".SṘ", 0, ".sṙ", 0
    du ".DṠ", 0, ".dṡ", 0
    du ".FṪ", 0, ".fṫ", 0
    du ".WẆ", 0, ".wẇ", 0
    du ".XẊ", 0, ".xẋ", 0
    du ".OẎ", 0, ".oẏ", 0
    du ".ZŻ", 0, ".zż", 0
    du ':AÄ', 0, ':aä', 0
    du ':KË', 0, ':kë', 0
    du ':ЕЁ', 0, ':её', 0 ; rus
    du ':MḦ', 0, ':mḧ', 0
    du ':LÏ', 0, ':lï', 0
    du '::Ö', 0, ':;ö', 0
    du ':IÜ', 0, ':iü', 0
    du ':WẄ', 0, ':wẅ', 0
    du ':XẌ', 0, ':xẍ', 0
    du ':OŸ', 0, ':oÿ', 0
    du 'ЖAÄ', 0, 'Жaä', 0
    du 'ЖEË', 0, 'Жeë', 0
    du 'ЖЕЁ', 0, 'Жеё', 0 ; rus
    du 'ЖHḦ', 0, 'Жhḧ', 0
    du 'ЖIÏ', 0, 'Жiï', 0
    du 'ЖOÖ', 0, 'Жoö', 0
    du 'ЖUÜ', 0, 'Жuü', 0
    du 'ЖWẄ', 0, 'Жwẅ', 0
    du 'ЖXẌ', 0, 'Жxẍ', 0
    du 'ЖYŸ', 0, 'Жyÿ', 0
    du "^AÂ", 0, "^aâ", 0
    du "^CĈ", 0, "^cĉ", 0
    du "^KÊ", 0, "^kê", 0
    du "^GĜ", 0, "^gĝ", 0
    du "^MĤ", 0, "^mĥ", 0
    du "^LÎ", 0, "^lî", 0
    du "^YĴ", 0, "^yĵ", 0
    du "^:Ô", 0, "^;ô", 0
    du "^DŜ", 0, "^dŝ", 0
    du "^IÛ", 0, "^iû", 0
    du "^WŴ", 0, "^wŵ", 0
    du "^OŶ", 0, "^oŷ", 0
    du "^ZẐ", 0, "^zẑ", 0
    du "vAǍ", 0, "vaǎ", 0
    du "vCČ", 0, "vcč", 0
    du "VCČ", 0, "Vcč", 0
    du "vVĎ", 0, "vvď", 0
    du "VVĎ", 0, "Vvď", 0
    du "vKĚ", 0, "vkě", 0
    du "VKĚ", 0, "Vkě", 0
    du "vEĚ", 0, "veě", 0
    du "VEĚ", 0, "Veě", 0
    du "bEĚ", 0, "beě", 0
    du "BEĚ", 0, "Beě", 0
    du "vGǦ", 0, "vgǧ", 0
    du "vMȞ", 0, "vmȟ", 0
    du "vLǏ", 0, "vlǐ", 0
    du "vNǨ", 0, "vnǩ", 0
    du "vUĽ", 0, "vuľ", 0
    du "vJŇ", 0, "vjň", 0
    du "VJŇ", 0, "Vjň", 0
    du "v:Ǒ", 0, "v;ǒ", 0
    du "vSŘ", 0, "vsř", 0
    du "VSŘ", 0, "Vsř", 0
    du "vDŠ", 0, "vdš", 0
    du "VDŠ", 0, "Vdš", 0
    du "vFŤ", 0, "vfť", 0
    du "VFŤ", 0, "Vfť", 0
    du "vIǓ", 0, "viǔ", 0
    du "vZŽ", 0, "vzž", 0
    du "VZŽ", 0, "Vzž", 0
    du "мAǍ", 0, "мaǎ", 0
    du "мCČ", 0, "мcč", 0
    du "МCČ", 0, "Мcč", 0
    du "мDĎ", 0, "мdď", 0
    du "МDĎ", 0, "Мdď", 0
    du "мEĚ", 0, "мeě", 0
    du "МEĚ", 0, "Мeě", 0
    du "мGǦ", 0, "мgǧ", 0
    du "мHȞ", 0, "мhȟ", 0
    du "мIǏ", 0, "мiǐ", 0
    du "мKǨ", 0, "мkǩ", 0
    du "мLĽ", 0, "мlľ", 0
    du "мNŇ", 0, "мnň", 0
    du "мOǑ", 0, "мoǒ", 0
    du "мRŘ", 0, "мrř", 0
    du "МRŘ", 0, "Мrř", 0
    du "мSŠ", 0, "мsš", 0
    du "МSŠ", 0, "Мsš", 0
    du "мTŤ", 0, "мtť", 0
    du "МTŤ", 0, "Мtť", 0
    du "мUǓ", 0, "мuǔ", 0
    du "мZŽ", 0, "мzž", 0
    du "МZŽ", 0, "Мzž", 0
    du "uAĂ", 0, "uaă", 0
    du "uKĔ", 0, "ukĕ", 0
    du "uGĞ", 0, "ugğ", 0
    du "uLĬ", 0, "ulĭ", 0
    du "u:Ŏ", 0, "u;ŏ", 0
    du "uIŬ", 0, "uiŭ", 0
    du "`AÀ", 0, "`aà", 0
    du "`KÈ", 0, "`kè", 0
    du "`LÌ", 0, "`lì", 0
    du "`JǸ", 0, "`jǹ", 0
    du "`:Ò", 0, "`;ò", 0
    du "`IÙ", 0, "`iù", 0
    du "`WẀ", 0, "`wẁ", 0
    du "`OỲ", 0, "`oỳ", 0
    du "~AÃ", 0, "~aã", 0
    du "~KẼ", 0, "~kẽ", 0
    du "~LĨ", 0, "~lĩ", 0
    du "~JÑ", 0, "~jñ", 0
    du "~:Õ", 0, "~;õ", 0
    du "~IŨ", 0, "~iũ", 0
    du "~BṼ", 0, "~bṽ", 0
    du "~OỸ", 0, "~oỹ", 0
; ogonek:  ˛ Ąą    Ęę    Įį      Ǫǫ      Ųų
; cedilla: ¸   ÇçḐḑ  ĢģḨḩ  ĶķĻļŅņ  ŖŗŞşŢţ
    du ",AĄ", 0, ",aą", 0
    du ",CÇ", 0, ",cç", 0
    du ",DḐ", 0, ",dḑ", 0
    du ",EĘ", 0, ",eę", 0
    du ",GĢ", 0, ",gģ", 0
    du ",HḨ", 0, ",hḩ", 0
    du ",IĮ", 0, ",iį", 0
    du ",KĶ", 0, ",kķ", 0
    du ",LĻ", 0, ",lļ", 0
    du ",NŅ", 0, ",nņ", 0
    du ",OǪ", 0, ",oǫ", 0
    du ",RŖ", 0, ",rŗ", 0
    du ",SŞ", 0, ",sş", 0
    du ",TŢ", 0, ",tţ", 0
    du ",UŲ", 0, ",uų", 0
    du "/AȺ", 0, "/aⱥ", 0
    du "/BɃ", 0, "/bƀ", 0
    du "/CȻ", 0, "/cȼ", 0
    du "/DĐ", 0, "/dđ", 0
    du "/EɆ", 0, "/eɇ", 0
    du "/FꞘ", 0, "/fꞙ", 0
    du "/GǤ", 0, "/gǥ", 0
    du "/HĦ", 0, "/hħ", 0
    du "/IƗ", 0, "/iɨ", 0
    du "/JɈ", 0, "/jɉ", 0
    du "/KꝀ", 0, "/kꝁ", 0
    du "/LŁ", 0, "/lł", 0
    du "/:Ø", 1, "/;ø", 1, " ØØ", 0, " øø", 0
    du "\:Ø", 0, "\;ø", 0
    du "\ЩØ", 0, "\щø", 0
    du "/PⱣ", 0, "/pᵽ", 0
    du "/RɌ", 0, "/rɍ", 0
    du "/TŦ", 0, "/tŧ", 0
    du "/YɎ", 0, "/yɏ", 0
    du "/ZƵ", 0, "/zƶ", 0
    du "mAĀ", 0, "maā", 0
    du "mÆǢ", 0, "mæǣ", 0
    du "mEĒ", 0, "meē", 0
    du "mGḠ", 0, "mgḡ", 0
    du "mIĪ", 0, "miī", 0
    du "mYȲ", 0, "myȳ", 0
    du "eAÆ", 1, "eaæ", 1, "EAÆ", 1, " ÆÆ", 0, " ææ", 0
    du "eOŒ", 0, "eoœ", 0, "EOŒ", 0
    du "slᵢ", 0, "_kᵢ", 0
    du "syⱼ", 0, "_yⱼ", 0
    du "sjⁿ", 0, "^jⁿ", 0
    du "oc©", 0
    du "os®", 0
    du "mf™", 0
    du "hTÞ", 0, "htþ", 0, "HTÞ", 0
    du "sDẞ", 0, "sdß", 0, "SDẞ", 0
    du "tEÐ", 0, "teð", 0, "TEÐ", 0
    du "uhµ", 0
    du "m:Ω", 0, "m;ω", 0, "M:Ω", 0, "M;Ω", 0
    du "lAΑ", 0, "laα", 0, "LAΑ", 0, "LaΑ", 0
    du "eTΒ", 0, "etβ", 0, "ETΒ", 0, "EtΒ", 0
    du "eVΔ", 0, "evδ", 0, "EVΔ", 0, "EvΔ", 0
    du "iDΣ", 0, "idς", 0, "IDΣ", 0, "IdΣ", 0
    du "iEΦ", 0, "ieφ", 0, "IEΦ", 0, "IeΦ", 0
    du "or£", 0
    du "ec¢", 0
    du "eo¥", 0
    du "ek€", 0
    du "$k€", 0
    du "us₽", 0
    du "$s₽", 0
    du "ieﬁ", 0
    du "feﬀ", 0
    du "leﬂ", 0
    du "nl∫", 0
    du "ueƒ", 0
    du "o;•", 0
    du "rg°", 0
    du "ed§", 0
	du "ar¶", 0
    du "irπ", 0
	du "qd√", 0
    du "hd", 0ADh, 0 ; soft hyphen
    du "ls", 202Eh, 0 ; right-to-left override
    du "ru", 202Dh, 0 ; left-to-right override
    du "sm☭", 0
	du "kd☠", 0
	du "as☢", 0
	du "it☣", 0
	du "er☮", 0
	du "io☯", 0
	du "ns❄", 0
    du "aw⚠", 0
    du "em♥", 0
	du "td★", 0
	du "ah♂", 0
	du "ee♀", 0
    du "mh¯", 0
    du "0;ಠ", 0
    du "ct", 20BFh, 0 ; Bitcoin sign

    du "`q̀", 0 ; combining grave
    du "ёq̀", 0 ; combining grave (RU layout)
    du "'q́", 0 ; combining acute
    du "эq́", 0 ; combining acute (RU layout)
    du "^q̂", 0 ; combining circumflex
    du "6q̂", 0 ; combining circumflex (RU layout)
    du "~q̃", 0 ; combining tilde
    du "Ёq̃", 0 ; combining tilde (RU layout)
    du "hq̄", 0 ; combining macron
    du "ьq̄", 0 ; combining macron (RU layout)
    du "iq̆", 0 ; combining breve
    du "шq̆", 0 ; combining breve (RU layout)
    du ".q̇", 0 ; combining dot above
    du "юq̇", 0 ; combining dot above (RU layout)
    du "pq̈", 0 ; combining diaeresis
    du "зq̈", 0 ; combining diaeresis (RU layout)
    du ";q̊", 0 ; combining ring
    du "жq̊", 0 ; combining ring (RU layout)
    du '"q̋', 0 ; combining double acute
    du 'Эq̋', 0 ; combining double acute (RU layout)
    du "bq̌", 0 ; combining caron
    du "иq̌", 0 ; combining caron (RU layout)
    du ",q̧", 0 ; combining cedilla
    du "бq̧", 0 ; combining cedilla (RU layout)
    du "-q̶", 0 ; combining long stroke overlay
    du "/q̸", 0 ; combining solidus
    du "\q̸", 0 ; combining solidus
    du "*q⃰", 0 ; combining asterix
    du "xqͯ", 0 ; combining X
    du "чqͯ", 0 ; combining X (RU layout)
    du "_q͇", 0 ; combining double-underscore

; Fractions
    du "2f½", 0
    du "3f⅓", 0
    du "4f¼", 0
    du "5f⅕", 0
    du "6f⅙", 0
    du "7f⅐", 0
    du "8f⅛", 0
    du "9f⅑", 0
    du "0f⅒", 0

if TYPEWRITER
    du "@f½", 0
    du "#f⅓", 0
    du "$f¼", 0
    du "%f⅕", 0
    du "^f⅙", 0
    du "&f⅐", 0
    du "*f⅛", 0
    du "(f⅑", 0
    du ")f⅒", 0
end if
du "qf¾", 0

; Roman numbers
    du "1sⅠ", 0
    du "2sⅡ", 0
    du "3sⅢ", 0
    du "4sⅣ", 0
    du "5sⅤ", 0
    du "6sⅥ", 0
    du "7sⅦ", 0
    du "8sⅧ", 0
    du "9sⅨ", 0
    du "0sⅩ", 0

if TYPEWRITER
    du "!sⅠ", 0
    du "@sⅡ", 0
    du "#sⅢ", 0
    du "$sⅣ", 0
    du "%sⅤ", 0
    du "^sⅥ", 0
    du "&sⅦ", 0
    du "*sⅧ", 0
    du "(sⅨ", 0
    du ")sⅩ", 0
end if

    du "fb█", 0, "Fb▓", 0, "FB▓", 0
    du "gb░", 0, "Gb▒", 0, "GB▒", 0
    du "db▀", 0, "Db▌", 0, "DB▌", 0
    du "jb▄", 0, "Jb▐", 0, "JB▐", 0
	du "*b✱", 0

    du "vb│", 0, "hb─", 0, "Vb┴", 0, "Hb┬", 0
    du "lb┘", 0, "rb└", 0, "Lb┤", 0, "Rb├", 0
    du "vB║", 0, "hB═", 0, "VB╩", 0, "HB╦", 0
    du "lB╝", 0, "rB╚", 0, "LB╣", 0, "RB╠", 0
    du "xb┼", 0, "xB╬", 0

    du "<a←", 0, ">a→", 0
    du "-a↓", 0, "+a↑", 0
    du "ra↻", 0, "ia⇒", 0

    du "kh∀", 0, "eh∃", 0
    du "eh∄", 0, "oh∅", 0
    du "<h∠", 0, "vh∨", 0

    ; du "AAA", 0, "aaa", 0, "ФAA", 0, "фaa", 0
    ; du "BBB", 0, "bbb", 0, "ИBB", 0, "иbb", 0
    ; du "CCC", 0, "ccc", 0, "СCC", 0, "сcc", 0
    ; du "DDD", 0, "ddd", 0, "ВDD", 0, "вdd", 0
    ; du "EEE", 0, "eee", 0, "УEE", 0, "уee", 0
    ; du "FFF", 0, "fff", 0, "АFF", 0, "аff", 0
    ; du "GGG", 0, "ggg", 0, "ПGG", 0, "пgg", 0
    ; du "HHH", 0, "hhh", 0, "РHH", 0, "рhh", 0
    ; du "III", 0, "iii", 0, "ШII", 0, "шii", 0
    ; du "JJJ", 0, "jjj", 0, "ОJJ", 0, "оjj", 0
    ; du "KKK", 0, "kkk", 0, "ЛKK", 0, "лkk", 0
    ; du "LLL", 0, "lll", 0, "ДLL", 0, "дll", 0
    ; du "MMM", 0, "mmm", 0, "ЬMM", 0, "ьmm", 0
    ; du "NNN", 0, "nnn", 0, "ТNN", 0, "тnn", 0
    ; du "OOO", 0, "ooo", 0, "ЩOO", 0, "щoo", 0
    ; du "PPP", 0, "ppp", 0, "ЗPP", 0, "зpp", 0
    ; du "QQQ", 0, "qqq", 0, "ЙQQ", 0, "йqq", 0
    ; du "RRR", 0, "rrr", 0, "КRR", 0, "кrr", 0
    ; du "SSS", 0, "sss", 0, "ЫSS", 0, "ыss", 0
    ; du "TTT", 0, "ttt", 0, "ЕTT", 0, "еtt", 0
    ; du "UUU", 0, "uuu", 0, "ГUU", 0, "гuu", 0
    ; du "VVV", 0, "vvv", 0, "МVV", 0, "мvv", 0
    ; du "WWW", 0, "www", 0, "ЦWW", 0, "цww", 0
    ; du "XXX", 0, "xxx", 0, "ЧXX", 0, "чxx", 0
    ; du "YYY", 0, "yyy", 0, "НYY", 0, "нyy", 0
    ; du "ZZZ", 0, "zzz", 0, "ЯZZ", 0, "яzz", 0

    dw 4 dup 0

palign

data export
export "kbd_us-ru_undead_colemak-dh.dll", KbdLayerDescriptor, "KbdLayerDescriptor"
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
    'FileDescription','US+RU Colemak-DH Customized Keyboard Layout',\
    'FileVersion','1.0',\
    'InternalName','kbd_us-ru_undead_colemak-dh',\
    'LegalCopyright','Public domain. No rights reserved.',\
    'OriginalFilename','kbd_us-ru_undead_colemak-dh.dll',\
    'ProductName','kbdasm',\
    'ProductVersion','1.0'

section '.reloc' data readable discardable fixups
