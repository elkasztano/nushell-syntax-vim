# nushell syntax installation script
# this is my very first nushell script
# use at your own risk

let system_os = (sys).host.long_os_version

if not ($system_os starts-with "Linux") {
  print $"your system: '($system_os)'"
  print "currently only Linux systems supported - exiting"
  exit 1
}

let vimdir = $"($env.HOME)/.vim"

if not ( $vimdir | path exists ) {
  print $"creating '($vimdir)'"
  mkdir $vimdir
} else {
  print $"directory '($vimdir)' already exists"
}

let dirlist = [ $"($env.HOME)/.vim/syntax", $"($env.HOME)/.vim/ftplugin", $"($env.HOME)/.vim/ftdetect" ]

$dirlist | where not ($it | path exists) | each { 
  |it| 
  print $"creating directory '($it)'"
  mkdir $it
} | ignore

let filetable = [
{src: $"($env.PWD)/syntax/nu.vim", trg: $"($env.HOME)/.vim/syntax"},
{src: $"($env.PWD)/ftplugin/nu.vim", trg: $"($env.HOME)/.vim/ftplugin"},
{src: $"($env.PWD)/ftdetect/nu.vim", trg: $"($env.HOME)/.vim/ftdetect"}
]

$filetable | each {
  |it|
  print $"copying (ansi -e '0;1m')'($it.src)'(ansi -e '0m') to (ansi -e '0;1m')'($it.trg)'(ansi -e '0m')"
  cp $it.src $it.trg
} | ignore
