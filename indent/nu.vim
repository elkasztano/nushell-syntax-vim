" Vim indent file
" Language:    Nushell
" Maintainer:  El Kasztano
" URL:         https://github.com/elkasztano/nushell-syntax-vim
" License:     MIT <https://opensource.org/license/mit>
" Last Change: 2026 September 26

if exists("b:did_indent")
	finish
endif
let b:did_indent = 1

setlocal shiftwidth=2
setlocal softtabstop=2
setlocal expandtab

setlocal autoindent
setlocal indentexpr=GetNuIndent(v:lnum)

setlocal indentkeys=0{,0},0],0),!^F,o,O,0|

let b:undo_indent = "setl ai< et< indk< inde< sts< sw<"

if exists("*GetNuIndent")
	finish
endif

let s:save_cpo = &cpo
set cpo&vim

function! s:CleanLine(line) abort
	let line = substitute(a:line, '#.*$', '', '')
	let line = substitute(line, '[\s\u00a0]\+$', '', '')
	return line
endfunction

function! s:IsClosureParameter(line) abort
	return a:line =~# '^\s*|[^|]*|\s*$'
endfunction

function! s:FindMatchingOpen(lnum, col, open, close) abort
	let depth = 1
	let lnum = a:lnum
	let col = a:col - 1
	let in_string = 0
	let quote = ''

	while lnum > 0
		let line = getline(lnum)

		" Scan backwards through the line.
		while col > 0
			let char = strpart(line, col - 1, 1)

			" A # starts a comment when we are not inside a string.
			if !in_string && char == '#'
				let col -= 1

				" Skip the rest of the comment while scanning backwards.
				while col > 0
					let char = strpart(line, col - 1, 1)

					if char =~ "\s"
						let col -= 1
					else
						break
					endif
				endwhile

				" Find the beginning of the comment.
				while col > 0
					let char = strpart(line, col - 1, 1)

					if char == ' '
					\ || char == "\t"
					\ || char == '#'
						break
					endif

					let col -= 1
				endwhile

				continue
			endif

			" When scanning backwards, a quote toggles string state.
			if char == '"' || char == "'"
				" Determine whether this quote is escaped.
				let escaped = 0
				let check_col = col - 1

				while check_col > 0
					let prev_char = strpart(line, check_col - 1, 1)

					if prev_char == '\'
						let escaped = !escaped
						let check_col -= 1
					else
						break
					endif
				endwhile

				if !escaped
					if in_string
						if char == quote
							let in_string = 0
							let quote = ''
						endif
					else
						let in_string = 1
						let quote = char
					endif
				endif

				let col -= 1
				continue
			endif

			if !in_string
				if char == a:close
					let depth += 1
				elseif char == a:open
					let depth -= 1

					if depth == 0
						return lnum
					endif
				endif
			endif

			let col -= 1
		endwhile

		let lnum -= 1

		if lnum > 0
			let col = strlen(getline(lnum))
		endif
	endwhile

	return 0
endfunction

function! GetNuIndent(lnum)
	let prevlnum = prevnonblank(a:lnum - 1)

	if prevlnum == 0
		return 0
	endif

	let prev_line = getline(prevlnum)
	let cur_line = getline(a:lnum)

	let prev_clean = s:CleanLine(prev_line)

	" Do not alter indentation if the previous line was a comment.
	let prev_syn = synIDattr(
				\ synID(prevlnum, indent(prevlnum) + 1, 1),
				\ "name"
				\ )

	if prev_syn =~? 'nuComment'
		return indent(prevlnum)
	endif

	let ind = indent(prevlnum)

	" Opening braces, brackets and parentheses all behave identically.
	if prev_clean =~ '[{[(]\s*$'
		let ind += shiftwidth()
	endif

	" Pipe indent logic
	" A line such as "|it|" is a Nushell closure parameter declaration,
	" not a pipeline continuation.
	let prev_is_closure_parameter = s:IsClosureParameter(prev_clean)
	let cur_is_closure_parameter = s:IsClosureParameter(cur_line)

	let prev_ended_in_pipe = (
				\ prev_clean =~ '|\s*$'
				\ ) &&
				\ !(prev_clean =~ '[{[(]\s*$') &&
				\ !prev_is_closure_parameter

	let cur_starts_with_pipe = (
				\ cur_line =~ '^\s*|'
				\ ) &&
				\ !cur_is_closure_parameter

	let prev_prevlnum = prevnonblank(prevlnum - 1)

	if prev_prevlnum > 0
		let prev_prev_line = getline(prev_prevlnum)
	else
		let prev_prev_line = ""
	endif

	let prev_prev_clean = s:CleanLine(prev_prev_line)
	let prev_prev_is_closure_parameter =
				\ s:IsClosureParameter(prev_prev_clean)

	let prev_started_with_pipe = (
				\ prev_line =~ '^\s*|'
				\ ) &&
				\ !prev_is_closure_parameter

	let prev_prev_ended_in_pipe = (
				\ prev_prev_clean =~ '|\s*$'
				\ ) &&
				\ !(prev_prev_clean =~ '[{[(]\s*$') &&
				\ !prev_prev_is_closure_parameter

	let prev_was_pipeline = prev_started_with_pipe || prev_prev_ended_in_pipe

	if (prev_ended_in_pipe || cur_starts_with_pipe) && !prev_was_pipeline
		let ind += shiftwidth()
	elseif prev_was_pipeline && !(prev_ended_in_pipe || cur_starts_with_pipe)
		let ind -= shiftwidth()
	endif

	" Block de-indent
	" Find the matching opening delimiter and use its indentation.
	" The matching scanner ignores brackets inside strings and comments.
	if cur_line =~ '^\s*[}\])]'
		let close = matchstr(cur_line, '^\s*\zs[}\])]')

		if close == '}'
			let open = '{'
		elseif close == ']'
			let open = '['
		else
			let open = '('
		endif

		let close_col = match(cur_line, close) + 1

		let match_lnum = s:FindMatchingOpen(
					\ a:lnum,
					\ close_col,
					\ open,
					\ close
					\ )

		if match_lnum > 0
			let ind = indent(match_lnum)
		else
			" Fallback for an unmatched closing delimiter.
			let ind -= shiftwidth()
		endif
	endif

	return max([0, ind])
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
