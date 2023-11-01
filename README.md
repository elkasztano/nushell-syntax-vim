# nushell-syntax-vim
Nushell syntax highlighting and indentation for Vim

## Installation
* create the ~/.vim directory and required subdirectories if they do not already exist
```
mkdir -p ~/.vim/ftdetect && mkdir -p ~/.vim/ftplugin && mkdir -p ~/.vim/syntax
```

* copy the .vim-files to their corresponding directories in ~/.vim
* restart vim, if necessary

## Installation using Nushell script (experimental)
* requires 'nu' to be in your PATH
* use at your own risk
* tested with Nushell 0.86.0 on Debian 12

```
git clone "https://github.com/elkasztano/nushell-syntax-vim"
cd nushell-syntax-vim
nu ./install.nu
```

to uninstall navigate to the 'nushell-syntax-vim' directory, then type
```
nu ./uninstall.nu
```

## Notes
I am new to both Nushell and Vimscript, and I am currently learning both at the same time. Please bear in mind that this little project is still very much work in progress. I couldn't find a way to get Nushell syntax highlighting in Vim, so I decided to implement it myself.
Suggestions for improvement are highly appreciated.

Tested with Vim 9.0
