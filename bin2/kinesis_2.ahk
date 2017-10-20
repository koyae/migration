; Below is just a set of mappings for the Kinesis Freestyle 2 keyboard.

; The mappings reduce the amount of reach and switch a few keys around in the
; Home column so they match that of the ASUS HL90, which had the same keys in
; a vertical row to the right of the Enter key as the Freestyle does, but in a
; different sequence than the freestyle.

#UseHook

PgDn:: ; pageDown-key
	Send, {End}
	return
^PgDn:: ; ctrlPagedown
	Send, {CtrlDown}{End}{CtrlUp}
	return
+PgDn:: ; shiftPagedown
	Send, {ShiftDown}{End}{ShiftUp}
	return
^+PgDn:: ; ctrlShiftPagedown
	Send, {CtrlDown}{ShiftDown}{End}{ShiftUp}{CtrlUp}
	return

End:: ; end-key
	Send, {PgUp}
	return
^End:: ; ctrlEnd
	Send, {CtrlDown}{Pgup}{CtrlUp}
	return
+End:: ; shiftEnd
	Send, {ShiftDown}{End}{ShiftUp}
	return
^+End:: ; ctrlShiftEnd
	Send, {ShiftDown}{CtrlDown}{PgUp}{CtrlUp}{ShiftUp}
	return


PgUp:: ; pageUp-key
	Send, {PgDn}
	return
^PgUp:: ; ctrlPageup
	Send, {CtrlDown}{PgDn}{CtrlUp}
	return
+PgUp:: ; shiftPageup
	Send, {ShiftDown}{PgDn}{ShiftUp}
	return

^Home:: ; ctrlHome
	; Below, send a normal ctrlHome if the right ctrl-key is used.
	; If the left ctrl-key is used, simulate a ctrlDelete keypress instead.
	GetKeyState, which, LCtrl
	if which = D
		Send, {CtrlDown}{Del}{CtrlUp}
	else
		Send, {CtrlDown}{Home}{CtrlUp}
	return

F1:: ; F1-key
	Send, {Escape}
	return

F7:: ; F7-key
	Send, {F5}
	return

PrintScreen:: ; printscreen-key
	Send, {Insert}
	return

!Home:: ; altHome (sent when the Web key is pressed)
	Send, {PrintScreen}
	return

Pause:: ; pauseBreak-key
	Send, {Delete}
	return
^Pause:: ; ctrlPausebreak
	Send, {CtrlDown}{Delete}{CtrlUp}
	return
+Pause:: ; shiftPausebreak pastes
	Send, {ShiftDown}{Insert}{ShiftUp}
	return

!-:: ; altMinus / alt-
	Winset, AlwaysOnTop, , A
	return

; META CONTROLS:

^+F5:: ; ctrlShiftF5
	Reload
	return
