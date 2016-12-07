if get(g:, 'loaded_autoload_ctrlp_session')
  finish
endif
let g:loaded_autoload_ctrlp_session = 1
let s:save_cpo = &cpo
set cpo&vim

let s:session_dir = get(g:, 'ctrlp_session_dir', '~/.vim/session')
let s:session_path = fnamemodify(expand(s:session_dir), ':p')
let s:current_session_name = ''

function! s:get_session_list() abort
  return glob(s:session_path . '*.vim', 0, 1)
endfunction

function! s:get_session_file_path(session_name) abort
  return fnamemodify(s:session_path . a:session_name . '.vim', ':p')
endfunction

function! ctrlp#session#delete(session_name) abort
  let session_file = s:get_session_file_path(a:session_name)
  if confirm('Delete ' . a:session_name . '.vim ?', "&No\n&Yes") == 2
    call delete(session_file)
  endif
endfunction

function! ctrlp#session#save(session_name) abort
  let session_name = a:session_name != '' ? a:session_name : s:current_session_name
  if session_name == ''
    let session_name = 'default'
  endif
  let session_file = s:get_session_file_path(session_name)
  if !filereadable(session_file)
    if confirm('Create ' . session_name . '.vim ?', "&No\n&Yes") != 2
      return
    endif
  endif
  execute 'silent mksession! ' . session_file
  let s:current_session_name = session_name
endfunction

function! ctrlp#session#completion(...) abort
  return map(s:get_session_list(), 'fnamemodify(v:val, ":p:t:r")')
endfunction

let g:ctrlp_ext_var = add(get(g:, 'ctrlp_ext_vars', []), {
      \ 'init': 'ctrlp#session#init()',
      \ 'accept': 'ctrlp#session#accept',
      \ 'lname': 'session extension',
      \ 'sname': 'session',
      \ 'type': 'path',
      \ 'nolim': 1
      \})

let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)
function! ctrlp#session#id() abort
  return s:id
endfunction

function! ctrlp#session#init(...) abort
  return map(s:get_session_list(), 'fnamemodify(v:val, ":p:t:r")')
endfunction

function! ctrlp#session#accept(mode, str) abort
  call ctrlp#exit()
  let session_file = s:get_session_file_path(a:str)
  if a:mode == 'h'
    call ctrlp#session#delete(a:str)
  else
    " update session name
    let s:current_session_name = a:str
    " close all current buffer
    execute 'silent bufdo bwipeout'
    execute 'source ' . session_file
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
