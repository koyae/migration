; Below is just a set of mappings for the Kinesis Freestyle 2 keyboard.

#UseHook On

; make WinActive will match text anywhere in a window title:
SetTitleMatchMode, 2

Pause:: ; printscreen-key
	Send, {Insert}
	return

+Pause:: ; shiftPausebreak pastes
	SendInput %clipboard%
	return
; ^ While I'd prefer to just directly send shiftInsert to avoid any
; consequences of doing the above, this doesn't work in Windows'
; Linux-subsystem shells because there's actually no hotkey to bind to paste
; whatsoever.
;
; Theoretically there's one coming, per stackoverflow.com/questions/38832230 but
; it's not present in the production release yet.

!-:: ; altMinus / alt-
	Winset, AlwaysOnTop, , A
	return

F4::
	if WinActive("Unity") {
		Send {WheelUp 4}
	} else if WinActive("Firefox") {
		Send {WheelUp 1}
	} else if WinActive("Blender") {
		Send {WheelUp 1}
	} else if WinActive("GIMP") {
		Send {F4}
	} else if WinActive("PDF-XChange") {
		Send ^{=}
	} else if WinActive("Word") {
		Send ^{WheelUp 1}
	} else {
		Send {WheelUp 1}
	}
	return

F3::
	if WinActive("Unity") {
		Send {WheelDown 4}
	}else if WinActive("Firefox") {
		Send {WheelDown 1}
	} else if WinActive("Blender") {
		Send {WheelDown 1}
	} else if WinActive("GIMP") {
		Send {F3}
	} else if WinActive("PDF-XChange") {
		Send ^{-}
	} else if WinActive("Word") {
		Send ^{WheelDown 1}
	} else {
		Send {WheelDown 1}
	}
	return

^l:: ; ctrlL opens library tab
	; NOTE: The only issue with the below implementation is that the offset (75)
	; given to ImageSearch (used because searching the entire screen takes too
	; long) only appears to work if the window is maximized or docked on the
	; LEFT side of the screen. If the window is shifted right, the target button
	; is not found. It's not clear why this doesn't work, since the
	; documentation indicates the coordinates are window-relative by default.
	;
	; Note that for different monitor-resolutions, you may have to replace or
	; update the library-button images accordingly so the search can succeed.
	; I've included two but you could potentially convert to loop if you have
	; more monitors than that which have disperate resolutions.
	;
	if WinActive("OneNote") {
		CoordMode, Pixel, Client
		WinGetPos, winX, winY, winW, winH, OneNote
		; Below, we allow 25 (of 255) degrees of wiggle-room since DllCall()
		; results in the hover-color of the button sticking around, so we
		; account for that in case the mouse hasn't been moved manulally
		ImageSearch, libX, libY, 0, 0, 75, A_ScreenHeight, *25 onenote_library_symbol.jpg
		if (ErrorLevel = 1) {
			ImageSearch, libX, libY, 0, 0, 75, A_ScreenHeight, *25 onenote_library_symbol2.jpg
		}
		if (ErrorLevel = 2) {
			MsgBox Search could not init
		} else if (ErrorLevel != 1) {
			CoordMode, Mouse, Screen
			MouseGetPos, mouseReturnX, mouseReturnY
			CoordMode Mouse, Client
			clickHereX := libX + (47/2)
			clickHereY := libY + 16
			MouseMove, %clickHereX%, %clickHereY%, 1
			Click
			DllCall("SetCursorPos", "int", mouseReturnX, "int", mouseReturnY)
			; ^ This works better for resetting the mouse to its old position if
			; there are multiple monitors. Otherwise the mouse does not return
			; to its previous position as expected
		}
	} else {
		Send ^l
	}


; META CONTROLS:

^+F5:: ; ctrlShiftF5
	Reload
	return
