﻿
if(A_ScriptName=="tray_menu.ahk") {
	ExitApp
}

; with this label, you can include this file on top of the file
Goto, SUB_TRAY_MENU_FILE_END_LABEL


#Include %A_ScriptDir%\source\sux_core.ahk
#Include %A_ScriptDir%\source\action.ahk



class TrayMenu
{
	static ASSET_DIR := "app_data/"
	static icon_default := TrayMenu.ASSET_DIR "sux_default.ico"
	static icon_disable := TrayMenu.ASSET_DIR "sux_disable.ico"
	static donate_img_alipay := TrayMenu.ASSET_DIR "donate_alipay.png"
	static donate_img_wechat := TrayMenu.ASSET_DIR "donate_wechat.png"


	init() {
		this.update_tray_menu()
		; this.SetAutorun("config")
		this.SetHotCorner("config")
		this.SetLimitModeInFullScreen("config")
		this.SetDisableWin10AutoUpdate("config")
	}

	SetDisableWin10AutoUpdate(act="toggle")
	{
		cfg := SuxCore.GetIniConfig(INI_DISABLE_WIN10_AUTO_UPDATE_SWITCH, SuxCore.Default_disable_win10_auto_update_switch)
		switch := (act="config")? cfg : act
		switch := (act="toggle")? !cfg : switch
		SuxCore.SetIniConfig(INI_DISABLE_WIN10_AUTO_UPDATE_SWITCH, switch)
		; TrayMenu.update_tray_menu()
		if (switch) {
			DisableWin10AutoUpdate()
			SetTimer, DisableWin10AutoUpdate, %tick_disable_win10_auto_interval%
		}
		else {
			SetTimer, DisableWin10AutoUpdate, Delete
			EnableWin10AutoUpdate()
		}
	}

	SetLimitModeInFullScreen(act="toggle")
	{
		cfg := SuxCore.GetIniConfig(INI_LIMIT_MODE_IN_FULL_SCREEN, SuxCore.Default_limit_mode_in_full_screen_switch)
		switch := (act="config")? cfg : act
		switch := (act="toggle")? !cfg : switch
		SuxCore.SetIniConfig(INI_LIMIT_MODE_IN_FULL_SCREEN, switch)
		; TrayMenu.update_tray_menu()
		if (switch) {
			global tick_detect_interval
			SetTimer, HANDLE_LIMIT_MODE_IN_FULL_SCREEN, %tick_detect_interval%
		}
		else {
			SetTimer, HANDLE_LIMIT_MODE_IN_FULL_SCREEN, Off
		}
	}
	
	SetAutorun(act="toggle")
	{
		cfg := SuxCore.GetIniConfig(INI_AUTORUN, SuxCore.Default_autorun_switch)
		autorun := (act="config")? cfg : act
		autorun := (act="toggle")? !cfg : autorun
		SuxCore.SetIniConfig(INI_AUTORUN, autorun)
		; TrayMenu.update_tray_menu()
		Regedit.Autorun(autorun, SuxCore.ProgramName, SuxCore.Launcher_Name)
		; if(autorun)
		; {
		; 	Menu, Tray, Check, % lang("Start With Windows")
		; }
		; Else
		; {
		; 	Menu, Tray, UnCheck, % lang("Start With Windows")
		; }
	}

	SetHotCorner(act="toggle")
	{
		cfg := SuxCore.GetIniConfig(INI_HOT_CORNER, SuxCore.Default_hot_corner_switch)
		hot_corner_switch := (act="config")? cfg : act
		hot_corner_switch := (act="toggle")? !cfg : hot_corner_switch
		SuxCore.SetIniConfig(INI_HOT_CORNER, hot_corner_switch)
		; TrayMenu.update_tray_menu()
		if (hot_corner_switch) {
			global tick_detect_interval
			SetTimer, TICK_HOT_CORNERS, %tick_detect_interval%
		}
		else {
			SetTimer, TICK_HOT_CORNERS, Off
		}
	}

	SetTheme(act="itemname")
	{
		if(act="itemname")
		{
			; m(A_ThisMenuItem)
			; m(A_ThisMenu)
			; m(A_ThisMenuItemPos)
			cur_theme_list := ["light", "dark"]
			cur_theme := cur_theme_list[A_ThisMenuItemPos]
		}
		else {
			cur_theme := act
		}
		SuxCore.SetIniConfig(INI_THEME, cur_theme)
		; TrayMenu.update_tray_menu()
	}

	SetLang(act="itemname")
	{
		if(act="itemname")
		{
			lang_map := {"English": "en", "中文": "cn"}
			lang := lang_map[A_ThisMenuItem]
		}
		else {
			lang := act
		}
		SuxCore.SetIniConfig(INI_LANG, lang)
		; TrayMenu.update_tray_menu()
	}

	; Tray Menu
	update_tray_menu()
	{
		version_str := lang("About") " sux v" SuxCore.version
		autorun := SuxCore.GetIniConfig(INI_AUTORUN, 0)
		remote_ver_str := SuxCore.get_remote_ini_config("ver")
		if (remote_ver_str != "ERROR" && get_version_sum(remote_ver_str) > get_version_sum(SuxCore.version)) {
			check_update_menu_name := lang("A New Version v") remote_ver_str . " !" lang(" Click me to chekc it out!")
		}
		else {
			check_update_menu_name := lang("Check Update")
		}
		lang := SuxCore.GetIniConfig(INI_LANG, SuxCore.Default_lang)
		cur_theme := SuxCore.GetIniConfig(INI_THEME, SuxCore.Default_theme)
		hot_corner_switch := SuxCore.GetIniConfig(INI_HOT_CORNER, SuxCore.Default_hot_corner_switch)
		limit_mode_in_full_screen_switch := SuxCore.GetIniConfig(INI_LIMIT_MODE_IN_FULL_SCREEN, SuxCore.Default_limit_mode_in_full_screen_switch)
		disable_win10_auto_update_switch := SuxCore.GetIniConfig(INI_DISABLE_WIN10_AUTO_UPDATE_SWITCH, SuxCore.Default_disable_win10_auto_update_switch)

		Menu, Tray, Tip, % SuxCore.ProgramName
		xMenu.New("TrayLanguage"
			,[["中文", "TrayMenu.SetLang", {check: lang=="cn"}]
			, ["English", "TrayMenu.SetLang", {check: lang=="en"}]])
		xMenu.New("SearchGuiTheme"
			,[[lang("Light"), "TrayMenu.SetTheme", {check: cur_theme=="light"}]
			, [lang("Dark"), "TrayMenu.SetTheme", {check: cur_theme=="dark"}]])
		xMenu.New("SensitiveFeatureSwitch"
			,[[lang("Hot Corner"), "TrayMenu.SetHotCorner", {check: hot_corner_switch==1}]
			, [lang("Auto Disable sux In Full Screen"), "TrayMenu.SetLimitModeInFullScreen", {check: limit_mode_in_full_screen_switch==1}]
			, [lang("Disable Win10 Auto Update"), "TrayMenu.SetDisableWin10AutoUpdate", {check: disable_win10_auto_update_switch==1}]])
		TrayMenuList := []
		TrayMenuList := EnhancedArray.merge(TrayMenuList
			,[[version_str, "TrayMenu.AboutSux"]
			,[lang("Help"), SuxCore.help_addr]
			,[lang("Donate"), "TrayMenu.ShowDonatePic"]
			,[check_update_menu_name, "CheckUpdate"]
			,[]
			,[lang("Start With Windows"), "TrayMenu.SetAutorun", {check: autorun}]
			,["Language",, {"sub": "TrayLanguage"}]
			,[lang("Theme"),, {"sub": "SearchGuiTheme"}]
			,[lang("Feature Switch"),, {"sub": "SensitiveFeatureSwitch"}]
			,[]
			,[lang("Open sux Folder"), A_WorkingDir]
			,[lang("Edit Config File"), "TrayMenu.Edit_conf_yaml"]
			,[]
			,[lang("Disable"), "TrayMenu.SetDisable", {check: A_IsPaused&&A_IsSuspended}]
			,[lang("Restart sux"), "ReloadSux"]
			,[lang("Exit"), "TrayMenu.ExitSux"] ])
		this.SetMenu(TrayMenuList)
		Menu, Tray, Default, % lang("Disable")
		Menu, Tray, Click, 1
		this.Update_Icon()
	}

	static _switch_tray_standard_menu := 0
	Standard_Tray_Menu(act="toggle")
	{
		SuxCore._switch_tray_standard_menu := (act="toggle")? !SuxCore._switch_tray_standard_menu :act
		this.update_tray_menu()
	}

	ShowDonatePic() {
		Gui, sux_donate: New
		Gui sux_donate:+Resize +AlwaysOnTop +MinSize400 -MaximizeBox -MinimizeBox
		Gui, Font, s12
		s := "支付宝"
		Gui, Add, Text,, % s
		Gui, Add, Picture, w300 h-1, % TrayMenu.donate_img_alipay
		; Gui, Add, Picture, w300 h-1, C:\Users\b\Documents\github\sux\app_data\donate_alipay.png
		s := "微信"
		Gui, Add, Text,, % s
		Gui, Add, Picture, w300 h-1, % TrayMenu.donate_img_wechat
		GuiControl, Focus, Close
		s := lang("Donate")
		Gui, Show,, % s
	}

	AboutSux() {
		Gui, sux_About: New
		Gui sux_About:+Resize +AlwaysOnTop +MinSize400 -MaximizeBox -MinimizeBox
		Gui, Font, s12
		s := "sux v" SuxCore.version
		Gui, Add, Text,, % s
		s := "<a href=""" SuxCore.Project_Home_Page """>" lang("Home Page") "</a>"
		Gui, Add, Link,, % s
		s := "<a href=""" SuxCore.Project_Issue_page """>" lang("Feedback") "</a>"
		Gui, Add, Link,, % s
		Gui, Add, Text
		GuiControl, Focus, Close
		s := lang("About") . " sux"
		Gui, Show,, % s
	}

	Update_Icon()
	{
		setsuspend := A_IsSuspended
		setpause := A_IsPaused
		if !setpause && !setsuspend {
			this.SetIcon(this.icon_default)
		}
		Else if !setpause && setsuspend {
			this.SetIcon(this.icon_disable)
		}
		Else if setpause && !setsuspend {
			this.SetIcon(this.icon_disable)
		}
		Else if setpause && setsuspend {
			this.SetIcon(this.icon_disable)
		}
	}

	; Tray.SetIcon
	SetIcon(path)
	{
		if(FileExist(path)) {
			Menu, Tray, Icon, %path%,,1
		}
	}

	; Tray.SetMenu
	SetMenu(menuList)
	{
		Menu, Tray, DeleteAll
		Menu, Tray, NoStandard
		xMenu.add("Tray", menuList)
	}

	ExitSux(show_msg=true)
	{
		ExitApp
	}

	Edit_conf_yaml()
	{
		OpenFolderAndSelectFile(SuxCore.conf_user_yaml_file)
	}

	SetDisable(act="toggle")
	{
		setdisable := (act="toggle")? !(A_IsPaused&&A_IsSuspended): act
		TrayMenu.SetState(setdisable, setdisable)
	}

	SetState(setsuspend="", setpause="")
	{
		setsuspend := (setsuspend="")? A_IsSuspended: setsuspend
		setpause := (setpause="")? A_IsPaused: setpause
		if(!A_IsSuspended && setsuspend) {
			RunArr(SuxCore.OnSuspendCmd)
		}
		if(!A_IsPaused && setpause) {
			RunArr(SuxCore.OnPauseCmd)
		}
		if(setsuspend) {
			Suspend, On
		}
		else {
			Suspend, Off
		}
		if(setpause) {
			Pause, On, 1
		}
		else {
			Pause, Off
		}
		TrayMenu.update_tray_menu()
	}
}



; //////////////////////////////////////////////////////////////////////////
; //////////////////////////////////////////////////////////////////////////
; //////////////////////////////////////////////////////////////////////////
/*
e.g.
xMenu.Add("Menu1", [["item1","func1"],["item2","func2"],[]
				,["submenu",["subitem_1","func3"]
				,["subitem_2",, {sub: "SubMenu", "disable"}]]])
xMenu.Show("Menu1")
*/
class xMenu
{
	static MenuList := {}

	Show(Menu_Name, X := "", Y := "")
	{
		if (X == "" || Y == "")
			Menu, %Menu_Name%, Show
		Else
			Menu, %Menu_Name%, Show, % X, % Y
	}

	New(Menu_Name, Menu_Config)
	{
		this.Clear(Menu_Name)
		this.Add(Menu_Name, Menu_Config)
	}

	Clear(Menu_Name)
	{
		Try
		{
			Menu, %Menu_Name%, DeleteAll
		}
	}

	Add(Menu_Name, Menu_Config)
	{
		ParsedCfg := this._Config_Parse(Menu_Name, Menu_Config)
		Loop, % ParsedCfg.MaxIndex()
		{
			cfg_entry := ParsedCfg[A_Index]
			if (cfg_entry[4].HasKey("sub"))
			{
				sub_name := cfg_entry[4]["sub"]
				Menu, % cfg_entry[1], Add, % cfg_entry[2], :%sub_name%
			}
			Else
			{
				Menu, % cfg_entry[1], Add, % cfg_entry[2], Sub_xMenu_Open
				this.MenuList[cfg_entry[1] "_" cfg_entry[2]] := cfg_entry[3]
			}
			For Key, Value in cfg_entry[4]
			{
				if Value = 0
					Continue
				StringLower, Key, Key
				if(Key == "check")
					Menu, % cfg_entry[1], Check, % cfg_entry[2]
				if(Key == "uncheck")
					Menu, % cfg_entry[1], UnCheck, % cfg_entry[2]
				if(Key == "togglecheck")
					Menu, % cfg_entry[1], ToggleCheck, % cfg_entry[2]
				if(Key == "enable")
					Menu, % cfg_entry[1], Enable, % cfg_entry[2]
				if(Key == "disable")
					Menu, % cfg_entry[1], Disable, % cfg_entry[2]
				if(Key == "toggleenable")
					Menu, % cfg_entry[1], ToggleEnable, % cfg_entry[2]
			}
		}
	}

	_Config_Parse(PName, Config)
	{
		ParsedCfg := {}
		Loop, % Config.MaxIndex()
		{
			cfg_entry := Config[A_Index]
			If IsObject(cfg_entry[2])
			{
				ParsedCfg_Sub := this._Config_Parse(cfg_entry[1], cfg_entry[2])
				Loop, % ParsedCfg_Sub.MaxIndex()
				{
					sub_entry := ParsedCfg_Sub[A_Index]
					ParsedCfg.Insert([sub_entry[1],sub_entry[2],sub_entry[3],sub_entry[4]])
				}
				ParsedCfg.Insert([PName,cfg_entry[1],,{"sub":cfg_entry[1]}])
			}
			Else
			{
				if cfg_entry.MaxIndex() == 3
					cfg_ctrl := cfg_entry[3]
				Else
					cfg_ctrl := {}
				ParsedCfg.Insert([PName,cfg_entry[1],cfg_entry[2],cfg_ctrl])
			}
		}
		Return % ParsedCfg
	}
}


Sub_xMenu_Open:
; ActiveHwnd := WinExist("A")
Run(xMenu.MenuList[A_ThisMenu "_" A_ThisMenuItem])
TrayMenu.update_tray_menu()
Send, !{esc}  ; GotoNextApp,  没有这一行的话, 点击了菜单之后双击alt没反应, 还得点击一下其他地方才有反应
; WinActivate
; WinActivate, ahk_id %ActiveHwnd%	
Return



TICK_HOT_CORNERS:
	global LIMIT_MODE
	if (LIMIT_MODE) {
		return
	}
	global HOTKEY_REGISTER_MAP
	border_code := get_border_code()
	; ToolTipWithTimer(border_code)
	if (InStr(border_code, "Corner")) {
		action := HOTKEY_REGISTER_MAP[border_code "|" "hover"]
		; ToolTipWithTimer(border_code "|" "hover")
		ToolTipWithTimer(action, 1111)
		run(action)
		Loop 
		{
			if (get_border_code() == "")
				break ; exits loop when mouse is no longer in the corner
		}
	}
	Return


HANDLE_LIMIT_MODE_IN_FULL_SCREEN:
	global LIMIT_MODE
	if (IsFullscreen()) {
		if (LIMIT_MODE == 0) {
			ToolTipWithTimer(lang("sux limit mode auto enable in full screen mode."))
			LIMIT_MODE := 1
		}
	}
	else {
		if (LIMIT_MODE == 1) {
			ToolTipWithTimer(lang("sux limit mode auto disable not in full screen mode."))
			LIMIT_MODE := 0
		}
	}
	Return



; //////////////////////////////////////////////////////////////////////////
SUB_TRAY_MENU_FILE_END_LABEL:
	temp_tm := "blabla"