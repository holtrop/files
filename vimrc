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
set tabpagemax=999

" GUI settings
set background=dark
set showtabline=2
set nomousehide

if has("gui_running")
    colorscheme ir_black
    runtime ftplugin/man.vim
    nmap K :Man <cword><CR>
    set lines=50
    set scrolloff=8
    if &diff
        set columns=175
    endif
else
    set scrolloff=4
endif

if has("win32") || has("win64")
    set directory=$TMP
endif

" mappings
map ,# :set pasteO75A#yypO#73A A#0ll:set nopasteR
map ,p :set pasteo#73A A#0ll:set nopasteR
map ,* :set pasteO/74A*o 73A*A/O * :set nopasteA
map ,; :set pasteO;74A*o;*72A A*o;74A*0klll:set nopasteR
map ,8 :set pasteo20A-A8<20A-:set nopaste0
map ,m mz:%s///g:noh'z
map ,t :tabn
map ,T :tabp
map ,s mz:%s/\v\s+$//'z
map ,f :set ts=8:retab:set ts=4
map ,C ggVGc
" jump to tag in a new tab
map ,w :tab :tag 
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
  autocmd FileType html setlocal sw=2 ts=2 sts=2
  autocmd FileType xhtml setlocal sw=2 ts=2 sts=2
  autocmd FileType xml setlocal sw=2 ts=2 sts=2
  autocmd FileType ruby setlocal sw=2 ts=2 sts=2
endif " has("autocmd")

if !exists('s:loaded')
    let s:loaded = 0
endif

if s:loaded
    delfunction Bwmatch
    delcommand Bwmatch
endif

function Bwmatch(exp)
    let last = bufnr('$')
    let index = 0
    while index <= last
        if bufexists(index) && bufname(index) =~ a:exp
            execute ':bw ' . index
        endif
        let index += 1
    endwhile
    redraw!
endfunction

command -nargs=1 Bwmatch :call Bwmatch('<args>')

let s:loaded = 1
