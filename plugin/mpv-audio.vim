let s:AUDIO_PLAYER_BUFFER_NAME = "Audio Player"
let s:YOUTUBE_URL_REGEX = "https\\?://www.youtube.com/watch?v=\[a-zA-Z0-9_-\]\\+"

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
    execute "normal! \<c-w>p"
endfunc

" Initial implementation that relies on word boundaries to find current URL.
" Doesn't work in all cases.
function! s:MpvPlayAudioV1()
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

" Uses a regex to find URL. Currently limited, but lays a foundation for more
" flexible URL detection.
function! s:MpvPlayAudio()
    let l:cur_line = getline(".")
    let l:url = matchstr(l:cur_line, s:YOUTUBE_URL_REGEX)
    if empty(l:url)
        echo "Count not find a URL on current line"
        return
    endif
    call s:PlayWithMpv(l:url)
endfunc

com! MpvPlayAudioV1 call s:MpvPlayAudioV1()
com! MpvPlayAudio call s:MpvPlayAudio()
com! -range MpvPlayAudioRange call s:MpvPlayAudioRange()
