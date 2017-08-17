; Below is just a set of mappings for the Kinesis Freestyle 2 keyboard.

; The mappings reduce the amount of reach and switch a few keys around in the
; Home column so they match that of the ASUS HL90, which had the same keys in
; a vertical row to the right of the Enter key as the Freestyle does, but in a 
; different sequence than the freestyle.

Pgdn:: ; pageDown-key
	Send, {NumpadEnd}
	return
^PgDn:: ; ctrlPagedown
	Send, {CtrlDown}{NumpadEnd}{CtrlUp}
	return
+Pgdn:: ; shiftPagedown
	Send, {ShiftDown}{NumpadEnd}{ShiftUp}
	return

End:: ; end-key
	Send, {NumpadPgup}
	return
^End:: ; ctrlEnd
	Send, {CtrlDown}{NumpadPgup}{CtrlUp}
	return
+End:: ; shiftEnd
	Send, {ShiftDown}{NumpadEnd}{ShiftUp}
	return

PgUp:: ; pageUp-key
	Send, {NumpadPgdn}
	return
^PgUp:: ; ctrlPageup
	Send, {CtrlDown}{NumpadPgdn}{CtrlUp}
	return
+PgUp:: ; shiftPageup
	Send, {ShiftDown}{NumpadPgdn}{ShiftUp}
	return

^Home:: ; ctrlHome
	; Below, send a normal ctrlHome if the right ctrl-key is used.
	; If the left ctrl-key is used, simulate a ctrlDelete keypress instead.
	GetKeyState, which, LCtrl
	if which = D
		Send, {CtrlDown}{Delete}{CtrlUp}
	else
		Send, {CtrlDown}{Home}{CtrlUp}
	return

F1:: ; F1-key
	Send, {Escape}
	return

Pause:: ; pauseBreak-key
	Send, {Delete}
	return
^Pause:: ; ctrlPausebreak
	Send, {CtrlDown}{Pause}{CtrlUp}
	return