# nushell syntax installation script
# this is my very first nushell script
# use at your own risk

let system_os = (sys host).long_os_version

print $"your system: '($system_os)'"

if ($system_os starts-with "Linux") {
  
  let vimdir = $"($env.HOME)/.vim"
  
  let dirlist = [
    $"($vimdir)/syntax",
    $"($vimdir)/ftplugin",
    $"($vimdir)/ftdetect",
    $"($vimdir)/indent"
  ]
  
  let filetable = [
    {src: $"($env.PWD)/syntax/nu.vim", trg: $"($vimdir)/syntax"},
    {src: $"($env.PWD)/ftplugin/nu.vim", trg: $"($vimdir)/ftplugin"},
    {src: $"($env.PWD)/ftdetect/nu.vim", trg: $"($vimdir)/ftdetect"},
    {src: $"($env.PWD)/indent/nu.vim", trg: $"($vimdir)/indent"}
  ]

  install $vimdir $dirlist $filetable

} else if ($system_os starts-with "Windows") {
  
  let homedir = $"($env.HOMEDRIVE)($env.HOMEPATH)"

  let vimdir = $"($homedir)\\vimfiles"
  
  let dirlist = [
    $"($vimdir)\\syntax",
    $"($vimdir)\\ftplugin",
    $"($vimdir)\\ftdetect",
    $"($vimdir)\\indent"
  ]

  let filetable = [
    {src: $"($env.PWD)\\syntax\\nu.vim", trg: $"($vimdir)\\syntax"},
    {src: $"($env.PWD)\\ftplugin\\nu.vim", trg: $"($vimdir)\\ftplugin"},
    {src: $"($env.PWD)\\ftdetect\\nu.vim", trg: $"($vimdir)\\ftdetect"},
    {src: $"($env.PWD)\\indent\\nu.vim", trg: $"($vimdir)\\indent"}
  ]

  install $vimdir $dirlist $filetable

} else {
  print $"(ansi -e '0;33;1m')currently only Linux or Windows systems supported - exiting(ansi -e '0m')"
  exit 1
}

def install [vimdir, dirlist, filetable] {

  if not ( $vimdir | path exists ) {
    print $"creating '($vimdir)'"
    mkdir $vimdir
  } else {
    print $"directory '($vimdir)' already exists"
  }

  $dirlist | where not ($it | path exists) | each { 
    |it| 
    print $"creating directory '($it)'"
    mkdir $it
  } | ignore

  $filetable | each {
    |it|
    print $"copying (ansi -e '0;1m')'($it.src)'(ansi -e '0m') to (ansi -e '0;1m')'($it.trg)'(ansi -e '0m')"
    cp $it.src $it.trg
  } | ignore

}
