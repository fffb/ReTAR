AutoComplete(ComboBox, entriesList) {
    ; CB_GETEDITSEL = 0x0140, CB_SETEDITSEL = 0x0142
    currContent := ComboBox.Text
    if ((GetKeyState("Delete", "P")) || (GetKeyState("Backspace", "P")))
        return

    valueFound := false
    for index, value in entriesList
    {
        ; Check if the current value matches the target value
        if (value = currContent)
        {
            valueFound := true
            break ; Exit the loop if the value is found
        }
    }
    if (valueFound)
        return ; Exit Nested request

    Start :=0, End :=0
    MakeShort(0, &Start, &End)
    try {
        if (ControlChooseString(ComboBox.Text, ComboBox) > 0) {
            Start := StrLen(currContent)
            End := StrLen(ComboBox.Text)
            PostMessage 0x0142, 0, MakeLong(Start, End), , "ahk_id" ComboBox.Hwnd
        }
    } Catch as e {
        ControlSetText currContent, ComboBox
        PostMessage 0x0142, 0, MakeLong(StrLen(currContent), StrLen(currContent)), , "ahk_id " ComboBox.Hwnd
    }

    MakeShort(Long, &LoWord, &HiWord) {
        LoWord := Long & 0xffff
        , HiWord := Long >> 16
    }

    MakeLong(LoWord, HiWord) {
        return (HiWord << 16) | (LoWord & 0xffff)
    }
}