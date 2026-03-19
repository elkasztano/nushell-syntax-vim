" Vim filetype plugin
" Language:	Nushell
" Maintainer:	El Kasztano
" URL:		https://github.com/elkasztano/nushell-syntax-vim
" License:	MIT <https://opensource.org/license/mit>
" Last Change:	2026 Mar 17

if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

setlocal commentstring=#\ %s
setlocal comments=b:#,:#
setlocal formatoptions-=t
setlocal formatoptions+=croql

setlocal iskeyword+=$,-,?

let b:undo_ftplugin = "setl fo< cms< com< isk< | unlet! b:match_words"
