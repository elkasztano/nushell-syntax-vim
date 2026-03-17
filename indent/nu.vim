" Vim indent file
" Language:	Nushell
" Maintainer:	El Kasztano
" URL:		https://github.com/elkasztano/nushell-syntax-vim
" License:	MIT <https://opensource.org/license/mit>
" Last Change:	2026 Mar 17

if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

setlocal shiftwidth=2
setlocal softtabstop=2
setlocal expandtab

setlocal autoindent
setlocal indentexpr=GetNuIndent(v:lnum)

setlocal indentkeys=0{,0},0],0),!^F,o,O,e,0|

" cleanup when the filetype changes
let b:undo_indent = "setl ai< et< indk< inde< sts< sw<"

if exists("*GetNuIndent")
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

function! GetNuIndent(lnum)
  " get number of last non-blank line
  let prevlnum = prevnonblank(a:lnum - 1)
  if prevlnum == 0
    return 0
  endif

  " if inside a string or comment, do not change the indent
  let synname = synIDattr(synID(a:lnum, 1, 1), "name")
  if synname =~? 'nuString\|nuComment\|nuRawString'
    return -1
  endif

  let prev_line = getline(prevlnum)
  let cur_line = getline(a:lnum)
  let ind = indent(prevlnum)

  " block indent, also handles closures like { |it|
  let is_block_indent = (prev_line =~# '\v[{\[(]\s*(\|[^|]*\|\s*)?(#.*)?$')
  if is_block_indent
    let ind += shiftwidth()
  endif

  " pipe indent
  let prev_ended_in_pipe = (prev_line =~# '\v\|\s*(#.*)?$') && !is_block_indent
  let cur_starts_with_pipe = (cur_line =~# '\v^\s*\|')

  " look back two lines to see if we are ALREADY in a pipeline
  let prev_prevlnum = prevnonblank(prevlnum - 1)
  let prev_prev_line = prev_prevlnum > 0 ? getline(prev_prevlnum) : ""

  let prev_prev_is_block = (prev_prev_line =~# '\v[{\[(]\s*(\|[^|]*\|\s*)?(#.*)?$')
  let prev_prev_ended_in_pipe = (prev_prev_line =~# '\v\|\s*(#.*)?$') && !prev_prev_is_block
  let prev_started_with_pipe = (prev_line =~# '\v^\s*\|')

  " continue if previous line ended with pipe or started with pipe
  let prev_was_pipeline = prev_started_with_pipe || prev_prev_ended_in_pipe

  " only add an indent if this is the FIRST line of the pipeline
  if (prev_ended_in_pipe || cur_starts_with_pipe) && !prev_was_pipeline
    let ind += shiftwidth()
  endif

  " pipe de-indent
  if prev_was_pipeline && !(prev_ended_in_pipe || cur_starts_with_pipe)
    let ind -= shiftwidth()
  endif

  " block de-indent
  if cur_line =~# '\v^\s*[}\])]'
    let ind -= shiftwidth()
  endif

  return ind
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

