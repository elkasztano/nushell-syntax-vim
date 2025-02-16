# nushell syntax uninstall script
# use at your own risk

let system_os = (sys host).long_os_version

if ($system_os starts-with "Linux") {

  let vimdir = $"($env.HOME)/.vim"
  
  let filelist = [
    $"($vimdir)/syntax/nu.vim",
    $"($vimdir)/indent/nu.vim",
    $"($vimdir)/ftdetect/nu.vim",
    $"($vimdir)/ftplugin/nu.vim"
  ]

  uninstall $vimdir $filelist

} else if ($system_os starts-with "Windows") {

  let homedir = $"($env.HOMEDRIVE)($env.HOMEPATH)"

  let vimdir = $"($homedir)\\vimfiles"

  let filelist = [
    $"($vimdir)\\syntax\\nu.vim",
    $"($vimdir)\\indent\\nu.vim",
    $"($vimdir)\\ftdetect\\nu.vim",
    $"($vimdir)\\ftplugin\\nu.vim"
  ]

  uninstall $vimdir $filelist

} else {
  print $"(ansi -e '0;33;1m')currently only Linux or Windows systems supported(ansi -e '0m')"
  print "please remove the files manually"
  exit 1
}

def uninstall [vimdir, filelist] {

  if not ( $vimdir | path exists ) {
    print $"'($vimdir)' does not exist"
    print "nothing to uninstall - exiting"
    exit 0
  }

  $filelist | each {
    |it|
    if ( $it | path exists ) {
      rm --interactive $it
    } else {
      print $"file (ansi -e '0;1m')'($it)'(ansi -e '0m') not found"
      print "no file means nothing to remove\n"
    }
  }
}

print ""
