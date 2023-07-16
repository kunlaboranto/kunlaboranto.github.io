" for win
"set nobackup
"set nowritebackup
"set noundofile

" 환경 설정 -----------------------------------------------------------------

"GUI
if has("gui_running")
	if has("gui_win32")
       set guifont=Bitstream_Vera_Sans_Mono:h8:cHANGEUL
	"else
        set guifont=Bitstream\ Vera\ Sans\ Mono\ 9
	endif

    "set guioptions=egmrLtT
    set guioptions=aegmt
    "set stal=2
endif

"set encoding=cp949
set fileencodings=ucs-bom,euc-kr,utf-8,default,latin1
"set encoding=utf-8
"set fileencodings=ucs-bom,utf-8,euc-kr,udefault,latin1

"diff
"set diffopt+=iwhite

"set columns=160

syntax on

set tags=./tags
set tags+=../tags
set tags+=../../tags
set tags+=../../../tags
set tags+=../../../../tags
"set tags+=$HOME/.onmir/etc/tags-usr-include
"set tags+=/usr/include/tags
set nocompatible

"[주의] 치환시에 몽땅 바뀐다.
"set ic

" filetype에 따른 indentation, plugin on (간혹 off 되어 있는 경우가 있음)
filetype indent plugin on

set ts=4
set sw=4
set sts=0
set noet

"붙여 넣기시 계단현상 제거(http://demo.initech.com/?document_srl=9718)
set paste!
"set ai
"set nu

"cindent 를 끈다. ( sw 가 space만 입력한다. indent로 tab을 사용하려면 꺼야함 )
"set nocindent 
set cindent
set hlsearch

"need block mpdev (om src)
set expandtab

"folding
"vi 폴딩을 위한 설정 자세한 사용법은 아래 링크 참조(참고:vim editor - foldmethod)
"zf 생성, za 토글, zM 모두접기, zR 모두펴기
"set foldmethod=marker
"set foldcolumn=0

"additional
set laststatus=2
set ruler

" Clever Tab features -------------------------------------------------------
" function! CleverTab()
"     if strpart( getline('.'), 0, col('.')-1 ) =~ '^\s*$'
"         return "\<Tab>"
"     else
"         return "\<C-N>"
" endfunction
" inoremap <Tab> <C-R>=CleverTab()<CR>

" save and make
map <F5> :w<CR>:make<CR>
" :make 후 next/prev error로 이동
map <F6> :cn<CR>
map <F7> :cp<CR>
" 함수 선언 보기 (ctags 이용시)
map <F8> <C-]>
" 함수 선언 빠져나오기 (ctags 이용시)
map <F9> <C-T>

" c 파일의 경우 Makefile 이 없으면 gcc를 불러줌
au BufRead,BufNewFile *.c 
\ if !filereadable("Makefile") && !filereadable("makefile") |
\ set makeprg=gcc\ %\ -o\ %< |
\ endif

" cpp 파일의 경우 Makefile 이 없으면 g++를 불러줌
au BufRead,BufNewFile *.cpp
\ if !filereadable("Makefile") && !filereadable("makefile") |  
\ set makeprg=g++\ %\ -o\ %< | 
\ endif 

" java 파일의 경우 Makefile 이 없으면 javac를 불러줌
au BufRead,BufNewFile *.java 
\ if !filereadable("Makefile") && !filereadable("makefile") |  
\ set makeprg=javac\ %  |
\ endif

" 지난번 편집했던 곳으로 Jump
au BufReadPost *
\ if line("'\"") > 0 && line("'\"") <= line("$") |
\   exe "normal g`\"" |
\ endif

"source $VIMRUNTIME/colors/blue.vim
"source $VIMRUNTIME/colors/delek.vim
"source $VIMRUNTIME/colors/desert.vim


if has("gui_running")
    source $VIMRUNTIME/colors/evening.vim
else
    "source $VIMRUNTIME/colors/pablo.vim
    "if xShell
    source $VIMRUNTIME/colors/evening.vim
    "source $VIMRUNTIME/colors/shine.vim
endif
"source $VIMRUNTIME/colors/koehler.vim

map <F2> :source $VIMRUNTIME/colors/evening.vim<CR>
map <F3> :source $VIMRUNTIME/colors/pablo.vim<CR>
map <F4> :source $VIMRUNTIME/colors/shine.vim<CR>

"({{{-- add by 임(DLA) --

"vi에서 ESC키로 명령모드 들어가면 '영문'모드로 전환
"[성공] scim 에서 해제에 아래키 등록
"       kldp/node/71378
"   KeyRelease+Escape,Control+KeyRelease+bracketleft

" save and run
map <C-F5> :w<CR>:!./%<<CR>

"2개 창 종료
map <C-F10> :q!<CR>:q!<CR>
map <C-X> :q<CR>:q<CR>

">> TODO [안됨] 
"code assist
map <C-Space> <C-P>

"}}})

":if &ttymouse = "xterm"
"if exists('&ttymouse')
	":echo &ttymouse
"endif


"""""""""""" new try 
run misc/vimgdb.vim
"set asm=0
