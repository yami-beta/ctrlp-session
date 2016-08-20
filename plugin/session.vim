if get(g:, 'loaded_ctrlp_session')
  finish
endif
let g:loaded_ctrlp_session = 1
let s:save_cpo = &cpo
set cpo&vim

command! CtrlPSession call ctrlp#init(ctrlp#session#id())
command! -nargs=? -complete=customlist,ctrlp#session#completion SSave call ctrlp#session#save(<q-args>)
command! -nargs=? -complete=customlist,ctrlp#session#completion SDelete call ctrlp#session#delete(<q-args>)

let &cpo = s:save_cpo
unlet s:save_cpo
