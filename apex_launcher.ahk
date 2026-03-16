#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

;══════════════════════════════════════
; Quality of life
;══════════════════════════════════════

SetCapsLockState "AlwaysOff"

::@@::zahiindaiyan@gmail.com
::@w::https://www.
::@git::https://www.github.com/ZahinDaiyan
::@mail::https://www.gmail.com
::@cp::https://codeforces.com/profile/Zahin_Daiyan
::@dev::cd D:\dev\webdev
::@nfig::cd C:\Users\zahii\AppData\Local\nvim

;══════════════════════════════════════
; Vim-style navigation (hold CapsLock)
;══════════════════════════════════════

CapsLock & h::Send("{Left}")
CapsLock & j::Send("{Down}")
CapsLock & k::Send("{Up}")
CapsLock & l::Send("{Right}")
CapsLock & w::Send("^{Backspace}")
CapsLock & d::Send("{Delete}")
CapsLock & u::Send("^z")

;══════════════════════════════════════
; Code Snippets
;══════════════════════════════════════

::forloop::for (int i = 0; i < n; ++i) 

; ═══════════════════════════════════════════════════════════════════════════════
;  APEX LAUNCHER  v2.1  (slim edition)
;  Alt+Space  →  open/close
;  Type       →  fuzzy search apps, commands, URLs, math
;  ↑ ↓ Tab    →  navigate results
;  Enter      →  launch / copy math result
;  Esc        →  close
; ═══════════════════════════════════════════════════════════════════════════════

global LAUNCH_KEY := "!Space"

; ── WINDOW GEOMETRY ───────────────────────────────────────────────────────────
global WIN_W    := 720
global WIN_H    := 62
global RESULT_H := 44
global MAX_RES  := 8

; ── COLORS ────────────────────────────────────────────────────────────────────
global C_BG        := 0x0e0e0f
global C_BG_SEL    := 0x1a1f2e
global C_BG_ITEM   := 0x141416
global C_SEPARATOR := 0x222228
global C_FG        := 0xdde1ec
global C_FG_DIM    := 0x52566a
global C_FG_SEL    := 0xffffff
global C_ACCENT    := 0x5b9cf6
global C_INPUT_BG  := 0x0e0e0f

global KIND_COLORS := Map(
    "cmd",  0x5b9cf6,
    "app",  0x4ade80,
    "url",  0xfb923c,
    "math", 0xa78bfa
)
global KIND_ICONS := Map(
    "cmd",  "❯",
    "app",  "◈",
    "url",  "⊕",
    "math", "∑"
)

; ── BUILT-IN COMMANDS ─────────────────────────────────────────────────────────
global Builtins := Map(
    "brave",          Map("cmd", "C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe", "desc", "Brave Browser"),
    "chrome",         Map("cmd", "C:\Program Files\Google\Chrome\Application\chrome.exe",              "desc", "Google Chrome"),
    "nvim",           Map("cmd", "nvim",                                     "desc", "Neovim"),
    "cmd",            Map("cmd", "pwsh -NoLogo -WorkingDirectory ~",         "desc", "PowerShell 7"),
    "powershell",     Map("cmd", "powershell",                               "desc", "PowerShell 5"),
    "terminal",       Map("cmd", "wt",                                       "desc", "Windows Terminal"),
    "explorer",       Map("cmd", "explorer",                                 "desc", "File Explorer"),
    "notepad",        Map("cmd", "notepad",                                  "desc", "Notepad"),
    "lock",           Map("cmd", "LockWorkStation",                          "desc", "Lock the screen"),
    "sleep",          Map("cmd", "rundll32.exe powrprof.dll,SetSuspendState 0,1,0", "desc", "Sleep the PC"),
    "shutdown",       Map("cmd", "shutdown /s /t 0",                         "desc", "Shut down"),
    "restart",        Map("cmd", "shutdown /r /t 0",                         "desc", "Restart"),
    "logout",         Map("cmd", "shutdown /l",                              "desc", "Log out"),
    "task manager",   Map("cmd", "taskmgr",                                  "desc", "Task Manager"),
    "taskmgr",        Map("cmd", "taskmgr",                                  "desc", "Task Manager"),
    "calculator",     Map("cmd", "calc",                                     "desc", "Calculator"),
    "settings",       Map("cmd", "ms-settings:",                             "desc", "Windows Settings"),
    "snip",           Map("cmd", "SnippingTool",                             "desc", "Snipping Tool"),
    "control panel",  Map("cmd", "control",                                  "desc", "Control Panel"),
    "device manager", Map("cmd", "devmgmt.msc",                              "desc", "Device Manager"),
    "disk management",Map("cmd", "diskmgmt.msc",                             "desc", "Disk Management"),
    "winver",         Map("cmd", "winver",                                   "desc", "Windows version"),
    "env",            Map("cmd", "rundll32.exe sysdm.cpl,EditEnvironmentVariables", "desc", "Environment variables"),
    "store",          Map("cmd", "ms-windows-store:",                        "desc", "Microsoft Store"),
    "wsl",            Map("cmd", "wsl",                                      "desc", "Windows Subsystem for Linux"),
    "regedit",        Map("cmd", "regedit",                                  "desc", "Registry Editor"),
    "hosts",          Map("cmd", "notepad C:\Windows\System32\drivers\etc\hosts", "desc", "Edit hosts file"),
    "services",       Map("cmd", "services.msc",                             "desc", "Services"),
    "paint",          Map("cmd", "mspaint",                                  "desc", "MS Paint")
)

; ── HISTORY ───────────────────────────────────────────────────────────────────
global gHistory     := Map()
global HISTORY_FILE := A_AppData "\ApexLauncher\history.ini"

; ── STATE ─────────────────────────────────────────────────────────────────────
global gResults  := []
global gSel      := 0
global gGui      := 0
global gEdit     := 0
global gRows     := []
global gDebounce := 0
global gVisible  := false
global gLastQuery := ""
global gSepCtrl  := 0

; ═══════════════════════════════════════════════════════════════════════════════
;  STARTUP
; ═══════════════════════════════════════════════════════════════════════════════
LoadHistory()
HotKey LAUNCH_KEY, ToggleLauncher

; ═══════════════════════════════════════════════════════════════════════════════
;  TOGGLE
; ═══════════════════════════════════════════════════════════════════════════════
ToggleLauncher(*) {
    global gVisible
    if gVisible
        HideLauncher()
    else
        ShowLauncher()
}

; ═══════════════════════════════════════════════════════════════════════════════
;  BUILD GUI
; ═══════════════════════════════════════════════════════════════════════════════
BuildGui() {
    global gGui, gEdit, gRows

    gGui := Gui("+AlwaysOnTop -Caption +LastFound +E0x08000000", "ApexLauncher")
    gGui.BackColor := Format("{:06X}", C_BG)
    gGui.MarginX   := 0
    gGui.MarginY   := 0

    gGui.SetFont("s15 c" Format("{:06X}", C_ACCENT), "Segoe UI Symbol")
    gGui.Add("Text", "x14 y16 w26 h30 +BackgroundTrans", "⌕")

    gGui.SetFont("s13 c" Format("{:06X}", C_FG) " q5", "Segoe UI")
    gEdit := gGui.Add("Edit",
        "x46 y13 w" (WIN_W - 62) " h36 -E0x200 Background" Format("{:06X}", C_INPUT_BG))
    gEdit.OnEvent("Change", OnTypeDebounce)

    HotIfWinActive "ApexLauncher ahk_class AutoHotkeyGUI"
    HotKey "Enter",  OnEnter
    HotKey "Escape", (*) => HideLauncher()
    HotKey "Down",   (*) => MoveSelection(1)
    HotKey "Up",     (*) => MoveSelection(-1)
    HotKey "Tab",    (*) => MoveSelection(1)
    HotKey "+Tab",   (*) => MoveSelection(-1)
    HotIf

    gGui.OnEvent("Close", HideLauncher)
    gRows := []
}

; ═══════════════════════════════════════════════════════════════════════════════
;  SHOW / HIDE
; ═══════════════════════════════════════════════════════════════════════════════
ShowLauncher(*) {
    global gGui, gEdit, gVisible

    if !IsObject(gGui)
        BuildGui()

    gEdit.Value := ""
    gLastQuery  := ""
    ClearResults()

    MonitorGetWorkArea(MonitorGetPrimary(), &mL, &mT, &mR, &mB)
    mW := mR - mL
    mH := mB - mT
    x  := mL + (mW - WIN_W) // 2
    y  := mT + (mH * 28) // 100

    gGui.Show("x" x " y" y " w" WIN_W " h" WIN_H " NoActivate")
    WinActivate "ApexLauncher ahk_class AutoHotkeyGUI"
    gEdit.Focus()
    gVisible := true
}

HideLauncher(*) {
    global gGui, gVisible
    if IsObject(gGui)
        gGui.Hide()
    gVisible := false
}

; ═══════════════════════════════════════════════════════════════════════════════
;  INPUT HANDLING
; ═══════════════════════════════════════════════════════════════════════════════
OnTypeDebounce(*) {
    global gDebounce
    if gDebounce
        SetTimer gDebounce, 0
    gDebounce := ProcessInput.Bind()
    SetTimer gDebounce, -80
}

ProcessInput(*) {
    global gEdit, gLastQuery
    q := Trim(gEdit.Value)
    if (q = gLastQuery)
        return
    gLastQuery := q
    if (q = "") {
        ClearResults()
        return
    }
    ShowResults(DoSearch(q))
}

; ═══════════════════════════════════════════════════════════════════════════════
;  SEARCH
; ═══════════════════════════════════════════════════════════════════════════════
DoSearch(q) {
    global Builtins, MAX_RES, gHistory
    results := []
    qL      := StrLower(q)

    ; ── 1. Math ─────────────────────────────────────────────────────────────
    mathVal := TryMath(q)
    if (mathVal != "") {
        results.Push(Map(
            "label", q " = " mathVal,
            "desc",  "Press Enter to copy result",
            "path",  mathVal,
            "kind",  "math",
            "score", 100
        ))
    }

    ; ── 2. URL detection ────────────────────────────────────────────────────
    if IsUrl(q) {
        url := (SubStr(q, 1, 4) = "http") ? q : "https://" q
        results.Push(Map("label", url, "desc", "Open URL", "path", url, "kind", "url", "score", 90))
    }

    ; ── 3. Built-in commands ────────────────────────────────────────────────
    for name, info in Builtins {
        sc := FuzzyScore(name, qL)
        if (sc > 0)
            results.Push(Map(
                "label", name,
                "desc",  info["desc"],
                "path",  info["cmd"],
                "kind",  "cmd",
                "score", sc + GetHistoryBonus(name)
            ))
    }

    ; ── 4. Start Menu apps ──────────────────────────────────────────────────
    dirs := [
        EnvGet("APPDATA")     "\Microsoft\Windows\Start Menu\Programs",
        EnvGet("PROGRAMDATA") "\Microsoft\Windows\Start Menu\Programs"
    ]
    seen := Map()
    for dir in dirs {
        loop files dir "\*.lnk", "R" {
            cleanName := StrReplace(A_LoopFileName, ".lnk", "")
            if seen.Has(StrLower(cleanName))
                continue
            sc := FuzzyScore(StrLower(cleanName), qL)
            if (sc > 0) {
                seen[StrLower(cleanName)] := true
                results.Push(Map(
                    "label", cleanName,
                    "desc",  A_LoopFileDir,
                    "path",  A_LoopFileFullPath,
                    "kind",  "app",
                    "score", sc + GetHistoryBonus(cleanName)
                ))
            }
        }
    }

    ; ── 5. Sort and trim ────────────────────────────────────────────────────
    results := SortResults(results)
    while results.Length > MAX_RES
        results.RemoveAt(results.Length)

    return results
}

; ── Fuzzy scoring ─────────────────────────────────────────────────────────────
FuzzyScore(haystack, needle) {
    h := StrLower(haystack)
    n := StrLower(needle)
    if (h = n)
        return 100
    if SubStr(h, 1, StrLen(n)) = n
        return 80
    if InStr(h, n)
        return 60
    pos := 1
    nLen := StrLen(n)
    i := 1
    while i <= nLen {
        ch    := SubStr(n, i, 1)
        found := InStr(h, ch,, pos)
        if !found
            return 0
        pos := found + 1
        i++
    }
    return 40
}

SortResults(arr) {
    loop arr.Length - 1 {
        i := A_Index + 1
        while i > 1 && arr[i]["score"] > arr[i-1]["score"] {
            tmp      := arr[i]
            arr[i]   := arr[i-1]
            arr[i-1] := tmp
            i--
        }
    }
    return arr
}

; ── Math evaluator ────────────────────────────────────────────────────────────
TryMath(q) {
    if !RegExMatch(q, "^[\d\s\+\-\*\/\^\(\)\.%]+$")
        return ""
    try {
        sc := ComObject("ScriptControl")
        sc.Language := "JScript"
        val := sc.Eval(q)
        result := String(val)
        ; Don't show math result if it's just the same as input (e.g. single number)
        if (result = Trim(q))
            return ""
        return result
    }
    return ""
}

; ── URL detection ─────────────────────────────────────────────────────────────
IsUrl(q) {
    return RegExMatch(q, "i)^(https?://|www\.|[\w-]+\.(com|net|org|io|dev|ai|co|app|me|tv|gg)(/|$))")
        || RegExMatch(q, "^localhost(:\d+)?")
}

; ═══════════════════════════════════════════════════════════════════════════════
;  RESULTS UI
; ═══════════════════════════════════════════════════════════════════════════════
ClearResults() {
    global gGui, gRows, gResults, gSel, gSepCtrl
    for row in gRows {
        try row.bg.Destroy()
        try row.iconCtrl.Destroy()
        try row.labelCtrl.Destroy()
        try row.descCtrl.Destroy()
        try row.badgeCtrl.Destroy()
    }
    if IsObject(gSepCtrl) {
        try gSepCtrl.Destroy()
        gSepCtrl := 0
    }
    gRows    := []
    gResults := []
    gSel     := 0
    if IsObject(gGui)
        gGui.Move(,, WIN_W, WIN_H)
}

ShowResults(results) {
    global gGui, gRows, gResults, gSel, gSepCtrl
    ClearResults()
    if !results.Length
        return

    gResults := results
    gSel     := 1

    gSepCtrl := gGui.Add("Progress", "x0 y" WIN_H " w" WIN_W " h1 Background" Format("{:06X}", C_SEPARATOR))
    gSepCtrl.Value := 0

    yPos := WIN_H + 1

    for i, r in results {
        kind   := r["kind"]
        kColor := KIND_COLORS.Has(kind) ? KIND_COLORS[kind] : C_FG_DIM
        kIcon  := KIND_ICONS.Has(kind)  ? KIND_ICONS[kind]  : "·"

        bg := gGui.Add("Progress",
            "x0 y" yPos " w" WIN_W " h" RESULT_H " Background" Format("{:06X}", C_BG_ITEM))
        bg.Value := 0

        gGui.SetFont("s11 c" Format("{:06X}", kColor) " q5", "Segoe UI Symbol")
        iconCtrl := gGui.Add("Text",
            "x14 y" (yPos + 13) " w18 h20 Background" Format("{:06X}", C_BG_ITEM), kIcon)

        gGui.SetFont("s11 c" Format("{:06X}", C_FG) " q5", "Segoe UI")
        labelCtrl := gGui.Add("Text",
            "x36 y" (yPos + 7) " w" (WIN_W - 160) " h18 Background" Format("{:06X}", C_BG_ITEM),
            r["label"])

        descText := r.Has("desc") ? r["desc"] : ""
        gGui.SetFont("s8 c" Format("{:06X}", C_FG_DIM) " q5", "Segoe UI")
        descCtrl := gGui.Add("Text",
            "x36 y" (yPos + 26) " w" (WIN_W - 160) " h14 Background" Format("{:06X}", C_BG_ITEM),
            descText)

        gGui.SetFont("s7 c" Format("{:06X}", kColor) " q5", "Segoe UI")
        badgeCtrl := gGui.Add("Text",
            "x" (WIN_W - 54) " y" (yPos + 14) " w48 h16 +Right Background" Format("{:06X}", C_BG_ITEM),
            kind)

        gRows.Push({
            bg:        bg,
            iconCtrl:  iconCtrl,
            labelCtrl: labelCtrl,
            descCtrl:  descCtrl,
            badgeCtrl: badgeCtrl
        })

        yPos += RESULT_H
    }

    gGui.Move(,, WIN_W, WIN_H + 1 + results.Length * RESULT_H)
    Highlight(1)
}

OnMessage(0x201, WM_LBUTTONDOWN)
WM_LBUTTONDOWN(wParam, lParam, msg, hwnd) {
    global gGui, gResults, WIN_H, RESULT_H
    if !IsObject(gGui)
        return
    if (hwnd != gGui.Hwnd)
        return
    y := (lParam >> 16) & 0xFFFF
    if (y < WIN_H + 1)
        return
    rowIdx := ((y - WIN_H - 1) // RESULT_H) + 1
    if (rowIdx >= 1 && rowIdx <= gResults.Length) {
        Highlight(rowIdx)
        LaunchSelected()
    }
}

Highlight(idx) {
    global gResults, gSel, gRows
    gSel := idx
    loop gResults.Length {
        i     := A_Index
        isSel := (i = idx)
        row   := gRows[i]
        kind  := gResults[i]["kind"]
        kCol  := KIND_COLORS.Has(kind) ? KIND_COLORS[kind] : C_FG_DIM
        bgCol := isSel ? C_BG_SEL : C_BG_ITEM
        fgCol := isSel ? C_FG_SEL : C_FG
        try {
            row.bg.Opt("Background"        Format("{:06X}", bgCol))
            row.iconCtrl.Opt("Background"  Format("{:06X}", bgCol) " c" Format("{:06X}", kCol))
            row.labelCtrl.Opt("Background" Format("{:06X}", bgCol) " c" Format("{:06X}", fgCol))
            row.descCtrl.Opt("Background"  Format("{:06X}", bgCol))
            row.badgeCtrl.Opt("Background" Format("{:06X}", bgCol))
        }
    }
}

MoveSelection(dir) {
    global gResults, gSel
    if !gResults.Length
        return
    n := gSel + dir
    if n < 1
        n := gResults.Length
    if n > gResults.Length
        n := 1
    Highlight(n)
}

; ═══════════════════════════════════════════════════════════════════════════════
;  LAUNCH
; ═══════════════════════════════════════════════════════════════════════════════
OnEnter(*) {
    global gResults, gSel, gEdit
    q := Trim(gEdit.Value)
    if !q
        return
    HideLauncher()
    if gResults.Length
        LaunchResult(gResults[gSel])
}

LaunchSelected() {
    global gResults, gSel
    HideLauncher()
    if gResults.Length
        LaunchResult(gResults[gSel])
}

LaunchResult(r) {
    kind  := r["kind"]
    path  := r["path"]
    label := r["label"]

    RecordHistory(label)

    if (kind = "math") {
        A_Clipboard := path
        ShowToast("Copied: " path)
        return
    }

    if (kind = "url") {
        Run path
        return
    }

    if (kind = "cmd") {
        if (path = "LockWorkStation") {
            DllCall("LockWorkStation")
            return
        }
        if RegExMatch(path, "^rundll32|^shutdown|^wsl") {
            Run path,, "Hide"
            return
        }
        try Run path
        catch as e
            ShowToast("Failed: " e.Message)
        return
    }

    ; app
    try Run path
    catch {
        try Run label
        catch as e
            ShowToast("Could not launch: " label)
    }
}

; ═══════════════════════════════════════════════════════════════════════════════
;  TOAST
; ═══════════════════════════════════════════════════════════════════════════════
ShowToast(msg) {
    t := Gui("+AlwaysOnTop -Caption +LastFound +E0x08000000", "Toast")
    t.BackColor := "202020"
    t.SetFont("s10 cE8E8E8 q5", "Segoe UI")
    t.Add("Text", "x12 y8 w320 h24", msg)
    MonitorGetWorkArea(MonitorGetPrimary(), &mL,, &mR, &mB)
    tw := 344
    t.Show("x" (mR - tw - 20) " y" (mB - 60) " w" tw " h40 NoActivate")
    SetTimer () => t.Destroy(), -3000
}

; ═══════════════════════════════════════════════════════════════════════════════
;  HISTORY
; ═══════════════════════════════════════════════════════════════════════════════
LoadHistory() {
    global gHistory, HISTORY_FILE
    gHistory := Map()
    if !FileExist(HISTORY_FILE)
        return
    try {
        loop read HISTORY_FILE {
            parts := StrSplit(A_LoopReadLine, "=")
            if parts.Length = 2
                gHistory[parts[1]] := Integer(parts[2])
        }
    }
}

SaveHistory() {
    global gHistory, HISTORY_FILE
    dir := SubStr(HISTORY_FILE, 1, InStr(HISTORY_FILE, "\",, -1) - 1)
    if !DirExist(dir)
        DirCreate dir
    try {
        out := ""
        for label, count in gHistory
            out .= label "=" count "`n"
        FileDelete HISTORY_FILE
        FileAppend out, HISTORY_FILE
    }
}

RecordHistory(label) {
    global gHistory
    gHistory[label] := gHistory.Has(label) ? gHistory[label] + 1 : 1
    SaveHistory()
}

GetHistoryBonus(label) {
    global gHistory
    if !gHistory.Has(label)
        return 0
    cnt := gHistory[label]
    return Min(20, Integer(Log(cnt + 1) * 10))
}
