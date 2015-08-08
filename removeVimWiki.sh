#!/bin/bash

# Script to remove vimwiki from VIM ecosystem for this user.

cd ~/.vim || exit 1
rm -rf autoload/vimwiki
rm -f doc/vimwiki.txt
rm -f ftplugin/vimwiki.vim
rm -f plugin/vimwiki.vim
rm -f syntax/vimwiki*.vim

# Reset vim help after removing vimwikidocs
vim -c "helptags doc/|q"
