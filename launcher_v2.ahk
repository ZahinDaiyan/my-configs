#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent
;══════════════════════════════════════
; Quality of life
;══════════════════════════════════════

SetCapsLockState "AlwaysOff"

::@@::zahiindaiyan@gmail.com


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


; ═══════════════════════════════════════════════════════════════════════════════
;  APEX LAUNCHER  v2.0
;  Alt+Space  →  open/close
;  Type       →  fuzzy search apps, commands, URLs, math
;  ↑ ↓ Tab    →  navigate results
;  Enter      →  launch selection
;  Esc        →  close
;  Click      →  launch clicked result
; ═══════════════════════════════════════════════════════════════════════════════

; ── LAUNCH HOTKEY ─────────────────────────────────────────────────────────────
global LAUNCH_KEY := "!Space"

; ── WINDOW GEOMETRY ───────────────────────────────────────────────────────────
global WIN_W      := 720
global WIN_H      := 62         ; height with no results
global RESULT_H   := 44
global MAX_RES    := 8
global INPUT_PAD  := 14         ; left padding for input text
global ICON_SIZE  := 20

; ── COLORS ────────────────────────────────────────────────────────────────────
global C_BG        := 0x0e0e0f
global C_BG_SEL    := 0x1a1f2e
global C_BG_ITEM   := 0x141416
global C_SEPARATOR := 0x222228
global C_FG        := 0xdde1ec
global C_FG_DIM    := 0x52566a
global C_FG_SEL    := 0xffffff
global C_ACCENT    := 0x5b9cf6
global C_ACCENT2   := 0xa78bfa
global C_GREEN     := 0x4ade80
global C_ORANGE    := 0xfb923c
global C_INPUT_BG  := 0x0e0e0f

; ── BADGE COLORS PER KIND ─────────────────────────────────────────────────────
global KIND_COLORS := Map(
    "cmd",   0x5b9cf6,
    "app",   0x4ade80,
    "url",   0xfb923c,
    "math",  0xa78bfa,
    "file",  0x38bdf8
)
global KIND_ICONS := Map(
    "cmd",   "❯",
    "app",   "◈",
    "url",   "⊕",
    "math",  "∑",
    "file",  "◻"
)

; ── EXTRA SEARCH FOLDERS ──────────────────────────────────────────────────────
global EXTRA_DIRS := [
    EnvGet("USERPROFILE") "\Desktop",
    EnvGet("USERPROFILE") "\Downloads"
]

; ── BUILT-IN COMMANDS ─────────────────────────────────────────────────────────
global Builtins := Map(
    "lock",           Map("cmd", "LockWorkStation",                          "desc", "Lock the screen"),
    "sleep",          Map("cmd", "rundll32.exe powrprof.dll,SetSuspendState 0,1,0", "desc", "Sleep the PC"),
    "shutdown",       Map("cmd", "shutdown /s /t 0",                         "desc", "Shut down"),
    "restart",        Map("cmd", "shutdown /r /t 0",                         "desc", "Restart"),
    "logout",         Map("cmd", "shutdown /l",                              "desc", "Log out"),
    "cmd",            Map("cmd", "pwsh",                                      "desc", "Powershell 7 Preview"),
    "powershell",     Map("cmd", "powershell",                               "desc", "PowerShell"),
    "terminal",       Map("cmd", "wt",                                       "desc", "Windows Terminal"),
    "notepad",        Map("cmd", "notepad",                                  "desc", "Text editor"),
    "explorer",       Map("cmd", "explorer",                                 "desc", "File Explorer"),
    "task manager",   Map("cmd", "taskmgr",                                  "desc", "Task Manager"),
    "taskmgr",        Map("cmd", "taskmgr",                                  "desc", "Task Manager"),
    "regedit",        Map("cmd", "regedit",                                  "desc", "Registry Editor"),
    "calculator",     Map("cmd", "calc",                                     "desc", "Calculator"),
    "paint",          Map("cmd", "mspaint",                                  "desc", "MS Paint"),
    "settings",       Map("cmd", "ms-settings:",                             "desc", "Windows Settings"),
    "snip",           Map("cmd", "SnippingTool",                             "desc", "Snipping Tool"),
    "control panel",  Map("cmd", "control",                                  "desc", "Control Panel"),
    "device manager", Map("cmd", "devmgmt.msc",                              "desc", "Device Manager"),
    "services",       Map("cmd", "services.msc",                             "desc", "Services"),
    "event viewer",   Map("cmd", "eventvwr.msc",                             "desc", "Event Viewer"),
    "disk management",Map("cmd", "diskmgmt.msc",                             "desc", "Disk Management"),
    "winver",         Map("cmd", "winver",                                   "desc", "Windows version"),
    "hosts",          Map("cmd", "notepad C:\Windows\System32\drivers\etc\hosts", "desc", "Edit hosts file"),
    "env",            Map("cmd", "rundll32.exe sysdm.cpl,EditEnvironmentVariables", "desc", "Environment variables"),
    "clipboard",      Map("cmd", "ms-settings:clipboard",                    "desc", "Clipboard settings"),
    "store",          Map("cmd", "ms-windows-store:",                        "desc", "Microsoft Store"),
    "wsl",            Map("cmd", "wsl",                                      "desc", "Windows Subsystem for Linux")
)

; ── LAUNCH HISTORY  (frequency map  label → count) ────────────────────────────
global gHistory    := Map()
global HISTORY_FILE := A_AppData "\ApexLauncher\history.ini"

; ── STATE ─────────────────────────────────────────────────────────────────────
global gResults    := []
global gSel        := 0
global gGui        := 0
global gEdit       := 0
global gRows       := []        ; array of row objects {bg, icon, label, desc, badge}
global gDebounce   := 0
global gVisible    := false
global gLastQuery  := ""

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
;  BUILD GUI  (called once)
; ═══════════════════════════════════════════════════════════════════════════════
BuildGui() {
    global gGui, gEdit, gRows

    gGui := Gui("+AlwaysOnTop -Caption +LastFound +E0x08000000", "ApexLauncher")
    gGui.BackColor := Format("{:06X}", C_BG)
    gGui.MarginX   := 0
    gGui.MarginY   := 0

    ; Search icon
    gGui.SetFont("s15 c" Format("{:06X}", C_ACCENT), "Segoe UI Symbol")
    gGui.Add("Text", "x14 y16 w26 h30 +BackgroundTrans", "⌕")

    ; Input field
    gGui.SetFont("s13 c" Format("{:06X}", C_FG) " q5", "Segoe UI")
    gEdit := gGui.Add("Edit",
        "x46 y13 w" (WIN_W - 62) " h36 -E0x200 Background" Format("{:06X}", C_INPUT_BG))
    gEdit.OnEvent("Change", OnTypeDebounce)

    ; Keyboard hooks (active only when launcher window is focused)
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

    ; Center on the active monitor
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
;  DEBOUNCED INPUT
; ═══════════════════════════════════════════════════════════════════════════════
OnTypeDebounce(*) {
    global gDebounce
    if gDebounce
        SetTimer gDebounce, 0
    gDebounce := ProcessInput.Bind()
    SetTimer gDebounce, -80     ; 80ms debounce
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
;  SEARCH ENGINE
; ═══════════════════════════════════════════════════════════════════════════════
DoSearch(q) {
    global Builtins, MAX_RES, gHistory, EXTRA_DIRS
    results := []
    qL      := StrLower(q)

    ; ── 1. Math expression ──────────────────────────────────────────────────
    mathVal := TryMath(q)
    if (mathVal != "") {
        results.Push(Map(
            "label", mathVal,
            "desc",  "= " q,
            "path",  mathVal,
            "kind",  "math",
            "score", 100
        ))
    }

    ; ── 2. URL / path detection ─────────────────────────────────────────────
    if IsUrl(q) {
        url := (SubStr(q, 1, 4) = "http") ? q : "https://" q
        results.Push(Map("label", q, "desc", "Open URL", "path", url, "kind", "url", "score", 90))
    }
    if IsLocalPath(q) {
        results.Push(Map("label", q, "desc", "Open path", "path", q, "kind", "file", "score", 88))
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

    ; ── 4. Start Menu .lnk files ────────────────────────────────────────────
    dirs := [
        EnvGet("APPDATA")     "\Microsoft\Windows\Start Menu\Programs",
        EnvGet("PROGRAMDATA") "\Microsoft\Windows\Start Menu\Programs"
    ]
    for d in EXTRA_DIRS
        dirs.Push(d)

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

    ; ── 5. Also search .exe on Desktop & Downloads ──────────────────────────
    for dir in EXTRA_DIRS {
        loop files dir "\*.exe" {
            cleanName := StrReplace(A_LoopFileName, ".exe", "")
            sc := FuzzyScore(StrLower(cleanName), qL)
            if (sc > 0)
                results.Push(Map(
                    "label", cleanName,
                    "desc",  dir,
                    "path",  A_LoopFileFullPath,
                    "kind",  "app",
                    "score", sc + GetHistoryBonus(cleanName)
                ))
        }
    }

    ; ── 6. Sort by score descending ─────────────────────────────────────────
    results := SortResults(results)

    ; ── 7. Trim to MAX_RES - 1, then append Google search ───────────────────
    while results.Length >= MAX_RES
        results.RemoveAt(results.Length)

    results.Push(Map(
        "label", 'Search  "' q '"',
        "desc",  "google.com",
        "path",  "https://www.google.com/search?q=" q,
        "kind",  "url",
        "score", 0
    ))

    return results
}

; ── Fuzzy scoring ─────────────────────────────────────────────────────────────
;   100 = exact match
;    80 = prefix match
;    60 = substring match
;    40 = subsequence (every char of query appears in order)
;     0 = no match
FuzzyScore(haystack, needle) {
    h := StrLower(haystack)
    n := StrLower(needle)
    if (h = n)
        return 100
    if SubStr(h, 1, StrLen(n)) = n
        return 80
    if InStr(h, n)
        return 60
    ; subsequence check — every char of needle must appear in order in haystack
    pos := 1
    nLen := StrLen(n)
    i := 1
    while i <= nLen {
        ch  := SubStr(n, i, 1)
        found := InStr(h, ch,, pos)
        if !found
            return 0
        pos := found + 1
        i++
    }
    return 40
}

SortResults(arr) {
    ; simple insertion sort (list is small)
    loop arr.Length - 1 {
        i := A_Index + 1
        while i > 1 && arr[i]["score"] > arr[i-1]["score"] {
            tmp        := arr[i]
            arr[i]     := arr[i-1]
            arr[i-1]   := tmp
            i--
        }
    }
    return arr
}

; ── Math evaluator ────────────────────────────────────────────────────────────
TryMath(q) {
    ; Only attempt if it looks like a math expression
    if !RegExMatch(q, "^[\d\s\+\-\*\/\^\(\)\.%]+$")
        return ""
    try {
        ; Use WSH to evaluate safely
        sc := ComObject("ScriptControl")
        sc.Language := "JScript"
        val := sc.Eval(q)
        return String(val)
    }
    return ""
}

; ── URL / path detection ──────────────────────────────────────────────────────
IsUrl(q) {
    return RegExMatch(q, "i)^(https?://|www\.|[\w-]+\.(com|net|org|io|dev|ai|co|app|me|tv|gg)(/|$))")
        || RegExMatch(q, "^localhost(:\d+)?")
        || RegExMatch(q, "^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}")
}

IsLocalPath(q) {
    return RegExMatch(q, "^[a-zA-Z]:\\") || SubStr(q, 1, 2) = "\\"
}

; ═══════════════════════════════════════════════════════════════════════════════
;  RESULTS UI
; ═══════════════════════════════════════════════════════════════════════════════
global gSepCtrl := 0   ; the separator line control (destroyed on clear)

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

    ; Separator line
    gSepCtrl := gGui.Add("Progress", "x0 y" WIN_H " w" WIN_W " h1 Background" Format("{:06X}", C_SEPARATOR))
    gSepCtrl.Value := 0

    yPos := WIN_H + 1

    for i, r in results {
        kind   := r["kind"]
        kColor := KIND_COLORS.Has(kind) ? KIND_COLORS[kind] : C_FG_DIM
        kIcon  := KIND_ICONS.Has(kind)  ? KIND_ICONS[kind]  : "·"

        ; Row background
        bg := gGui.Add("Progress",
            "x0 y" yPos " w" WIN_W " h" RESULT_H " Background" Format("{:06X}", C_BG_ITEM))
        bg.Value := 0

        ; Kind icon
        gGui.SetFont("s11 c" Format("{:06X}", kColor) " q5", "Segoe UI Symbol")
        iconCtrl := gGui.Add("Text",
            "x14 y" (yPos + 13) " w18 h20 Background" Format("{:06X}", C_BG_ITEM), kIcon)

        ; Main label
        gGui.SetFont("s11 c" Format("{:06X}", C_FG) " q5", "Segoe UI")
        labelCtrl := gGui.Add("Text",
            "x36 y" (yPos + 7) " w" (WIN_W - 160) " h18 Background" Format("{:06X}", C_BG_ITEM),
            r["label"])

        ; Description / subtitle
        descText := r.Has("desc") ? r["desc"] : ""
        gGui.SetFont("s8 c" Format("{:06X}", C_FG_DIM) " q5", "Segoe UI")
        descCtrl := gGui.Add("Text",
            "x36 y" (yPos + 26) " w" (WIN_W - 160) " h14 Background" Format("{:06X}", C_BG_ITEM),
            descText)

        ; Badge (kind label, right-aligned)
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

; Handle mouse clicks on result rows
OnMessage(0x201, WM_LBUTTONDOWN)  ; WM_LBUTTONDOWN
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

        bgCol    := isSel ? C_BG_SEL  : C_BG_ITEM
        fgCol    := isSel ? C_FG_SEL  : C_FG
        accentCol := isSel ? kCol     : kCol     ; icon keeps kind color always

        try {
            row.bg.Opt("Background"        Format("{:06X}", bgCol))
            row.iconCtrl.Opt("Background"  Format("{:06X}", bgCol) " c" Format("{:06X}", accentCol))
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
    else
        Run "https://www.google.com/search?q=" q
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
        ; Copy result to clipboard
        A_Clipboard := path
        return
    }

    if (kind = "cmd") {
        if (path = "LockWorkStation") {
            DllCall("LockWorkStation")
            return
        }
        ; Check if it's a rundll32 / special command
        if RegExMatch(path, "^rundll32|^shutdown|^wsl") {
            Run path,, "Hide"
            return
        }
        try Run path
        catch as e
            ShowToast("Failed: " e.Message)
        return
    }

    if (kind = "url") {
        Run path
        return
    }

    if (kind = "file") {
        try Run path
        catch
            try Run "explorer.exe /select,`"" path "`""
        return
    }

    ; app (.lnk or executable)
    try Run path
    catch {
        try Run label
        catch as e
            ShowToast("Could not launch: " label)
    }
}

; ═══════════════════════════════════════════════════════════════════════════════
;  TOAST NOTIFICATION  (brief error / info display)
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
;  LAUNCH HISTORY
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
    ; logarithmic bonus, max +20
    return Min(20, Integer(Log(cnt + 1) * 10))
}
