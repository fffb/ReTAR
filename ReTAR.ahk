#SingleInstance force
#Include .\Lib\AutoComplete.ahk
#Include .\Lib\_eval.ahk
#Include .\Lib\FolderMenuList v1.1.1.ahk
SetTitleMatchMode 3 ;窗口标题必须和 WinTitle 完全一致才能匹配，否则热键在有“ReTAR”字样的窗口不起效

if !FileExist("Config.ini")
    IniWrite("cmd", "Config.ini", "cmd", "path")    ;如果不存在 config.ini，则自动创建，并创建一个[cmd] section,其 path 为 cmd

SectionNames := IniRead("Config.ini")    ; 返回一个以换行符(`n) 分隔的 section 列表
CBXListTemp := StrReplace(SectionNames, "`nCount")    ;去掉 section 列表中的 count
CBXList := StrSplit(CBXListTemp, "`n")    ;分割成字符串数组，传递给 combobox 当列表参数


CreateGUI
CreateMenu
MainGui.Hide
Return

CreateGUI()
{
    global
    MainGui := Gui("+ToolWindow -Caption", "ReTAR")
    MainGui.BackColor := "37377D"

    MainGui.SetFont("s20", "Tahoma")
    CBX := MainGui.Add("ComboBox", "x12 y9 w470 h180 vCBX", CBXList)
    CBX.OnEvent("Change", Calc)

    MainGui.SetFont("S12 c80FFFF", "Tahoma")
    FixedText := MainGui.Add("Edit", "x12 y+8 w540 h25 ReadOnly Background37377D")

    GoBtn := MainGui.Add("Button", "Default x492 y9 w60 h40", "Go")
    GoBtn.OnEvent("Click", RunApp)

    MainGui.Show("Center h90 w565")
}

CreateMenu()
{
    global
    Tray := A_TrayMenu
    Tray.delete    ; 删除标准菜单项目，不显示 ahk 自己的菜单
    TraySetIcon("ReTAR.ico")
    A_IconTip := "ReTAR"    ; 托盘提示信息
    Tray.Add "显示界面 (&S)", ShowUI
    Tray.Add "隐藏界面 (&H)", HideUI
    Tray.Add
    Tray.Add "开机启动 (&A)", AutoRun
    Tray.Add "打开配置文件 (&C)", EditConfig
    Tray.Add "重新加载 (&R)", RL
    Tray.Add
    Tray.Add "关于", About
    Tray.Add "退出 (&X)", ExitReTAR

    If FileExist(A_Startup "\ReTAR.lnk")
        Tray.Check "开机启动 (&A)"
}

HideUI(*)
{
    MainGui.Hide
}

ShowUI(*)
{
    MainGui.Show
    CBX.Text := ""    
}

`::
{
    if WinActive("ReTAR")
    {
        MainGui.Hide
    }
    else
    {
        ShowUI()
    }
}

#Hotif WinActive("ReTAR")
Esc::
{
    MainGui.Hide
}

AutoRun(*)
{
    If FileExist(A_Startup "\ReTAR.lnk")
    {
        FileDelete A_Startup "\ReTAR.lnk"
        Tray.Uncheck("开机启动 (&A)")
    }
    else
    {
        FileCreateShortcut A_ScriptFullPath, A_Startup "\ReTAR.lnk", A_ScriptDir
        Tray.Check("开机启动 (&A)")
    }
}

EditConfig(*)
{
    Run "Config.ini"
}

RL(*)
{
    Reload
}

About(*)
{
    global AboutGUI := gui(, "关于 ReTAR")

    AboutGUI.SetFont("s9", "Segoe UI")
    OKBtn := AboutGUI.Add("Button", "x152 y270 w75 h25", "确定")
    OKBtn.OnEvent("Click", CloseAbout)

    AboutGUI.SetFont("s20", "Microsoft Sans Serif")
    AboutGUI.Add("Text", "x54 y13 w272 h35", "ReTAR Version 0.8.5")
    
    AboutGUI.SetFont("s9", "Segoe UI")
    AboutGUI.Add("Text", "x130 y50 w200 h30", "Powered by AHK v2")

    AboutGUI.SetFont("s9", "Segoe UI")
    AboutGUI.Add("Text", "x120 y70 w148 h30", "Copyright © 2022-2023 FF `nUpdate: 2023-10-13 21:36")

    AboutGUI.Add("Picture", "x36 y55 w48 h48", "ReTAR.ico")
    AboutGUI.Add("text", "x121 y107 w150 h2 +0x10")

    AboutGUI.Add("Link", "x45 y117 w318 h137", 'Icon:`n<a href="https://www.iconfinder.com/iconsets/military-and-guns">Military and Guns icon pack</a> - by Abderraouf omara`n`nComponents:`n<a href="https://www.reddit.com/r/AutoHotkey/comments/10wufmn/help_with_ahk_v2_gui_with_combobox_adding/?rdt=58525">AutoComplete</a> - by Ark565 && skyracer85`n<a href="https://github.com/TheArkive/eval_ahk2">eval_ahk2</a> - by TheArkive`nSpecial thanks to <a href="https://www.macrocreator.com/">Pulover</a> for <a href="https://github.com/pulover/cbautocomplete">CbAutoComplete</a> && <a href="https://github.com/pulover/eval">eval</a>')

    AboutGUI.Show("w380 h306")
}

CloseAbout(*)
{
    AboutGui.Destroy()
}

ExitReTAR(*)
{
    ExitApp
}


IsVarInArr(item, arr)
{
    for i in arr
        if i = item
            return true
    return false
}

RunApp(*)
{
    if IsVarInArr(OutputVar, CBXList) = true    ;检查 edit 输入是否在 section 列表中
    {
        try Run PathVar
        catch
        {
            MsgBox "路径未找到，请检查配置", "路径错误", "Iconx"
        }
        else
        {
            CountNumber := IniRead("Config.ini", "Count", OutputVar, 0)    ;读取 ini 中 Count Section 下对应 key 的运行计数，如果无此 key，则默认创建为 0
            CountNumber += 1
            IniWrite(CountNumber, "Config.ini", "Count", OutputVar)    ;运行计数 +1 后写回
        }
        MainGui.Hide
    }
    else
    {
        if IsNumber(FixedText.Text)
        {
            A_Clipboard := ""
            A_Clipboard := FixedText.Text
            MsgBox "结果是 " FixedText.Text "，已复制到剪贴板。", "计算结果"
            MainGui.Hide
        }
        else
        {
            MsgBox "请在 ini 文件中添加相应配置", "错误", "48"
            MainGui.Hide
        }
    }
}

Calc(*)
{
    global OutputVar := CBX.Text
    AutoComplete(CBX, CBXList)
    if IsVarInArr(OutputVar, CBXList) = true    ;检查 edit 输入是否在 section 列表中
    {
        global PathVar := IniRead("Config.ini", OutputVar, "path")
        FixedText.Text := PathVar
    }
    else
    {
        try FixedText.Text := eval(CBX.Text, test := false)
    }
}