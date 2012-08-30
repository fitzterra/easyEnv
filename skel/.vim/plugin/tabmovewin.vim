" Vim global plugin for moving tabed windows left or right.
"  
" Last Change:	2012 August 29
" Maintainer:	Tom Coetser <tomc@icave.net>
" License:	This file is placed in the public domain.
"

if exists("loaded_tabmovewin")
  finish
endif
let loaded_tabmovewin = 1

function MoveThisTabLeft()
  " echo "Moving left.."
  " Get the total number of open tabs
  let l:num_tabs = tabpagenr('$')
  " echo "Num tabs: " . l:num_tabs
  " If there is only one tab open, we bail
  if l:num_tabs == 1
    return
  endif
  " Get the current tab number
  let l:tab_nr = tabpagenr()
  " echo "My tab number: " . l:tab_nr
  " Moving left, we want to go AFTER the tab that is 2 tabs from where we
  " are now
  let l:tab_dest = l:tab_nr - 2
  " echo "Moving to AFTER tab num: " . l:tab_dest
  " Did we wrap around?
  if l:tab_dest < 0
    let l:tab_dest = l:num_tabs
    " echo "But that is a wrap, so moving to AFTER tab num: " . l:tab_dest
  endif
  " Move it
  exe "tabmove " . l:tab_dest
endfunc

function MoveThisTabRight()
  " echo "Moving right.."
  " Get the total number of open tabs
  let l:num_tabs = tabpagenr('$')
  " echo "Num tabs: " . l:num_tabs
  " If there is only one tab open, we bail
  if l:num_tabs == 1
    return
  endif
  " Get the current tab number
  let l:tab_nr = tabpagenr()
  " echo "My tab number: " . l:tab_nr
  " Moving right, we want to go AFTER our current tab number - weird, but it
  " seems that is how tabmove works
  let l:tab_dest = l:tab_nr
  " echo "Moving to AFTER tab num: " . l:tab_dest
  " Did we wrap around?
  if l:tab_dest == l:num_tabs
    let l:tab_dest = 0
    " echo "But that is a wrap, so moving to AFTER tab num: " . l:tab_dest
  endif
  " Move it
  exe "tabmove " . l:tab_dest
endfunc


nnoremap <A-.> :call MoveThisTabRight()<CR>
nnoremap <A-,> :call MoveThisTabLeft()<CR>

