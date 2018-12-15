#SingleInstance force ; there can be only one
SetTitleMatchMode, 2 ; Match some substring of window titles
init()

; FUNCTIONS--------------------------------------------------------------------------------------------------

init(){
	global playing := false
	global mouseX := -1
	global mouseY := -1
	return
}

record_mouse_position(){
	global mouseX
	global mouseY
	mouseX := -1
	mouseY := -1
	MouseGetPos, mouseX, mouseY
	return
}

restore_mouse_position(){
	global mouseX
	global mouseY
	MouseMove, mouseX, mouseY, 0 ; snap back to previous position
	return
}

toggle_play(){
	global playing
	if playing{
		playing := false
	} else {
	playing := true
	}
	return
} ; toggle_play OUT

; set global previewing volume
set_volume(whatVolume){
	maximized := false
	arbitrary := 0 ; this gets overwritten, but the value needs to change for WavePad to actually wake up
	ControlSetText, Edit1, %arbitrary%
	ControlSetText, Edit1, %whatVolume%
	return
}

raise_drc_menu(){
	WinMenuSelectItem, WavePad,,Effects,Dynamic Range Compressor
	return
}

normalize_selection(level){
	WinMenuSelectItem, WavePad,,Effects,Normalize
	WinWait Normalize
	if level{
		Send %level%
	}

	Send {Enter}
	return
}

remove_noise(){
	WinMenuSelectItem, WavePad,,Effects,Noise Reduction,Apply Spectral Subtraction Based on Noise Sample
	return
}

paste_file(fn) {
	path := A_ScriptDir . "\" . fn
	str := ""
	FileRead, str, %path%
	Send %str%
	return
}

; -------------------------------------------------------------------------------------------------/FUNCTIONS




; BINDINGS:--------------------------------------------------------------------------------------------------

; NOTE: ctrlSpace must be natively mapped to the function "Insert Silence at
; current position", because legacy AHK gets messed up since the menu-item is
; called "Insert Silence..." and doesn't appear to tolerate quoting.
; This can be fixed if/when this file is migrated to AHK 2.0+

+F4:: ;shiftF4
	ExitApp
	return

^!r:: ;ctrlAltR
	Reload
	return

^1:: ;ctrl1 paste contents of file 1
	paste_file("1.txt")
	return

^2:: ;ctrl2 -- paste contents of file 2
	paste_file("2.txt")
	return

^3:: ;ctrl3 -- paste contents of file 3
	paste_file("3.txt")
	return

!8:: ; alt8
	MouseClick, right
	Sleep, 200
	Send a ; copy link locAtion
	Sleep, 200
	file := FileOpen("clipstack.txt","a")
	WriteMe := Clipboard
	file.WriteLine(WriteMe)
	file.Close()

#IfWinActive WavePad

^+s:: ;ctrlShiftS -- Save As
	; WinMenuSelectItem, WinTitle, WinText, Menu [, SubMenu1, {...} SubMenu6, ExcludeTitle, ExcludeText]
	WinMenuSelectItem, WavePad,,File,Save File As
	return

^w:: ;ctrlW -- close current file. Supposedly built in, but broken for some reason.
	WinMenuSelectItem, WavePad,,File,Close File
	return

; make a new file and maximize the subwindow
; ^n:: ; ctrlN
; 	WinMenuSelectItem, WavePad,,File,New File
; 	KeyWait, Enter, ;last parameter is for options. Blank waits for release. ; GLITCHY
; 	Sleep, 2000
; 	; set up
; 	x := 0
; 	z := 0
; 	controlHeight := -1
; 	controlWidth := -1
; 	titleBarHeight := 18 ; this is an estimate
; 	;3 try to find the middle of the UI-element:
; 	ControlGetPos x,z,controlWidth,controlHeight,LMC1,WavePad
; 	x := x + controlWidth/2
; 	z := z + titleBarHeight/2
; 	Click %x% %z%
; 	Click %x% %z%
; 	Sleep, 250
; 	Send {Esc} ; sometimes it likes to play the silence oddly so this oughta stop it

Space::
	global playing
	if playing {
		SendInput {Escape}
	} else {
		SendInput {F9}
	}
	toggle_play()
	return


; copy sample background noise ;
!c:: ; altC
	WinMenuSelectItem, WavePad,,Effects,Noise Reduction,Grab Noise Sample from Selected Area
	return

Esc::
	global playing
	playing := false
	WinMenuSelectItem, WavePad,,Control,Stop
	return

; remove background noise based off sample ;
!r:: ; altR
	remove_noise()
	return

\::
	set_volume(-30)
	return

; deamp to 0%
d:: ;
Down:: ; downArrow
	Send {CtrlDown}0{CtrlUp}
	return

; amplify 75%
PgDn:: ; pageDown
	Send {LAlt}
	Send e ; &Effects
	Send a ; &Amplify
	Send 75 ; enter percentage
	Send {Enter}
	return

; raise amplify menu
`::
	Send {LAlt}
	Send e ; &Effects
	Send a ; &Amplify
	return


;open menu for dynamic range compression
!d:: ; altD
	raise_drc_menu()
	return


; Normalize to last value used
PgUp:: ; pageUp
	normalize_selection(0) ; normalize to last used value
	return

Up::
!Up:: ;altUp
^Up:: ;ctrlUp
	normalize_selection(100)
	return

!Right:: ;altRight
^Right:: ;ctrlRight
	normalize_selection(85)
	return

!Left:: ;altLeft
^Left:: ;ctrlLeft
	normalize_selection(65)
	return

; Delete something
:*:xx::{Del}

; Taper out
:*:..:: ; >> or 2/3 ellipses
	Send {LAlt}
	Send e ; &Effects
	Send ff ; &Fade out
	Send {Enter}
	return

; Taper in << or double-comma (,,)
:*:,,::
	Send {LAlt}
	Send e ; &Effects
	Send f ; &Fade in
	Send {Enter}
	return

; block help files from appearing on press
F1:: ; protect F1 protect
	return

; Zoom out
F3::
	yPos := -1
	xPos := -1
	width := -1  ; parameter placeholder for ControlGetPos
	height := -1 ; parameter placeholder
	record_mouse_position()
	ControlGetPos, xPos, yPos, width, height, Button3, WavePad
	xPos := xPos + width/2
	yPos := yPos + height/2
	MouseClick, left, %xPos%, %yPos%, 1, 0 ; left click in center of button once with snap-movement to position
	; ControlClick, Button44, WavePad
	;;^ works but doesn't like to work in succession
	; Send {Ctrl down}{NumpadAdd}{Ctrl up}
	;;^ used to have this but this can make the play skip,
	;;^.. though hitting the button does not. Go figure.
	restore_mouse_position()
	; Send {Ctrl down}{NumpadSub}{Ctrl up}
	;;^ worked but could interrupt play
	return

; Zoom in
F4::
	yPos := -1
	xPos := -1
	width := -1  ; parameter placeholder for ControlGetPos
	height := -1 ; parameter placeholder
	record_mouse_position()
	ControlGetPos, xPos, yPos, width, height, Button2, WavePad
	xPos := xPos + width/2
	yPos := yPos + height/2
	MouseClick, left, %xPos%, %yPos%, 1, 0 ; left click in center of button once with snap-movement to position
	; ControlClick, Button44, WavePad
	;;^ works but doesn't like to work in succession
	; Send {Ctrl down}{NumpadAdd}{Ctrl up}
	;;^ used to have this but this can make the play skip,
	;;^.. though hitting the button does not. Go figure.
	restore_mouse_position()
	return

; #IfWinActive Wavepad OUT

#IfWinActive .flp ; FL Studio adjustments

a:: ; A-key
	Send p
	return

; USAGE NOTE: this works best if the user holds down alt
; Emulating this was attempted but didn't seem effective
!s:: ; altS -- adjust grid snap

	record_mouse_position()

	xLoc := -1 ; upper-right X of match
	yLoc := -1 ; upper-right Y of match

	searchULX := 0 ; x-coord for upper-left of area to search
	searchULY := 0 ; y-coord for upper-left of area to search
	searchLRX := A_ScreenWidth - 1 ; x-coord for lower-right of area to search
	searchLRY := A_ScreenHeight - 1 ; y-coord for lower-right of area to search

	findMe := "magnet.jpg"
	findMe := A_ScriptDir . "\" . findMe
	SetWorkingDir %A_ScriptDir% ; ImageSearch will WorkingDir for file, so look adjacent to script

	prevMode := A_CoordMode

	CoordMode, Pixel
	ErrorLevel = 0
	;ImageSearch, xLoc, yLoc, %searchULX%, %searchULY%, %searchLRX%, %searchLRY%, C:\magnet.jpg
	ImageSearch, xLoc, yLoc, 0, 0, searchLRX, searchLRY, *20 %findMe%
	; TrayTip, Current Error Level, %ErrorLevel%, 2, 1 ; 0 if img found and searched, 1 if not found, 2 if problem reading


	; Adjust to hit center of button: dimensions(magnet.jpg)/2 (it's square):
	xLoc := xLoc + 8
	yLoc := yLoc + 8
	;xLoc := 28
	;yLoc := 92

	MouseClick, left, %xLoc%, %yLoc%, 1, 0, D ; left click+hold in center of button once with snap-movement to position
	Sleep 150
	Send b ; should flop whether 'beat' or 'bar' snapping is selected.
	;.. FL keeps track of which one is selected and starts with caret there,
	;.. so we don't have to mess with doubletaps or whatever
	Sleep 50
	Send {Enter} ; confirm selection, exiting menu
	MouseClick, left, %xLoc%, %yLoc%, 1, 0, U ; left click+hold in center of button once with snap-movement to position
	restore_mouse_position()
	; TrayTip, Current findMe Path, %findMe%, 2, 1 ; 0 if img found and searched, 1 if not found, 2 if problem reading

	humanLocation := "at" . xLoc . "," . yLoc
	; TrayTip, Button Found, %xLoc% , 2, 1 ; 0 if img found and searched, 1 if not found, 2 if problem reading
	; TrayTip [, Title, Text, Duration, 1/2/3 info/warning/error icons]

	CoordMode, Pixel, Relative
	return

CapsLock:: ; Caplock
	record_mouse_position()
	; snap-click the location of the play-pause button
	;.. which is fixed relative to the top of the window]:
	MouseClick, left, 424, 52, 1, 0
	restore_mouse_position()
	return

; #IfWinActive .flp OUT
