# nushell-syntax-vim
Nushell syntax highlighting and indentation for Vim

## Installation
* create the ~/.vim directory and required subdirectories if they do not already exist
```
mkdir -p ~/.vim/ftdetect && \
mkdir -p ~/.vim/ftplugin && \
mkdir -p ~/.vim/syntax && \
mkdir -p ~/.vim/indent
```

* copy the .vim-files to their corresponding directories in ~/.vim
* restart vim, if necessary

## Installation using Vim Package (recommended)

* requires vim 8+
* tested with vim (but nvim should be working)
* just clone to you vim pack dir

```
git clone https://github.com/elkasztano/nushell-syntax-vim ~/.vim/pack/plugins/start
```

## Installation using Nushell script (experimental)
* requires 'nu' to be in your PATH
* use at your own risk
* tested with Nushell 0.104.0 on Debian 12 and Windows 11

```
git clone "https://github.com/elkasztano/nushell-syntax-vim" && \
cd nushell-syntax-vim && \
nu install.nu
```

to uninstall navigate to the 'nushell-syntax-vim' directory, then type
```
nu uninstall.nu
```

## Dynamic generation of a syntax file
Let Nushell write the syntax file.

Running `gen-vim-syntax.nu` generates a `nu.vim` syntax file in the current directory based on your active Nushell installation's built-in `help` output.

Just copy the generated `nu.vim` to your `syntax` directory.

_Warning:_ This script will silently overwrite `nu.vim` in the current working directory.

## Notes
I am new to both Nushell and Vimscript, and I am currently learning both at the same time. Please bear in mind that this little project is still very much a work in progress. I couldn't find a Nushell plugin for Vim, so I decided to create one myself.
Suggestions for improvement are highly appreciated.

Tested with Vim 9.1
