" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

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

  set autoindent        " always set autoindenting on

endif " has("autocmd")

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
syntax on
set hlsearch
set showmatch
set incsearch
set tags=./tags;/
let Tlist_WinWidth = 40
set grepprg=internal

" GUI settings
set background=dark
set showtabline=2
set nomousehide

if has("gui_running")
    colorscheme ir_black
    runtime ftplugin/man.vim
    nmap K :Man <cword><CR>
    set lines=50
    map ,w :winpos 769 153
    set scrolloff=8
    if &diff
        set columns=175
    endif
else
    set scrolloff=4
endif

if has("win32") || has("win64")
    set directory=$TMP
end

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
"map  :tab :tag 
"nnoremap <silent> <F8> :TlistToggle<CR>
" re-indent the following line how vim would automatically do it
map ,j Ji
map  :cn
map  :cp

" highlight characters past column 80
map ,L :highlight TooLong guibg=lightyellow:match TooLong '\%>80v.*.$'

" flag more than 80 characters in a row as an error
" 3match error '\%>80v.\+'

if has("autocmd")
  autocmd FileType text setlocal noautoindent
"  autocmd FileType c match error /\v\s+$/
"  autocmd FileType c 2match error /\t/
"  autocmd FileType cpp 2match error /\t/
  autocmd FileType c syn match Constant display "\<[A-Z_][A-Z_0-9]*\>"
  autocmd FileType cpp syn match Constant display "\<[A-Z_][A-Z_0-9]*\>"
  autocmd FileType dosbatch syn match Comment "^@rem\($\|\s.*$\)"lc=4 contains=dosbatchTodo,@dosbatchNumber,dosbatchVariable,dosbatchArgument
  au BufRead,BufNewFile *.dxl set filetype=dxl
  autocmd FileType dxl set syntax=cpp
  " open all buffers in a new tab
"  au BufAdd,BufNewFile * nested tab sball
" install glsl.vim in ~/.vim/syntax to use syntax highlighting for GLSL:
  au BufNewFile,BufWinEnter *.frag,*.vert,*.fp,*.vp,*.glsl setf glsl
  autocmd Syntax {cpp,c,idl} runtime syntax/doxygen.vim
  autocmd QuickFixCmdPre grep copen
  autocmd QuickFixCmdPre vimgrep copen
endif " has("autocmd")
