" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

if has("unix")

    if has("gui_running")
"        colorscheme elflord
        colorscheme ir_black
        set lines=40
    endif

else " Windows GUI settings

    source $VIMRUNTIME/vimrc_example.vim
    source $VIMRUNTIME/mswin.vim
    behave mswin

    set diffexpr=MyDiff()
    function MyDiff()
      let opt = '-a --binary '
      if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
      if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
      let arg1 = v:fname_in
      if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
      let arg2 = v:fname_new
      if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
      let arg3 = v:fname_out
      if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
      let eq = ''
      if $VIMRUNTIME =~ ' '
        if &sh =~ '\<cmd'
          let cmd = '""' . $VIMRUNTIME . '\diff"'
          let eq = '"'
        else
          let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
        endif
      else
        let cmd = $VIMRUNTIME . '\diff'
      endif
      silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3 . eq
    endfunction

    " Josh's
    if has("gui_running")
        set lines=53
        set columns=85
        colorscheme ir_black
        set guifont=Courier:h10
        map ,w :winpos 735 12
        map ,W :winpos 1436 46
    endif
    set backupdir=C:\WINDOWS\Temp\vim
    set directory=C:\WINDOWS\Temp\vim

endif " has("unix")

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

"""" BELOW HERE CAN BE THE SAME IN _vimrc """"
set ruler
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set autoindent
set copyindent
set cindent
set backspace=indent,eol,start
set mouse=a
set scrolloff=8
syntax on
set hlsearch
set showmatch
set incsearch

" GUI settings
set background=dark
set showtabline=2

if has("gui_running")
    colorscheme ir_black
    runtime ftplugin/man.vim
    nmap K :Man <cword><CR>
    set lines=38
    map ,w :winpos 769 153
    if &diff
        set columns=175
    endif
endif

" mappings
map ,# :set pasteO75A#yypO#73A A#0ll:set nopasteR
map ,p :set pasteo#73A A#0ll:set nopasteR
map ,* :set pasteO/74A*o *72A A*o 73A*A/0klll:set nopasteR
map ,; :set pasteO;74A*o;*72A A*o;74A*0klll:set nopasteR
map ,c :set pasteo *72A A*0lll:set nopasteR
map ,8 :set pasteo20A-A8<20A-:set nopaste0
map ,m mz:%s///g:noh'z
map ,t :tabn
map ,T :tabp
map ,s mz:%s/\v\s+$//'z
map ,f :set ts=8:retab:set ts=4
map ,C ggVGc
" jump to tag in a new tab
map  :tab :tag 

" highlight characters past column 80
map ,L :highlight TooLong guibg=lightyellow:match TooLong '\%>80v.*.$'

" flag more than 80 characters in a row as an error
" 3match error '\%>80v.\+'

set nomousehide

if has("autocmd")
  autocmd FileType text setlocal noautoindent
"  autocmd FileType c match error /\v\s+$/
"  autocmd FileType c 2match error /\t/
"  autocmd FileType cpp 2match error /\t/
  autocmd FileType c syn match Constant display "\<_*[A-Z][A-Z0-9_]*\>"
  autocmd FileType cpp syn match Constant display "\<_*[A-Z][A-Z0-9_]*\>"
  autocmd FileType dosbatch syn match Comment "^@rem\($\|\s.*$\)"lc=4 contains=dosbatchTodo,@dosbatchNumber,dosbatchVariable,dosbatchArgument
  au BufRead,BufNewFile *.dxl set filetype=dxl
  autocmd FileType dxl set syntax=cpp
endif " has("autocmd")
