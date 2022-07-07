" EASICS VERSION

" TABS ARE 8 SPACES, NO DISCUSSION POSSIBLE
set tabstop=8

" Default colorscheme (can be overwritten in vimrc.local)
colorscheme murphy

" Bundles
if filereadable(expand("~/.vimrc.bundles"))
  source ~/.vimrc.bundles
endif

""" Mappings
"" All modes
" To previous buffer
nnoremap <F1> :bp
" To next buffer
nnoremap <F2> :bn
" To alternate buffer
nnoremap <F3> :b#
" Go to previous tab in vim
nmap <S-F1> :tabp<CR>
" Go to next tab in vim
nmap <S-F2> :tabn<CR>
" Open alternate buffer in a horizontal split, on the right
nnoremap <S-F3> :execute "rightbelow vsplit " . bufname("#")
" Set current directory for current window
nnoremap <F4> :lcd %:p:h<CR>
" Replace tabs by blanks, trailing spaces by nothing
nmap <S-F4> :retab<CR>g/./s/ \+$//<CR>
" Display the next error in the list
nnoremap <F5> :cnext
nnoremap <F6> :cprevious
" In a long file: force syntax highlighting when in middle of file
nmap <S-F5> syntax sync fromstart
autocmd FileType cpp nmap <F7> :call AddMagic()
autocmd FileType ari nmap <F7> :call AddMagicAri()
" Alternate file
nnoremap <F8> :AF
" Create ifndef for header files
nnoremap <F10> :call CreateHeaderIfndef()
" Make class definition
nnoremap <F11> :call MakeClassDefinition()
" Make QT class definition
nnoremap <S-F11> :call MakeClassDefinitionQT()
" Make system c class definition
nnoremap <C-F11> :call MakeClassDefinitionSystemC()
" Git select
nnoremap ,g :call GitSelect()<CR>
" Alt+l is l
nnoremap <M-l> l
" Alt+h is h
nnoremap <M-h> h
" Git select
nnoremap <Leader>gs :call GitSelect()<CR>
" Select word under cursor
nnoremap <space> viw

"" Normal mode
" Diff both windows
nnoremap <Leader>d2 :diffthis<cr><c-w><c-w>:diffthis<cr>
" Remove diff
nnoremap <Leader>r2 :diffoff!<cr>

"" Insert mode
" Let hjkl work in insertmode with ctrl
" Move down
inoremap <C-J> <down>
" Move up
inoremap <C-K> <up>
" Move right
inoremap <C-L> <right>
" Move left
inoremap <C-H> <left>
" Move to end
inoremap <C-E> <end>
" Help = escape
inoremap <Help> <ESC>

"" Operator mode (movements in commands, e.g. d <move> or c <move> or y <move>
"" Vim wil operate on visually selected text
"" or text between previous and current position
" Inside next parentheses on current line
onoremap in( :<c-u>normal! f(vi(<cr>
" Inside last parentheses on current line
onoremap il( :<c-u>normal! F)vi(<cr>
" Around next parentheses on current line
onoremap an( :<c-u>normal! f(va(<cr>
" Around last parentheses on current line
onoremap al( :<c-u>normal! F)va(<cr>

"" Command line
" Valid names for keys are:  <Up> <Down> <Left> <Right> <Home> <End>
" <S-Left> <S-Right> <S-Up> <PageUp> <S-Down> <PageDown>  <LeftMouse>
cnoremap <C-A> <Home>
cnoremap <C-F> <Right>
cnoremap <C-B> <Left>
cnoremap <C-E> <End>
cnoremap <ESC>b <S-Left>
cnoremap <ESC>f <S-Right>
cnoremap <ESC><C-H> <C-W>

" Settings
set encoding=utf-8

" Leader
let mapleader = '\'

set backspace=2   " Backspace deletes like most programs in insert mode
set nobackup
set nowritebackup
set noswapfile    " http://robots.thoughtbot.com/post/18739402579/global-gitignore#comment-458413287
set history=50
set ruler         " show the cursor position all the time
set showcmd       " display incomplete commands
set incsearch     " do incremental searching
set laststatus=2  " Always display the status line
set autowrite     " Automatically :write before running commands
set modelines=0   " Disable modelines as a security precaution
set nomodeline
set shiftwidth=2   " Number of spaces for autoindent, << and >>
set shiftround
set expandtab   " When inserting a tab, expand it to the number of spaces
set list   " Print tabs and trailing spaces
" Strings to use for tabs and trailing spaces
set listchars=tab:»·,trail:·
set nojoinspaces   " Use one space, not two, after punctuation.
set textwidth=80   " Maximum text width, longer line will be broken after space
set colorcolumn=81   " Highlighted screen column
set nonumber   " Line numbers not displayed
" Completion mode for wildchar (tab): longest match, list all, complete next
set wildmode=longest,list,full
" Open new split panes to right and bottom, which feels more natural
set splitbelow
set splitright

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if (&t_Co > 2 || has("gui_running")) && !exists("syntax_on")
  syntax on
endif

" Load matchit.vim, but only if the user hasn't installed a newer version.
if !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &rtp) ==# ''
  runtime! macros/matchit.vim
endif

filetype plugin indent on

augroup vimrcEx
  autocmd!

  " When editing a file, always jump to the last known cursor position.
  " Don't do it for commit messages, when the position is invalid, or when
  " inside an event handler (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if &ft != 'gitcommit' && line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

  " Set syntax highlighting for specific file types
  autocmd BufRead,BufNewFile *.md set filetype=markdown
  autocmd BufRead,BufNewFile .{jscs,jshint,eslint}rc set filetype=json
  autocmd BufRead,BufNewFile
    \ aliases.local,
    \zshenv.local,zlogin.local,zlogout.local,zshrc.local,zprofile.local,
    \*/zsh/configs/*
    \ set filetype=sh
  autocmd BufRead,BufNewFile gitconfig.local set filetype=gitconfig
  autocmd BufRead,BufNewFile tmux.conf.local set filetype=tmux
  autocmd BufRead,BufNewFile vimrc.local set filetype=vim
augroup END

" When the type of shell script is /bin/sh, assume a POSIX-compatible
" shell for syntax highlighting purposes.
let g:is_posix = 1

" Use The Silver Searcher https://github.com/ggreer/the_silver_searcher
if executable('ag')
  " Use Ag over Grep
  set grepprg=ag\ --nogroup\ --nocolor

  " Use ag in fzf for listing files. Lightning fast and respects .gitignore
  let $FZF_DEFAULT_COMMAND = 'ag --literal --files-with-matches --nocolor --hidden -g ""'

  if !exists(":Ag")
    command -nargs=+ -complete=file -bar Ag silent! grep! <args>|cwindow|redraw!
    nnoremap \ :Ag<SPACE>
  endif
endif

" Tab completion
" will insert tab at beginning of line,
" will use completion if not at beginning
function! InsertTabWrapper()
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<Tab>"
    else
        return "\<C-p>"
    endif
endfunction
inoremap <Tab> <C-r>=InsertTabWrapper()<CR>
inoremap <S-Tab> <C-n>

" Get off my lawn
"nnoremap <Left> :echoe "Use h"<CR>
"nnoremap <Right> :echoe "Use l"<CR>
"nnoremap <Up> :echoe "Use k"<CR>
"nnoremap <Down> :echoe "Use j"<CR>

" Run commands that require an interactive shell
nnoremap <Leader>r :RunInInteractiveShell<Space>

" Treat <li> and <p> tags like the block tags they are
let g:html_indent_tags = 'li\|p'

" Set tags for vim-fugitive
set tags^=.git/tags

" Quicker window movement
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

" Map Ctrl + p to open fuzzy find (FZF)
nnoremap <c-p> :Files<cr>

" Set spellfile to location that is guaranteed to exist, can be symlinked to
" Dropbox or kept in Git and managed outside of thoughtbot/dotfiles using rcm.
set spellfile=$HOME/.vim-spell-en.utf-8.add

" Autocomplete with dictionary words when spell check is on
set complete+=kspell

" Always use vertical diffs
set diffopt+=vertical

" Local config
if filereadable($HOME . "/.vimrc.local")
  source ~/.vimrc.local
endif

