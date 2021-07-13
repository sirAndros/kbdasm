;https://www.reddit.com/r/AutoHotkey/comments/1qjf83/force_specific_program_to_use_caps/cddx3w7/
#Persistent ; Don't close when the auto-execute ends

; Listen for activation messages to all windows
DllCall("CoInitialize", "uint", 0)
if (!hWinEventHook := DllCall("SetWinEventHook", "uint", 0x3, "uint", 0x3, "uint", 0, "uint", RegisterCallback("HookProc"), "uint", 0, "uint", 0, "uint", 0))
{
    MsgBox, Error creating shell hook
    Exitapp
}

;MsgBox, Hook made
;DllCall("UnhookWinEvent", "uint", hWinEventHook) ; Remove the     message listening hook
return

; Handle the messages we hooked on to
HookProc(hWinEventHook, event, hwnd, idObject, idChild, dwEventThread, dwmsEventTime)
{
    SetCapsLockState, Off
}