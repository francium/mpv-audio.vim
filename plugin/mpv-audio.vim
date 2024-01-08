let s:AUDIO_PLAYER_BUFFER_NAME = "Audio Player"

function! s:CloseExistingAudioPlayerBuffer()
    for buffer_id in nvim_list_bufs()
        if bufexists(buffer_id) == 0
            continue
        endif
        let l:buffer_name = bufname(buffer_id)
        if l:buffer_name != s:AUDIO_PLAYER_BUFFER_NAME
            continue
        endif
        execute "bdelete! " . buffer_id
    endfor
endfunc

function! s:PlayWithMpv(path)
    if strchars(a:path) == 0
        echom "Invalid selection. Make sure to not select the newline character at the end of a line."
        return
    endif

    call s:CloseExistingAudioPlayerBuffer()
    let l:quoted_path = '"' . a:path . '"'
    echom "Playing " . l:quoted_path
    execute "10split"
    execute "terminal echo Playing " . l:quoted_path . " && mpv --no-video --keep-open=no " . l:quoted_path
    execute "file " . s:AUDIO_PLAYER_BUFFER_NAME
    normal A
endfunc

function! s:MpvPlayAudio()
    normal viWy
    call s:PlayWithMpv(@")
endfunc

function! s:MpvPlayAudioRange() range
    " Code for selection from https://stackoverflow.com/questions/47098852
    let l:first_col = virtcol("'<")
    let l:last_col = virtcol("'>")
    let l:selection = matchstr(getline('.'), '\v^.{'.(first_col-1).'}\zs.{'.(last_col-first_col+1).'}')
    call s:PlayWithMpv(selection)
endfunc

com! MpvPlayAudio call s:MpvPlayAudio()
com! -range MpvPlayAudioRange call s:MpvPlayAudioRange()
