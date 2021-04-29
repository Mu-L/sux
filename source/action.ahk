﻿#Include %A_ScriptDir%\source\common_const.ahk
#Include %A_ScriptDir%\source\search_plus.ahk
#Include %A_ScriptDir%\source\js_eval.ahk
#Include %A_ScriptDir%\source\snip_plus.ahk




HandleSearchSelectedText() {
	SearchPlus.ShowSelectedTextMenu()
}


StartSuxAhkWithWin() {
	msg_str := "Would you like to start sux with windows? Yes(Enable) or No(Disable)"
	MsgBox, 3,, %msg_str%
	IfMsgBox Cancel
		return

	Name_no_ext := "sux"
	Name := "sux.ahk"
	Dir = %A_ScriptDir%
	sux_ahk_file_path =  %A_ScriptFullPath%

	IfExist, %A_Startup%\%Name_no_ext%.lnk
	{
		IfMsgBox No
		{
			FileDelete, %A_Startup%\%Name_no_ext%.lnk
			MsgBox, %Name% removed from the Startup folder.
		}
		else {
			MsgBox, %Name% already added to Startup folder for auto-launch with Windows.
		}
	}
	Else
	{
		IfMsgBox Yes
		{
			FileCreateShortcut, "%sux_ahk_file_path%"
				, %A_Startup%\%Name_no_ext%.lnk
				, %Dir%   ; Line wrapped using line continuation
			MsgBox, %Name% added to Startup folder for auto-launch with Windows.
		}
	}
}


ScreenShot() {
	SnipPlus.AreaScreenShot()
}

ScreenShotAndSuspend() {
	SnipPlus.AreaScreenShotAndSuspend()
}

ReplaceCurrentLineText() {
	; result := (JsEval.eval("jsfunc_date()"))
	; MsgBox,,,%result%
	; run("jsfunc_date()")
	; return

	send, {Home}
	Sleep, 66
	send, +{End}
	ReplaceSelectedText()
	
	; ; Multi Monitor Support
	; SysGet, mon_cnt, MonitorCount
	; ; m(mon_cnt)
	; Loop, % mon_cnt
	; {
	; 	SysGet, Mon, Monitor, % A_Index
	; 	m(A_Index)
	; }
}

ReplaceSelectedText() {
	global STR_REPLACE_CONF_REGISTER_MAP
	; store the number of replacements that occurred (0 if none).
	replace_sum := 0

	ClipSaved := ClipboardAll   ; Save the entire clipboard to a variable of your choice.
	; ... here make temporary use of the clipboard, such as for pasting Unicode text via Transform Unicode ...
	; Sleep, 66
	; Send, ^a
	; Sleep, 66
	; Send, ^c
	Clipboard := ""
    SendInput, ^{insert}
    ClipWait, 0.1
	; Sleep, 66
	; Read from the array:
	; Loop % Array.MaxIndex()   ; More traditional approach.
	if(!ErrorLevel) {
		for key, value in STR_REPLACE_CONF_REGISTER_MAP ; Enumeration is the recommended approach in most cases.
		{
			cur_replace_cnt := 0
			; Using "Loop", indices must be consecutive numbers from 1 to the number
			; of elements in the array (or they must be calculated within the loop).
			; MsgBox % "Element number " . A_Index . " is " . Array[A_Index]
			; Using "for", both the index (or "key") and its associated value
			; are provided, and the index can be *any* value of your choosing.
			; m(key "//" value)
			Clipboard := StrReplace(Clipboard, key, value, cur_replace_cnt)
			replace_sum += cur_replace_cnt
		}
		; Sleep, 66
		if replace_sum != 0
			Send, ^v
		else
			Send, {Right}
	}
	; Sleep, 66
	Clipboard := ClipSaved   ; Restore the original clipboard. Note the use of Clipboard (not ClipboardAll).
	ClipSaved := ""   ; Free the memory in case the clipboard was very large.
}

MoveWindowToLeftSide() {
	send, #{Left}
}

MoveWindowToRightSide() {
	send, #{Right}
}

OpenFileExplorer() {
	run explorer.exe
}

OpenActionCenter() {
	send, #a
}

CloseCurrentWindow() {
	send, !{F4}
}

GoTop() {
	send, ^{Home}
}

GoBottom() {
	send, ^{End}
}

GoBack() {
	send, !{Left}
}

GoForward() {
	send, !{Right}
}

LockPc() {
	send, #l
}

OpenTaskView() {
	send, #{Tab}
}

VolumeMute() {
	Send {volume_mute}
}

VolumeUp() {
	Send {volume_up}
}

VolumeDown() {
	Send {volume_down}
}

GotoNextDesktop() {
	send, ^#{Right}
}

GotoPreDesktop() {
	send, ^#{Left}
}

RefreshTab() {
	send {F5}
}

ReopenLastTab() {
	send ^+t
}

GotoPreApp() {
	send !{Tab}
}

JumpToPrevTab() {
	ActivateWindowsUnderCursor()
	Send {LControl Down}{LShift Down}
	Send, {Tab}
	Sleep, 111
	Send {LControl Up}{LShift Up}
}

JumpToNextTab() {
	ActivateWindowsUnderCursor()
	Send {LControl Down}
	Send, {Tab}
	Sleep, 111
	Send {LControl Up}
}

SwitchCapsState() {
	; SetCapsLockState % !GetKeyState("CapsLock", "T")  ; Toggles CapsLock to its opposite state.
    GetKeyState, CapsLockState, CapsLock, T                              ;|
    if CapsLockState = D                                                 ;|
        SetCapsLockState, AlwaysOff                                      ;|
    else
    {
        SetCapsLockState, AlwaysOn
    }
}


SwitchInputMethodAndDeleteLeft() {
	global MULTI_HIT_DECORATOR
	global keyboard_double_click_timeout
	cur_key := StrReplace(A_ThisHotkey, MULTI_HIT_DECORATOR)
	; cur_key := StrReplace(A_ThisHotkey, "~")
	if (A_PriorHotkey <> A_ThisHotkey or A_TimeSincePriorHotkey > keyboard_double_click_timeout)
	; if (A_PriorHotkey != "~Alt" or A_TimeSincePriorHotkey > keyboard_double_click_timeout)
	{
		; Too much time between presses, so this isn't a double-press.
		Send, ^{Space}
		; ToolTipWithTimer(A_PriorKey)  ; LAlt
		; ToolTipWithTimer(A_ThisHotkey)  ; ~alt
		; ToolTipWithTimer(A_PriorHotkey)  ; ~alt
		KeyWait, % cur_key ; Wait for the key to be released.
		; KeyWait, % A_ThisHotkey ; Wait for the key to be released.
		; KeyWait, %A_PriorHotkey%  ; Wait for the key to be released.
		; KeyWait, Alt  ; Wait for the key to be released.
		; ToolTipWithTimer(A_PriorKey)
		return
	}
	; Send, ^{Space}
	Send, ^+{Left}
	; Sleep, 66
	Send, {Del}
	return
}


MaxMinWindow() {
	ActivateWindowsUnderCursor()
	; ; OutputVar is made blank if no matching window exists; otherwise, it is set to one of the following numbers:
	; ; -1: The window is minimized (WinRestore can unminimize it).
	; ; 1: The window is maximized (WinRestore can unmaximize it).
	; ; 0: The window is neither minimized nor maximized.
	WinGet,S,MinMax,A
	if S=0
		WinMaximize, A
	else if S=1
		WinMinimize, A
	; else if S=-1
	;     WinRestore, A
}

MaxWindow() {
	ActivateWindowsUnderCursor()
	; WinGet,S,MinMax,A
	WinMaximize, A
}

MinWindow() {
	ActivateWindowsUnderCursor()
	; WinGet,S,MinMax,A
	WinMinimize, A
}

ReloadSux() {
	Reload
}



SimulateClickDown() {
	SetDefaultMouseSpeed, 0 ; Move the mouse instantly.
	SetMouseDelay, 0
	fake_lb_down = 1
	Click Down
	Hotkey, RButton, SUB_TILDE_RBUTTON
	Hotkey, RButton, On
}


SUB_TILDE_RBUTTON:
	ClickUpIfLbDown()
	MouseClick, Right
	Return
