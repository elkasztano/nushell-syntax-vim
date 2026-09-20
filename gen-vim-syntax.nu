# target output path
let output_file = "nu.vim"

# dynamically generate command syntax rules
let cmd_rules = (
    help commands 
    | get name 
    | sort 
    | uniq 
    | each {|cmd|
        let opts = match $cmd {
            "const" | "def" | "def-env" => "nextgroup=nuIdtfr,nuSubCmd,nuDefflag skipwhite display",
            "export const" | "export def" | "export def-env" | "export extern" | "export extern-wrapped" | "export module" | "let" | "let-env" | "module" | "mut" | "overlay use" => "nextgroup=nuIdtfr skipwhite display",
            "from" | "get" | "group-by" | "sort-by" | "split-by" | "uniq-by" | "where" => "nextgroup=nuPrpty skipwhite display",
            _ => "display"
        }
        $"syn match nuCmd \"\\<($cmd)\\>\" ($opts)"
    } 
    | str join "\n"
)

# dynamically generate operator syntax rules
let op_rules = (
    help operators 
    | get operator 
    | each {|op| $op | split row "," }
    | flatten
    | str trim 
    | where {|op| $op != "" } 
    | uniq 
    | sort 
    | each {|op|
        let is_word = ($op =~ '^[a-zA-Z0-9_-]+$')
        if $is_word {
            let opts = match $op {
                "in" | "not-in" | "and" | "or" | "xor" => "nextgroup=nuPrpty skipwhite display",
                _ => "display"
            }
            $"syn match nuOp \"\\<($op)\\>\" ($opts)"
        } else {
            # use \V (Very Nomagic) so Vim treats all symbols literally
            let escaped = ($op | str replace -a '\' '\\' | str replace -a '"' '\"')
            $"syn match nuOp \"\\V($escaped)\" display"
        }
    } 
    | str join "\n"
)

# header block
const script_path = ( path self | path parse --extension '' | get stem )
const version = ( version | get version )
let header = r#'" Vim syntax file
" Language: Nushell '# + $version + r#'
" This syntax file was automatically generated using the following script:
" '# + $script_path + r#'
" Date of generation: '# + (date now | format date '%Y %b %d') + r#'

if exists("b:current_syntax")
  finish
endif

syn iskeyword @,192-255,-,_
'#

# static definitions between commands and operators
let mid_block = r#'
syn match nuNumber "\([a-zA-Z_\.]\+\d*\)\@<!\.\{0,2\}-\?\.\?\d\+[eE0-9\.+-<]*" nextgroup=nuUnit,nuDur

syn keyword nuTodo contained TODO FIXME NOTE
syn match nuComment "#.*$" contains=nuTodo
'#

# static definitions following operators
let footer = r##'
syn match nuVar '\$[[:alpha:]_][[:alnum:]_-]*'
syn match nuNestedVar '\$[[:alpha:]_][[:alnum:]_-]*' contained

syn match nuIdtfr :\(-\+\)\@![^? \t"=]\+: contained

syn region nuSubCmd start=/"/ skip=/\\./ end=/"/ contained

syn match nuPrpty '\w\+' contained

syn keyword nuType any binary bool cell-path closure datetime directory duration error filesize float glob int list nothing number path range record string table true false null

syn keyword nuCondi if then else

syn match nuUnit "b\>" contained
syn match nuUnit "kb\>" contained
syn match nuUnit "mb\>" contained
syn match nuUnit "gb\>" contained
syn match nuUnit "tb\>" contained
syn match nuUnit "pb\>" contained
syn match nuUnit "eb\>" contained
syn match nuUnit "kib\>" contained
syn match nuUnit "mib\>" contained
syn match nuUnit "gib\>" contained
syn match nuUnit "tib\>" contained
syn match nuUnit "pib\>" contained
syn match nuUnit "eib\>" contained

syn match nuDur "ns\>" contained
syn match nuDur "us\>" contained
syn match nuDur "ms\>" contained
syn match nuDur "sec\>" contained
syn match nuDur "min\>" contained
syn match nuDur "hr\>" contained
syn match nuDur "day\>" contained
syn match nuDur "wk\>" contained

syn match nuFlag "\<-\k\+"

syn match nuDefflag "\<--env\>" display contained nextgroup=nuIdtfr skipwhite
syn match nuDefflag "\<--wrapped\>" display contained nextgroup=nuIdtfr skipwhite

syn match nuSysCom "\^[^\$]\S\+" display
syn match nuSysComVar "\^\$\S\+" display

syn match nuSqrbr "\[" display
syn match nuSqrbr "\]" display
syn match nuSqrbr ":" display

syn region nuRawString start=/r\z(#\+\)'/ end=/'\z1/ contains=NONE
syn region nuString start=/\v"/ skip=/\v\\./ end=/\v"/ contains=nuEscaped
syn region nuString start='\'' end='\''
syn region nuString start='`' end='`'

syn region nuStrInt start=/$'/ end=/'/ contains=nuNested
syn region nuStrInt start=/$"/ skip=/\\./ end=/"/ contains=nuNested,nuEscaped

syn region nuNested start=/\\\@<!(/ end=/\\\@<!)/ skip=/\\./ contained contains=nuAnsi,nuNested,nuStrInt,nuNestedVar

syn match nuAnsi "ansi[a-zA-Z0-9;' -]\+)"me=e-1 contained

syn match nuClosure "|\(\w\|, \)\+|"

syn match nuDot ")\.\(\k\|\.\)\+"ms=s+1 display

syn match nuEscaped "\\\\" display
syn match nuEscaped :\\": display
syn match nuEscaped "\\n" display
syn match nuEscaped "\\t" display
syn match nuEscaped "\\r" display

hi def link nuCmd    Keyword
hi def link nuComment    Comment
hi def link nuTodo    Todo
hi def link nuRawString    Constant
hi def link nuString    Constant
hi def link nuChar    Constant
hi def link nuOp    Operator
hi def link nuVar    PreProc
hi def link nuSqrBr    Special
hi def link nuIdtfr    Identifier
hi def link nuType    Type
hi def link nuUnit    Type
hi def link nuDur    Type
hi def link nuPrpty    Special
hi def link nuSubCmd    Identifier
hi def link nuStrInt    Constant
hi def link nuNested    PreProc
hi def link nuNestedVar    Type
hi def link nuFlag    Special
hi def link nuEscaped    Special
hi def link nuCondi    Type
hi def link nuClosure    Type
hi def link nuNumber    Number
hi def link nuDot    Special
hi def link nuSysCom    Italic
hi def link nuSysComVar BoldItalic
hi def link nuAnsi    Special
hi def link nuDefflag    Special

syntax sync minlines=100
syntax sync match nuSyncRawString grouphere nuRawString /r#\+'/
syntax sync match nuSyncRawString groupthere NONE /'#\+/

let b:current_syntax = "nu"
'##

# combine sections, save to target file, and print feedback
$"($header)\n($cmd_rules)\n($mid_block)\n($op_rules)\n($footer)" | save -f $output_file

print $"Generated Vim syntax file saved to: ($output_file | path expand)"
