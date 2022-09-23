set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
unmap Y
source ~/.vimrc

lua require('plugins')
lua require('lsp_keys')

