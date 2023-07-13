colorscheme murphy
hi Folded term=standout ctermbg=LightGrey ctermfg=DarkBlue guibg=LightGrey guifg=DarkBlue
hi FoldColumn term=standout ctermbg=LightGrey ctermfg=DarkBlue guibg=Grey guifg=DarkBlue
highlight MatchParen guibg=darkgreen
highlight Pmenu guibg=darkgreen
highlight PmenuSel guibg=blue
highlight ColorColumn ctermbg=235 guibg=#2c2d27
set guifont=Cousine\ Regular\ 12
set guioptions-=T
set guioptions-=m
set guioptions-=L
set vb t_vb=
set mouse=a
set mousefocus
function! ToggleWindowSize()
  let l:numwindows = len(getwininfo())
  if &columns == 80
    set columns=161
    if l:numwindows == 1
      vsplit
    endif
  elseif &columns == 161
    set columns=242
    if l:numwindows == 2
      vsplit
    endif
  else
    set columns=80
  endif
endfunc
nmap <F12> :call ToggleWindowSize()<CR>
nmap <Help> :make
imap <C-H> <left>
map! <s-insert> <C-O>:set paste<CR><C-R>*<C-O>:set nopaste<CR>
nmap <S-F1> :tabp<CR>
nmap <S-F2> :tabn<CR>
nmap <S-F3> :tablast<CR>
if filereadable($HOME . "/.gvimrc.local")
  source ~/.gvimrc.local
endif
