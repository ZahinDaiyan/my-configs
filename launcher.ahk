#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

; ─────────────────────────────────────────────
;  LAUNCHER  —  Alt+Space to open
;  Type to search, Enter to launch, Esc to close
; ─────────────────────────────────────────────

; ── CONFIG ────────────────────────────────────
global LAUNCH_KEY  := "!Space"
global WIN_W       := 560
global WIN_H       := 58
global RESULT_H    := 36
global MAX_RESULTS := 8

; ── COLORS ────────────────────────────────────
global C_BG       := 0x0d0d0d
global C_BG_SEL   := 0x1e1e1e
global C_BG_ITEM  := 0x141414
global C_BORDER   := 0x2a2a2a
global C_FG       := 0xe8e8e8
global C_FG_DIM   := 0x666666
global C_ACCENT   := 0x55aaff
global C_INPUT_BG := 0x0d0d0d

; ── BUILT-IN COMMANDS ─────────────────────────
global Builtins := Map(
    "lock",           "LockWorkStation",
    "sleep",          "rundll32.exe powrprof.dll,SetSuspendState 0,1,0",
    "shutdown",       "shutdown /s /t 0",
    "restart",        "shutdown /r /t 0",
    "logout",         "shutdown /l",
    "cmd",            "cmd",
    "powershell",     "powershell",
    "terminal",       "wt",
    "notepad",        "notepad",
    "explorer",       "explorer",
    "task manager",   "taskmgr",
    "taskmgr",        "taskmgr",
    "regedit",        "regedit",
    "calculator",     "calc",
    "paint",          "mspaint",
    "settings",       "ms-settings:",
    "snip",           "SnippingTool",
    "control panel",  "control",
    "device manager", "devmgmt.msc",
    "services",       "services.msc",
    "event viewer",   "eventvwr.msc",
    "disk management","diskmgmt.msc"
)

; ── STATE ─────────────────────────────────────
global gResults        := []
global gSel            := 0
global gGui            := 0
global gEdit           := 0
global gResultControls := []

; ─────────────────────────────────────────────
;  REGISTER HOTKEY
; ─────────────────────────────────────────────
HotKey LAUNCH_KEY, ToggleLauncher

ToggleLauncher(*) {
    if WinExist("Launcher ahk_class AutoHotkeyGUI")
        HideLauncher()
    else
        ShowLauncher()
}

; ─────────────────────────────────────────────
;  BUILD GUI
; ─────────────────────────────────────────────
BuildGui() {
    global gGui, gEdit, gResultControls

    gGui := Gui("+AlwaysOnTop -Caption +LastFound", "Launcher")
    gGui.BackColor := Format("{:06X}", C_BG)
    gGui.MarginX   := 0
    gGui.MarginY   := 0

    gGui.SetFont("s16 c" Format("{:06X}", C_ACCENT), "Segoe UI")
    gGui.Add("Text", "x12 y14 w28 h30", "⌕")

    gGui.SetFont("s14 c" Format("{:06X}", C_FG), "Segoe UI")
    gEdit := gGui.Add("Edit",
        "x44 y10 w" (WIN_W - 60) " h38 -E0x200 Background" Format("{:06X}", C_INPUT_BG))
    gEdit.OnEvent("Change", OnType)

    gGui.OnEvent("Close", HideLauncher)

    HotIfWinActive "Launcher ahk_class AutoHotkeyGUI"
    HotKey "Enter",  OnEnter
    HotKey "Escape", (*) => HideLauncher()
    HotKey "Down",   (*) => MoveSelection(1)
    HotKey "Up",     (*) => MoveSelection(-1)
    HotKey "Tab",    (*) => MoveSelection(1)
    HotIf

    gResultControls := []
}

; ─────────────────────────────────────────────
;  SHOW / HIDE
; ─────────────────────────────────────────────
ShowLauncher(*) {
    global gGui, gEdit

    if !IsObject(gGui)
        BuildGui()

    gEdit.Value := ""
    ClearResults()

    x := (A_ScreenWidth  - WIN_W) // 2
    y := (A_ScreenHeight * 28)    // 100

    gGui.Show("x" x " y" y " w" WIN_W " h" WIN_H)
    gEdit.Focus()
}

HideLauncher(*) {
    global gGui
    if IsObject(gGui)
        gGui.Hide()
}

; ─────────────────────────────────────────────
;  SEARCH
; ─────────────────────────────────────────────
OnType(*) {
    global gEdit
    q := Trim(gEdit.Value)
    if (q = "") {
        ClearResults()
        return
    }
    ShowResults(DoSearch(q))
}

DoSearch(q) {
    global Builtins, MAX_RESULTS
    results := []
    qL      := StrLower(q)

    for name, cmd in Builtins {
        if InStr(name, qL)
            results.Push(Map("label", name, "path", cmd, "kind", "cmd"))
        if results.Length >= MAX_RESULTS
            return results
    }

    dir1 := EnvGet("APPDATA")     "\Microsoft\Windows\Start Menu\Programs"
    dir2 := EnvGet("PROGRAMDATA") "\Microsoft\Windows\Start Menu\Programs"

    for dir in [dir1, dir2] {
        loop files dir "\*.lnk", "R" {
            if InStr(StrLower(A_LoopFileName), qL) {
                cleanName := StrReplace(A_LoopFileName, ".lnk", "")
                results.Push(Map("label", cleanName, "path", A_LoopFileFullPath, "kind", "app"))
            }
            if results.Length >= MAX_RESULTS - 2
                break
        }
        if results.Length >= MAX_RESULTS - 2
            break
    }

    if InStr(q, ".") && !InStr(q, " ") {
        url := (SubStr(q, 1, 4) = "http") ? q : "https://" q
        results.Push(Map("label", "Open " q, "path", url, "kind", "url"))
    }

    results.Push(Map(
        "label", 'Search "' q '"',
        "path",  "https://www.google.com/search?q=" q,
        "kind",  "url"
    ))

    while results.Length > MAX_RESULTS
        results.RemoveAt(results.Length)

    return results
}

; ─────────────────────────────────────────────
;  RESULTS UI
; ─────────────────────────────────────────────
ClearResults() {
    global gGui, gResultControls, gResults, gSel

    for ctrl in gResultControls {
        try ctrl.Destroy()
    }
    gResultControls := []
    gResults        := []
    gSel            := 0

    if IsObject(gGui)
        gGui.Move(,, WIN_W, WIN_H)
}

ShowResults(results) {
    global gGui, gResultControls, gResults, gSel

    ClearResults()
    if !results.Length
        return

    gResults := results
    gSel     := 1

    sep := gGui.Add("Progress", "x0 y" WIN_H " w" WIN_W " h1 Background" Format("{:06X}", C_BORDER))
    sep.Value := 0
    gResultControls.Push(sep)

    yPos := WIN_H + 1

    for i, r in results {
        row := gGui.Add("Progress",
            "x0 y" yPos " w" WIN_W " h" RESULT_H " Background" Format("{:06X}", C_BG_ITEM))
        row.Value := 0
        gResultControls.Push(row)

        gGui.SetFont("s10 c" Format("{:06X}", C_FG), "Segoe UI")
        lbl := gGui.Add("Text",
            "x14 y" (yPos + 9) " w" (WIN_W - 80) " h20 Background" Format("{:06X}", C_BG_ITEM),
            r["label"])
        gResultControls.Push(lbl)

        kindText := (r["kind"] = "cmd") ? "cmd" : (r["kind"] = "app") ? "app" : "web"
        gGui.SetFont("s8 c" Format("{:06X}", C_FG_DIM), "Segoe UI")
        bdg := gGui.Add("Text",
            "x" (WIN_W - 52) " y" (yPos + 11) " w44 h16 +Right Background" Format("{:06X}", C_BG_ITEM),
            kindText)
        gResultControls.Push(bdg)

        yPos += RESULT_H
    }

    gGui.Move(,, WIN_W, WIN_H + 1 + results.Length * RESULT_H)
    Highlight(1)
}

Highlight(idx) {
    global gResults, gSel, gResultControls

    gSel := idx

    loop gResults.Length {
        i     := A_Index
        base  := 1 + (i - 1) * 3 + 1
        isSel := (i = idx)
        bgCol := isSel ? C_BG_SEL : C_BG_ITEM
        fgCol := isSel ? C_ACCENT : C_FG

        try {
            gResultControls[base].Opt("Background" Format("{:06X}", bgCol))
            gResultControls[base+1].Opt("Background" Format("{:06X}", bgCol) " c" Format("{:06X}", fgCol))
            gResultControls[base+2].Opt("Background" Format("{:06X}", bgCol))
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

; ─────────────────────────────────────────────
;  LAUNCH
; ─────────────────────────────────────────────
OnEnter(*) {
    global gResults, gSel, gEdit

    q := Trim(gEdit.Value)
    if !q
        return

    HideLauncher()

    if gResults.Length
        LaunchResult(gResults[gSel], q)
    else
        Run "https://www.google.com/search?q=" q
}

LaunchResult(r, q) {
    kind := r["kind"]
    path := r["path"]

    if (kind = "cmd") {
        if (path = "LockWorkStation")
            DllCall("LockWorkStation")
        else
            Run path,, "Hide"
    } else if (kind = "url") {
        Run path
    } else {
        try Run path
        catch {
            try Run r["label"]
        }
    }
}
