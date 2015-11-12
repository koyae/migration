function! SettingGuardSave(settingName)
	let g:lastSettingName=a:settingName
	let doThis='let g:' . a:settingName . 'OLD' . '=&' . a:settingName
	exec doThis
endfunction

" TODO: find a way to give a coherent message if SettingGuardSave wasn't
" called first, and therefore there's no known setting to fall back to
function! SettingGuardRestore(...)
	let settingName = 'someString'
	if len(a:000)
		let settingName=a:0
	elseif exists('g:lastSettingName')
		let settingName=g:lastSettingName
	else
		echo 'no settings to resore!'
		return
	endif
	let doThis='let &' . settingName . '=g:' . settingName . 'OLD'
	exec doThis
	let doThis='unlet g:' . settingName . 'OLD'
	exec doThis
endfunction
