; JoshsAutoHotKey.ahk
; Version 1.2
; 2009-03-18
;
; Original version from
; http://www.autohotkey.com/docs/scripts/EasyWindowDrag_(KDE).htm
;
; The shortcuts:
;  Alt + Left Button         : Drag to move a window.
;  Alt + Right Button        : Drag to resize a window.
;  Control + Alt + WheelUp   : Maximize a window
;  Control + Alt + WheelDown : Restore a window
;  Super + WheelDown         : Minimize a window
;  WheelUp                   : Focus window under cursor, then send wheel up
;  WheelDown                 : Focus window under cursor, then send wheel down
;  Super + Middle Button     : Send window to background
;
; You can optionally release Alt after the first
; click rather than holding it down the whole time.

; From Mike Zwagerman, 2009-03-18:
; This changes increase the Maximum Number of Hotkeys allowed
; per interval from the default of 70 to 200
#MaxHotkeysPerInterval 200

#SingleInstance force

If (A_AhkVersion < "1.0.39.00")
{
    MsgBox,20,,This script may not work properly with your version of AutoHotkey. Continue?
    IfMsgBox,No
    ExitApp
}


; This is the setting that runs smoothest on my
; system. Depending on your video card and cpu
; power, you may want to raise or lower this value.
SetWinDelay,2

CoordMode,Mouse
return

;!LButton::
;#LButton::
;;If DoubleAlt
;;{
;;    MouseGetPos,,,KDE_id
;;    ; This message is mostly equivalent to WinMinimize,
;;    ; but it avoids a bug with PSPad.
;;    PostMessage,0x112,0xf020,,,ahk_id %KDE_id%
;;    DoubleAlt := false
;;    return
;;}
;; Get the initial mouse position and window id, and
;; abort if the window is maximized.
;MouseGetPos,KDE_X1,KDE_Y1,KDE_id
;WinGet,KDE_Win,MinMax,ahk_id %KDE_id%
;If KDE_Win
;    return
;WinActivate,ahk_id %KDE_id%
;; Get the initial window position.
;WinGetPos,KDE_WinX1,KDE_WinY1,WinWidth,WinHeight,ahk_id %KDE_id%
;Loop
;{
;    GetKeyState,KDE_Button,LButton,P ; Break if button has been released.
;    If KDE_Button = U
;        break
;    MouseGetPos,KDE_X2,KDE_Y2 ; Get the current mouse position.
;    KDE_X2 -= KDE_X1 ; Obtain an offset from the initial mouse position.
;    KDE_Y2 -= KDE_Y1
;    KDE_WinX2 := (KDE_WinX1 + KDE_X2) ; Apply this offset to the window position.
;    KDE_WinY2 := (KDE_WinY1 + KDE_Y2)
;
;;    SysGet,Mon1,Monitor,1
;;    SysGet,Mon2,Monitor,2
;;    MsgBox, (%Mon1Left%,%Mon1Top%,%Mon1Right%,%Mon1Bottom%), (%Mon2Left%,%Mon2Top%,%Mon2Right%,%Mon2Bottom%)
;
;    WinMove,ahk_id %KDE_id%,,%KDE_WinX2%,%KDE_WinY2% ; Move the window to the new position.
;}
;return

;!RButton::
;#RButton::
;;If DoubleAlt
;;{
;;    MouseGetPos,,,KDE_id
;;    ; Toggle between maximized and restored state.
;;    WinGet,KDE_Win,MinMax,ahk_id %KDE_id%
;;    If KDE_Win
;;        WinRestore,ahk_id %KDE_id%
;;    Else
;;        WinMaximize,ahk_id %KDE_id%
;;    DoubleAlt := false
;;    return
;;}
;; Get the initial mouse position and window id, and
;; abort if the window is maximized.
;MouseGetPos,KDE_X1,KDE_Y1,KDE_id
;WinGet,KDE_Win,MinMax,ahk_id %KDE_id%
;If KDE_Win
;    return
;WinActivate,ahk_id %KDE_id%
;; Get the initial window position and size.
;WinGetPos,KDE_WinX1,KDE_WinY1,KDE_WinW,KDE_WinH,ahk_id %KDE_id%
;; Define the window region the mouse is currently in.
;; The four regions are Up and Left, Up and Right, Down and Left, Down and Right.
;If (KDE_X1 < KDE_WinX1 + KDE_WinW / 2)
;   KDE_WinLeft := 1
;Else
;   KDE_WinLeft := -1
;If (KDE_Y1 < KDE_WinY1 + KDE_WinH / 2)
;   KDE_WinUp := 1
;Else
;   KDE_WinUp := -1
;; left only
;If (KDE_X1 < KDE_WinX1 + KDE_WinW / 4 and abs(KDE_Y1 - KDE_WinY1 - KDE_WinH / 2) < KDE_WinH / 4)
;    KDE_WinUp := 0
;If (KDE_X1 > KDE_WinX1 + 3 * KDE_WinW / 4 and abs(KDE_Y1 - KDE_WinY1 - KDE_WinH / 2) < KDE_WinH / 4)
;    KDE_WinUp := 0
;If (KDE_Y1 < KDE_WinY1 + KDE_WinH / 4 and abs(KDE_X1 - KDE_WinX1 - KDE_WinW / 2) < KDE_WinW / 4)
;    KDE_WinLeft := 0
;If (KDE_Y1 > KDE_WinY1 + 3 * KDE_WinH / 4 and abs(KDE_X1 - KDE_WinX1 - KDE_WinW / 2) < KDE_WinW / 4)
;    KDE_WinLeft := 0
;Loop
;{
;    GetKeyState,KDE_Button,RButton,P ; Break if button has been released.
;    If KDE_Button = U
;        break
;    MouseGetPos,KDE_X2,KDE_Y2 ; Get the current mouse position.
;    ; Get the current window position and size.
;    WinGetPos,KDE_WinX1,KDE_WinY1,KDE_WinW,KDE_WinH,ahk_id %KDE_id%
;    If KDE_WinLeft = 0
;        KDE_X2 := 0
;    Else
;        KDE_X2 -= KDE_X1 ; Obtain an offset from the initial mouse position.
;    If KDE_WinUp = 0
;        KDE_Y2 := 0
;    Else
;        KDE_Y2 -= KDE_Y1
;    ; Then, act according to the defined region.
;    WinMove,ahk_id %KDE_id%,, KDE_WinX1 + (KDE_WinLeft+1)/2*KDE_X2  ; X of resized window
;                            , KDE_WinY1 +   (KDE_WinUp+1)/2*KDE_Y2  ; Y of resized window
;                            , KDE_WinW  -     KDE_WinLeft  *KDE_X2  ; W of resized window
;                            , KDE_WinH  -       KDE_WinUp  *KDE_Y2  ; H of resized window
;    KDE_X1 += KDE_X2 ; Reset the initial position for the next iteration.
;    KDE_Y1 += KDE_Y2
;}
;return

; This detects "double-clicks" of the alt key.
;~Alt::
;DoubleAlt := A_PriorHotKey = "~Alt" AND A_TimeSincePriorHotkey < 400
;Sleep 0
;KeyWait Alt  ; This prevents the keyboard's auto-repeat feature from interfering.
;return

#WheelDown::
MouseGetPos,,,KDE_id
WinMinimize,ahk_id %KDE_id%
return

^!WheelUp::
MouseGetPos,,,KDE_id
WinMaximize,ahk_id %KDE_id%
return

^!WheelDown::
MouseGetPos,,,KDE_id
WinRestore,ahk_id %KDE_id%
return

; Added by Josh 2008-11-20
; Super + middle-click will lower (send window to back)
#MButton::
MouseGetPos,,,KDE_id
WinSet,Bottom,,ahk_id %KDE_id%
return

; Added by Josh 2008-12-02
; scrolling the mouse wheel anywhere will activate the window
; that is under the cursor at that screen position
; also sends the event along to the application...
$WheelDown::
MouseGetPos,,,KDE_id
WinActivate,ahk_id %KDE_id%
; added 2008-12-03 to send a middle-button click to Windows
; Explorer windows so I can scroll in the "Folders" pane and
; the main pane independently
WinGetClass class,ahk_id %KDE_id%
if (class = "ExploreWClass" or class = "CabinetWClass")
{
    Send {MButton}
}
Send {WheelDown}
return

$WheelUp::
MouseGetPos,,,KDE_id
WinActivate,ahk_id %KDE_id%
WinGetClass class,ahk_id %KDE_id%
if (class = "ExploreWClass" or class = "CabinetWClass")
{
    Send {MButton}
}
Send {WheelUp}
return
