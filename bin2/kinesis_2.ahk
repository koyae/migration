; Below is just a set of mappings for the Kinesis Freestyle 2 keyboard.

#UseHook

Pause:: ; printscreen-key
	Send, {Insert}
	return

!Home:: ; altHome (sent when the Web key is pressed)
	Send, {PrintScreen}
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

; META CONTROLS:

^+F5:: ; ctrlShiftF5
	Reload
	return
