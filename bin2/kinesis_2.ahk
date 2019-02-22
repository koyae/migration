; Below is just a set of mappings for the Kinesis Freestyle 2 keyboard.

#UseHook

Pause:: ; printscreen-key
	Send, {Insert}
	return

!Home:: ; altHome (sent when the Web key is pressed)
	Send, {PrintScreen}
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
