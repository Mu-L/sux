﻿; Note: Save with encoding UTF-8 with BOM if possible.
; Notepad will save UTF-8 files with BOM automatically (even though it does not say so).
; Some editors however save without BOM, and then special characters look messed up in the AHK GUI.

; Initialize variable to keep track of the state of the GUI
; global gui_state := closed


if(A_ScriptName=="quick_entry.ahk") {
	ExitApp
}


; last_search_str = ""
; trim_gui_user_input = ""
current_selected_text = ""


; with this label, you can include this file on top of the file
Goto, SUB_CMD_WEB_SEARCH_FILE_END_LABEL

#Include %A_ScriptDir%\source\common_const.ahk
#Include %A_ScriptDir%\source\sux_core.ahk
#Include %A_ScriptDir%\source\util.ahk
#Include %A_ScriptDir%\source\snip_plus.ahk
#Include %A_ScriptDir%\source\translation.ahk
#Include %A_ScriptDir%\source\search_plus.ahk






class QuickEntry {

	static command_menu_pos_offset := 0
	static screenshot_menu_pos_offset := 0

	init() {
		; ; ; Esc一下, 不然第一次打开search_gui的阴影会有一个从淡到浓的bug
		; Send, {Esc}

		global WEB_SEARCH_TITLE_LIST
		global SHORTCUT_KEY_INDEX_ARR_LEFT

		ws_cnt := WEB_SEARCH_TITLE_LIST.Count()
		sk_l_cnt := SHORTCUT_KEY_INDEX_ARR_LEFT.Count()
		dec_cnt := (ws_cnt > sk_l_cnt) ? sk_l_cnt+1 : ws_cnt  ;; 因为有个"More Search", 所以是 sk_l_cnt+1
		dec_cnt += 1  ; 截图的菜单 和 search 之间有个分割线

		QuickEntry.screenshot_menu_pos_offset := dec_cnt

		dec_cnt += 5  ; 中间还有1个截图的菜单和1个变换文本和1个替换文本的菜单和1个翻译的菜单和1个分割线
		QuickEntry.command_menu_pos_offset := dec_cnt
	}

	
	ShowQuickEntryMenu() {
		search_gui_destroy()

		try {
			Menu, QuickEntry_Menu, DeleteAll
		}
		try {
			Menu, QuickEntry_Search_Menu_More, DeleteAll
		}
		try {
			Menu, QuickEntry_Command_Menu_More, DeleteAll
		}
		try {
			Menu, QuickEntry_TransformText_Detail_Menu, DeleteAll
		}

		global current_selected_text
		current_selected_text := GetCurSelectedText()
		if current_selected_text {
			sub_selected_text := lang("Selected") . ": " . SubStr(current_selected_text, 1, 2) . "..."
			; m(sub_selected_text)
			Menu, QuickEntry_Menu, Add, % sub_selected_text, Sub_Nothing
			Menu, QuickEntry_Menu, Disable, % sub_selected_text
			Menu, QuickEntry_Menu, Add
		}
		
		global WEB_SEARCH_TITLE_LIST
		global SHORTCUT_KEY_INDEX_ARR_LEFT
		shortcut_cnt_left := SHORTCUT_KEY_INDEX_ARR_LEFT.Count()
		for index, title in WEB_SEARCH_TITLE_LIST {
			if (index <= shortcut_cnt_left) {
				menu_shortcut_str := get_menu_shortcut_str(SHORTCUT_KEY_INDEX_ARR_LEFT, index, lang(title))
				; _cur_shortcut_str := SHORTCUT_KEY_INDEX_ARR_LEFT[index]
				; ;; 如果快捷键为空格的话, 得特殊处理
				; _cur_shortcut_str := _cur_shortcut_str == " " ? _cur_shortcut_str . "(" . lang("space") . ")" : _cur_shortcut_str
				; m(_cur_shortcut_str)
				;; 要为菜单项名称的某个字母加下划线, 在这个字母前加一个 & 符号. 当菜单显示出来时, 此项可以通过按键盘上对应的按键来选中.
				Menu, QuickEntry_Menu, Add, % menu_shortcut_str, QuickEntry_Search_Menu_Click
			}
			Else {
				Menu, QuickEntry_Search_Menu_More, Add, % lang(title), QuickEntry_Search_Menu_MoreClick
			}
		}
		if (WEB_SEARCH_TITLE_LIST.Count() > shortcut_cnt_left)
			Menu, QuickEntry_Menu, Add, % lang("More Search"), :QuickEntry_Search_Menu_More

		;;;;;; ScreenShot
		Menu, QuickEntry_Menu, Add  ;; 加个分割线
		Menu, QuickEntry_Menu, Add, % lang("ScreenShot && Suspend") . "`t&`t(" . lang("tab") . ")", QuickEntry_ScreenShot_Suspend_Menu_Click
		Menu, QuickEntry_Menu, Add, % lang("Translation") . "`t&f", QuickEntry_Translation_Menu_Click
		Menu, QuickEntry_Menu, Add, % lang("Replace Text") . "`t&r", QuickEntry_ReplaceText_Menu_Click

		;; transform text
		transform_text_arr := ["ABCD", "abcd", "|", "AbCd", "abCd", "|", "AB_CB", "ab_cd", "Ab_Cd", "ab_Cd", "|", "AB-CD", "ab-cd", "Ab-Cd", "ab-Cd"]
		for index, pattern in transform_text_arr {
			if (pattern == "|")
				Menu, QuickEntry_TransformText_Detail_Menu, Add
			else {
				; menu_shortcut_str := get_menu_shortcut_str(SHORTCUT_KEY_INDEX_ARR_LEFT_HAS_TAB, index, lang(pattern))
				Menu, QuickEntry_TransformText_Detail_Menu, Add, % index . ".`t" . pattern, QuickEntry_TransformText_Detail_Menu_click
			}
		}
		Menu, QuickEntry_Menu, Add, % lang("Transform Text") . "`t&g", :QuickEntry_TransformText_Detail_Menu

		;;;;;; command
		Menu, QuickEntry_Menu, Add  ;; 加个分割线
		global COMMAND_TITLE_LIST
		global SHORTCUT_KEY_INDEX_ARR_RIGHT
		shortcut_cnt_right := SHORTCUT_KEY_INDEX_ARR_RIGHT.Count()
		for index, title in COMMAND_TITLE_LIST {
			if (index <= shortcut_cnt_right) {
				menu_shortcut_str := get_menu_shortcut_str(SHORTCUT_KEY_INDEX_ARR_RIGHT, index, title)
				Menu, QuickEntry_Menu, Add, % menu_shortcut_str, QuickEntry_Command_Menu_Click
			}
			Else {
				Menu, QuickEntry_Command_Menu_More, Add, % title, QuickEntry_Command_Menu_MoreClick
			}
		}
		if (COMMAND_TITLE_LIST.Count() > shortcut_cnt_right)
			Menu, QuickEntry_Menu, Add, % lang("More Command"), :QuickEntry_Command_Menu_More

		Menu, QuickEntry_Menu, Show
	} 


	HandleCommand(command_title, cur_sel_text) 
	{
		global COMMAND_TITLE_2_ACTION_MAP
		if (COMMAND_TITLE_2_ACTION_MAP.HasKey(command_title))
		{
			if (command_title == "Everything" && cur_sel_text) {
				;;; everything search
				everything_exe_path := COMMAND_TITLE_2_ACTION_MAP["Everything"][1]
				run, %everything_exe_path%
				WinWaitActive, ahk_exe Everything.exe, , 2.222
				if ErrorLevel
					MsgBox,,, please install Everything and set its path in conf.user.yaml
				else if (cur_sel_text) {
					; Send, {Blind}{Text}%cur_sel_text%
					PasteContent(cur_sel_text)
				}
				; m("xxd")
				return
			}

			USE_CURRENT_DIRECTORY_PATH_CMDs := {"cmd" : "C: && cd %UserProfile%\Desktop", "git" : "cd ~/Desktop"}
			use_cur_path := USE_CURRENT_DIRECTORY_PATH_CMDs.HasKey(command_title)
			IfWinActive, ahk_exe explorer.exe ahk_class CabinetWClass  ; from file explorer
			{
				if (use_cur_path) {
					Send, !d
					final_cmd_str := StringJoin(" ", COMMAND_TITLE_2_ACTION_MAP[command_title]*)
					; Send, {Blind}{Text}%final_cmd_str%
					PasteContent(final_cmd_str)
					Send, {Enter}
					return
				}
			}
			run(COMMAND_TITLE_2_ACTION_MAP[command_title])
			if (use_cur_path) {
				file_path_str := COMMAND_TITLE_2_ACTION_MAP[command_title][1]  ; just like: "C:\Program Files\Git\bin\bash.exe"
				; m(file_path_str)
				RegExMatch(file_path_str, "([^<>\/\\|:""\*\?]+)\.\w+", file_name)  ; file_name just like: "bash.exe""
				; m(file_name)
				WinWaitActive, ahk_exe %file_name%,, 2222
				if !ErrorLevel {
					cd_user_desktop_cmd_input := USE_CURRENT_DIRECTORY_PATH_CMDs[command_title]
					; Send, {Blind}{Text}%cd_user_desktop_cmd_input%
					PasteContent(cd_user_desktop_cmd_input)
					Send, {Enter}
				}
			}
		}
	}

}





Sub_Nothing:
	Return


QuickEntry_Search_Menu_Click:
	dec_cnt := current_selected_text ? 2 : 0
	SearchPlus.cur_sel_search_title := WEB_SEARCH_TITLE_LIST[A_ThisMenuItemPos - dec_cnt]
	; if current_selected_text
	; 	SearchPlus.HandleSearch(current_selected_text)
	; else
		SearchPlus.search_gui_spawn(current_selected_text)
	Return

QuickEntry_Search_Menu_MoreClick:
	SearchPlus.cur_sel_search_title := WEB_SEARCH_TITLE_LIST[SHORTCUT_KEY_INDEX_ARR_LEFT.Count() + A_ThisMenuItemPos]
	; if current_selected_text
	; 	SearchPlus.HandleSearch(current_selected_text)
	; else
		SearchPlus.search_gui_spawn(current_selected_text)
	Return


QuickEntry_Command_Menu_Click:
	dec_cnt := (current_selected_text ? 2 : 0) + QuickEntry.command_menu_pos_offset
	search_title := COMMAND_TITLE_LIST[A_ThisMenuItemPos - dec_cnt]
	QuickEntry.HandleCommand(search_title, current_selected_text)
	Return


QuickEntry_Command_Menu_MoreClick:
	search_title := COMMAND_TITLE_LIST[SHORTCUT_KEY_INDEX_ARR_RIGHT.Count() + A_ThisMenuItemPos]
	QuickEntry.HandleCommand(search_title, current_selected_text)
	Return


QuickEntry_ScreenShot_Suspend_Menu_Click:
	dec_cnt := (current_selected_text ? 2 : 0) + QuickEntry.screenshot_menu_pos_offset
	if (A_ThisMenuItemPos - dec_cnt == 1) {
		SnipPlus.AreaScreenShot()
	}
	Return



QuickEntry_Translation_Menu_Click:
	TranslateSeletedText(current_selected_text)
	Return


QuickEntry_TransformText_Detail_Menu_click:
	st := current_selected_text
	if (!st) {
		SelectCurrentWord()
		st := GetCurSelectedText()
		if (!st) {
			ToolTipWithTimer(lang("Nothing selected") . ".")
			Return
		}
	}
	
	delimiters_arr := ["_", "-"]
	if (A_ThisMenuItemPos == 1) {
		for _i, deli in delimiters_arr
			st := StrReplace(st, deli, "")
		StringUpper, st, st
	}
	else if (A_ThisMenuItemPos == 2) {
		for _i, deli in delimiters_arr
			st := StrReplace(st, deli, "")
		StringLower, st, st
	}
	else if (A_ThisMenuItemPos >= 4 || A_ThisMenuItemPos <=15) {
		if (Instr(st, "-") || Instr(st, "_")) {
			st_arr := StrSplit(st, delimiters_arr)
		}
		else {
			for _i, deli in delimiters_arr
				temp_st := StrReplace(st, deli, "")
			if temp_st is upper
			{
				ToolTipWithTimer(lang("Can not separate words") . ".")	
				return
			}
			else if temp_st is lower
			{
				ToolTipWithTimer(lang("Can not separate words") . ".")	
				return
			}
			else {
				st_arr := []
				last_start_i := 1
				Loop, parse, st
				{
					if A_LoopField is upper
					{
						st_arr.Push(SubStr(st, last_start_i, A_Index-last_start_i))
						last_start_i := A_Index
					}
				}
				st_arr.Push(SubStr(st, last_start_i, StrLen(st)-last_start_i))
			}
		}

		st := ""
		deli_map := {1: "", 2: "", 4: "", 5: "", 7: "_", 8: "_", 9: "_", 10: "_", 12: "-", 13: "-", 14: "-", 15: "-"}

		first_letter_lower_case_map := {5: "", 10: "", 15: ""}
		title_case_map := {4: "", 5: "", 9: "", 10: "",  14: "", 15: ""}
		lower_case_map := {2: "", 8: "", 13: ""}
		upper_case_map := {1: "", 7: "", 12: ""}

		cur_delimiter := deli_map[A_ThisMenuItemPos]
		for index, _single_w in st_arr {
			if (st != "")
				st .= cur_delimiter
			if (index == 1 && first_letter_lower_case_map.HasKey(A_ThisMenuItemPos))
				StringLower, _single_w, _single_w
			else if (title_case_map.HasKey(A_ThisMenuItemPos))
				StringUpper, _single_w, _single_w, T
			else if (lower_case_map.HasKey(A_ThisMenuItemPos))
				StringLower, _single_w, _single_w
			else if (upper_case_map.HasKey(A_ThisMenuItemPos))
				StringUpper, _single_w, _single_w

			st .= _single_w
		}
	}

	PasteContent(st)
	Return



QuickEntry_ReplaceText_Menu_Click:
	if (!current_selected_text) {
		send, {Home}
		Sleep, 66
		send, +{End}
	}
	
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
    ClipWait, 0.6
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
		Sleep, 66
		if replace_sum != 0
			SafePaste()
		else
			Send, {Right}
	}
	; Sleep, 66
	Clipboard := ClipSaved   ; Restore the original clipboard. Note the use of Clipboard (not ClipboardAll).
	ClipSaved := ""   ; Free the memory in case the clipboard was very large.
	Return



; //////////////////////////////////////////////////////////////////////////
SUB_CMD_WEB_SEARCH_FILE_END_LABEL:
	temp_cws := "blabla"
