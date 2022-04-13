oldContents := ""
loop {
	Sleep, 1000
	if (oldContents != Clipboard and SubStr(Clipboard, 1, 4) = "http") {
	; if clipboard contents have changed and appear to contain a URL, grab the
	; open the URL in the default browser, wait a moment, and then switch back
	; to the previous window:
		WinGetActiveTitle, title
		Run %Clipboard%
		Sleep, 450
		WinActivate, %title%
	}
	oldContents := Clipboard
}