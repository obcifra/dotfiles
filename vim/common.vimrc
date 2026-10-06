" General Settings {{{
let $VIMHOME=expand('<sfile>:p:h')

" Use vim, not vi API
set nocompatible

" Disable use of swap and backup files
set nobackup nowritebackup noswapfile

" Show command history
set history=150

" Show incomplete commands
set showcmd

" Prevent quitting vim with hidden buffers (unfocused with unsaved changes)
set hidden

" Disable splash screen
set shortmess+=I

" }}}

" ---- Editor {{{
" UTF encoding
set encoding=utf-8

" Enable syntax highlighting
syntax on

" Disable wordwrap
set nowrap

" Show cursor
set ruler

" Show line numbers
set number

" Use system clipboard
set clipboard+=unnamed

" Highlight current line
set cursorline

" Highlight a matching [{()}] when cursor is placed on start/end character
set showmatch

" Always highlight column 80
autocmd BufWinEnter * highlight ColorColumn ctermbg=234
set colorcolumn=80

" Get rid of command delays
set timeout timeoutlen=1000 ttimeoutlen=100

" Visual autocomplete for command menu (e.g. :e ~/path/to/file)
set wildmenu
" }}}

" ---- Folding {{{
" Use indentation to guide folding
set foldmethod=indent

" Folding is disabled in new buffers by default
set nofoldenable
"  }}}

" ---- Search {{{
" Search while typing
set incsearch

" Search highlit matches
set hlsearch

" Search ignore case
set smartcase
set ignorecase

" Use ripgrep, if installed
if executable('rg')
  set grepprg=rg\ --vimgrep\ --smart-case\ --hidden
  "set grepformat=%f:%l:%c:%m
endif
" }}}

" ---- Tabs and Spacing {{{
" Convert tabs to spaces
set expandtab

" Set tab size for manual indenting
set tabstop=2

" Set tab size for auto indenting
set shiftwidth=2

" Permit backspace to delete whitespace characters
set backspace=indent,eol,start

" Highlight trailing whitespace
set list listchars=tab:\ \ ,trail:·
" }}}

" ---- Status Bar {{{
" Show status bar
set laststatus=2

" Set the status bar text
" set statusline=%f\ %=L:%l/%L\ %c\ (%p%%)

" Hide the toolbar
set guioptions-=T

" }}}

" ---- Buffers and Windows {{{

" Autoload files that have changed outside of vim
set autoread

" Better splits (new windows appear below and to the right)
set splitbelow
set splitright

" redraw only when we need to (i.e. don't redraw when executing a macro)
set lazyredraw
" }}}

" Language Key Mappings {{{
set keymap=russian-yawerty
set iminsert=0
set imsearch=-1

" Subscript Digraphs: <ctrl-k> [alpha]s
execute "digraphs as " . 0x2090
execute "digraphs es " . 0x2091
execute "digraphs hs " . 0x2095
execute "digraphs is " . 0x1D62
execute "digraphs js " . 0x2C7C
execute "digraphs ks " . 0x2096
execute "digraphs ls " . 0x2097
execute "digraphs ms " . 0x2098
execute "digraphs ns " . 0x2099
execute "digraphs os " . 0x2092
execute "digraphs ps " . 0x209A
execute "digraphs rs " . 0x1D63
execute "digraphs ss " . 0x209B
execute "digraphs ts " . 0x209C
execute "digraphs us " . 0x1D64
execute "digraphs vs " . 0x1D65
execute "digraphs xs " . 0x2093

" Superscript Digraphs: <ctrl-k> [alpha]S
execute "digraphs aS " . 0x1d43
execute "digraphs bS " . 0x1d47
execute "digraphs cS " . 0x1d9c
execute "digraphs dS " . 0x1d48
execute "digraphs eS " . 0x1d49
execute "digraphs fS " . 0x1da0
execute "digraphs gS " . 0x1d4d
execute "digraphs hS " . 0x02b0
execute "digraphs iS " . 0x2071
execute "digraphs jS " . 0x02b2
execute "digraphs kS " . 0x1d4f
execute "digraphs lS " . 0x02e1
execute "digraphs mS " . 0x1d50
execute "digraphs nS " . 0x207f
execute "digraphs oS " . 0x1d52
execute "digraphs pS " . 0x1d56
execute "digraphs rS " . 0x02b3
execute "digraphs sS " . 0x02e2
execute "digraphs tS " . 0x1d57
execute "digraphs uS " . 0x1d58
execute "digraphs vS " . 0x1d5b
execute "digraphs wS " . 0x02b7
execute "digraphs xS " . 0x02e3
execute "digraphs yS " . 0x02b8
execute "digraphs zS " . 0x1dbb
" }}}

" File-Specific Settings {{{
filetype plugin indent on

" git
autocmd Filetype gitcommit setlocal spell textwidth=72

" markdown
autocmd Bufread,BufNewFile *.md set filetype=markdown
autocmd Filetype markdown setlocal wrap linebreak nolist textwidth=0 wrapmargin=0

" yaml
autocmd FileType yaml setlocal shiftwidth=2 tabstop=2 expandtab

" shell
autocmd Bufread,BufNewFile *.bats set filetype=sh
autocmd FileType sh,zsh,vim,bats setlocal shiftwidth=2 tabstop=2 expandtab

" vim
autocmd FileType vim setlocal shiftwidth=2 tabstop=2 expandtab foldmethod=marker foldenable
" }}}

" Plugin Manager {{{
" ==============
" Set runtimepath for unconventional installs
exe 'set rtp+='.expand($VIMHOME.'/.vim')

" Returns true, if a plugin is available
function! PluginAvailable(plugin)
  return isdirectory(expand($VIMHOME.'/.vim/bundle/'.a:plugin))
endfunction

" Returns true, if a plugin is available and nvim is installed
function! NvimPluginAvailable(plugin)
  return isdirectory(expand($VIMHOME.'/.vim/bundle/'.a:plugin)) && has('nvim')
endfunction

" To install, execute :PlugInstall
" To clean, execute :PlugClean
call plug#begin(expand($VIMHOME.'/.vim/bundle'))

" File System Navigation
Plug 'preservim/nerdtree'

" Text/Code Navigation
Plug 'ctrlpvim/ctrlp.vim'
Plug 'preservim/tagbar'

" Writing
Plug 'preservim/vim-pencil'
Plug 'preservim/vim-wordy'

" GitHub Copilot for Vim and Neovim and Conquerer of Completion (CoC)
" Requires Neovim or vim 9.x
if has('nvim-0.8') || has('patch-9.0.0')
  if executable('node')
    Plug 'github/copilot.vim'
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
  endif
endif

" GitHub Copilot Chat for Neovim
if has('nvim-0.8')
  if executable('node')
    Plug 'nvim-lua/plenary.nvim'
    Plug 'CopilotC-Nvim/CopilotChat.nvim'
  endif
endif

" Look and Feel
Plug 'flazz/vim-colorschemes'
Plug 'itchyny/lightline.vim'

" Special File Types
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'
Plug 'gyim/vim-boxdraw'
Plug 'rust-lang/rust.vim'
Plug 'kaarmu/typst.vim'

" Version Control
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'

call plug#end()
" }}}

" ---- GitHub Copilot Chat plugin {{{
if NvimPluginAvailable('CopilotChat.nvim')
lua << EOF
require("CopilotChat").setup {
  debug = false,
  show_help = true,
}
EOF
endif
" }}}

" ---- colorscheme plugins {{{
if PluginAvailable('vim-colorschemes') && PluginAvailable('lightline.vim')
  set t_Co=256
  set background=dark
  colorscheme jellybeans
  let g:lightline = {'colorscheme': 'jellybeans',}
endif
" }}}

" ---- ctrl-p plugin {{{
if PluginAvailable('ctrlp.vim')
  map <leader><leader> <C-p>
  map <leader>b :CtrlPBuffer<cr>
  map <leader>t :CtrlPTag<cr>
  let g:ctrlp_show_hidden=1
  let g:ctrlp_working_path_mode=0
  let g:ctrlp_max_height=30

  " CtrlP -> override <C-o> to provide options for how to open files
  let g:ctrlp_arg_map = 1

  set wildignore+=*/.git/*,*/.hg/*,*/.svn/*.,*/.DS_Store

  " CtrlP -> directories to ignore when fuzzy finding
  let g:ctrlp_custom_ignore = '\v[\/]((node_modules)|\.(git|svn|grunt|sass-cache))$'
endif
" }}}

" ---- gitgutter plugin {{{
if PluginAvailable('vim-gitgutter')
  let g:gitgutter_enabled = 1
  let g:gitgutter_eager = 0

  if exists('&signcolumn')  " Vim 7.4.2201
    set signcolumn=yes
  else
    let g:gitgutter_sign_column_always = 1
  endif
  highlight clear SignColumn
endif
" }}}

" ---- nerdtree plugin {{{
if PluginAvailable('nerdtree')
  map <leader>[ :NERDTreeToggle<cr>
  let NERDTreeShowHidden=1
  let NERDTreeMinimalUI=1
endif
" }}}

" ---- tagbar plugin {{{
if PluginAvailable('tagbar')
  map <Leader>] :TagbarToggle<CR>
endif
" }}}

" ---- tabularize plugin {{{
if PluginAvailable('tabular')
  map <Leader>e :Tabularize /=<cr>
  map <Leader>c :Tabularize /:<cr>
  map <Leader>es :Tabularize /=\zs<cr>
  map <Leader>cs :Tabularize /:\zs<cr>
endif
" }}}

" Mappings {{{
" Notes...
"
" :map     j gg (j will be mapped to gg)
" :map     Q j  (Q will also be mapped to gg, because j will be expanded -> recursive mapping)
" :noremap W j  (W will be mapped to j not to gg, because j will not be expanded -> non recursive)
"
" These mappings work in all modes. To have mappings work in only specific
" modes then denote the mapping with the mode character.
"
" e.g.
" to map something in just NORMAL mode use :nmap or :nnoremap
" to map something in just VISUAL mode use :vmap or :vnoremap

" Alternate escape
inoremap jk <esc>
inoremap kj <esc>

" Clear search buffer
:nnoremap § :nohlsearch<cr>

" Command to use sudo when needed
cmap w!! %!sudo tee > /dev/null %

" File System Explorer (in horizontal split)
map <leader>. :Sexplore<cr>

" Buffers
map <leader>yt :ls<cr>

" Buffers (runs the delete buffer command on all open buffers)
map <leader>yd :bufdo bd<cr>

" Make handling vertical/linear Vim windows easier
map <leader>w- <C-W>- " decrement height
map <leader>w+ <C-W>+ " increment height
map <leader>w] <C-W>_ " maximize height
map <leader>w[ <C-W>= " equalize all windows

" Handling horizontal Vim windows doesn't appear to be possible.
" Attempting to map <C-W> < and > didn't work
" Same with mapping <C-W>|

" Make splitting Vim windows easier
map <leader>; <C-W>s
map <leader>` <C-W>v

" Tmux style window selection
map <Leader>ws :ChooseWin<cr>
" }}}

" Commands {{{
" jump to last cursor
autocmd BufReadPost *
  \ if line("'\"") > 0 && line("'\"") <= line("$") |
  \   exe "normal g`\"" |
  \ endif

fun! StripTrailingWhitespace()
  " don't strip on these filetypes
  if &ft =~ 'markdown'
    return
  endif
  %s/\s\+$//e
endfun
autocmd BufWritePre * call StripTrailingWhitespace()

" Rainbow parenthesis always on!
if exists(':RainbowParenthesesToggle')
  autocmd VimEnter * RainbowParenthesesToggle
  autocmd Syntax * RainbowParenthesesLoadRound
  autocmd Syntax * RainbowParenthesesLoadSquare
  autocmd Syntax * RainbowParenthesesLoadBraces
endif

" Reset spelling colours when reading a new buffer
" This works around an issue where the colorscheme is changed by .local.vimrc
fun! SetSpellingColors()
  highlight SpellBad cterm=bold ctermfg=white ctermbg=red
  highlight SpellCap cterm=bold ctermfg=red ctermbg=white
endfun
autocmd BufWinEnter * call SetSpellingColors()
autocmd BufNewFile * call SetSpellingColors()
autocmd BufRead * call SetSpellingColors()
autocmd InsertEnter * call SetSpellingColors()
autocmd InsertLeave * call SetSpellingColors()

" Change colourscheme when diffing
fun! SetDiffColors()
  highlight DiffAdd    cterm=bold ctermfg=white ctermbg=DarkGreen
  highlight DiffDelete cterm=bold ctermfg=white ctermbg=DarkGrey
  highlight DiffChange cterm=bold ctermfg=white ctermbg=DarkBlue
  highlight DiffText   cterm=bold ctermfg=white ctermbg=DarkRed
endfun
autocmd FilterWritePre * call SetDiffColors()
" }}}

" External {{{
set exrc
set secure
" }}}
