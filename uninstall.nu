# nushell syntax uninstall script
# use at your own risk

let system_os = (sys).host.name

if not ($system_os ends-with "GNU/Linux") {
  print $"your system: '($system_os)'"
  print "currently only GNU/Linux systems supported - exiting"
  exit 1
}

let vimdir = $"($env.HOME)/.vim"

if not ( $vimdir | path exists ) {
  print $"'($vimdir)' does not exist"
  print "nothing to uninstall - exiting"
  exit 1
}

let dirlist = [ "syntax", "ftplugin", "ftdetect" ]

$dirlist | each {
  |it|
  let fullpath = $"($env.HOME)/.vim/($it)/nu.vim"
  if ( $fullpath | path exists ) {
    rm --interactive $fullpath
  } else {
    print $"file (ansi -e '0;1m')'($fullpath)'(ansi -e '0m') not found"
    print "no file means nothing to remove\n"
  }

}

print ""
