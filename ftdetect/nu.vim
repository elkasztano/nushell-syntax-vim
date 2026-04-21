autocmd BufRead,BufNewFile *.nu set filetype=nu

" shebang detection
autocmd BufRead,BufNewFile * if getline(1) =~# '^#!.*\<nu\>' | set filetype=nu | endif
