set tabstop=2
set shiftwidth=2
set expandtab
set number relativenumber
set ruler
set tags=./tags
set autoindent
set showcmd
" don't enable smartindent, it does weird stuff with gq if there's the word
" 'for' in the line
set clipboard+=unnamedplus
" make macros snappy
set lazyredraw

" disable text wrapping and automatic commenting
autocmd FileType * setlocal formatoptions-=t formatoptions-=c formatoptions-=r formatoptions-=o

" allow window moving with ctrl + arrows
" but only in normal mode
" don't use alt because
nnoremap <C-Left> <C-W>h
nnoremap <C-Right> <C-W>l
nnoremap <C-Down> <C-W>j
nnoremap <C-Up> <C-W>k
nnoremap <C-h> <C-W>h
nnoremap <C-l> <C-W>l
nnoremap <C-j> <C-W>j
nnoremap <C-k> <C-W>k

" disable search highlighting with ctrl-/
nnoremap <C-/> :noh<CR>

" map - and _ to insert lines like o and O without leaving normal mode
nnoremap - o<Esc>
nnoremap _ O<Esc>

" treat buffers like firefox tabs
nnoremap <C-Tab> :bn<CR>
nnoremap <C-S-Tab> :bp<CR>

" Intellij has this cool keyboard shortcut ctrl + enter that sends everything
" at and after the cursor to the next line
nnoremap <C-CR> i<CR><Esc>k:s/\s$//e<CR>:noh<CR>$

" when editing a file where root permission is necessary
command DoasW w !doas tee % > /dev/null

" plugin time
call plug#begin()

Plug 'scrooloose/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'vim-syntastic/syntastic'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-commentary'
Plug 'machakann/vim-sandwich'
Plug 'adelarsq/vim-matchit'
Plug 'bkad/CamelCaseMotion'
Plug 'wellle/targets.vim'
Plug 'easymotion/vim-easymotion'
Plug 'michaeljsmith/vim-indent-object'
Plug 'cocopon/iceberg.vim'
Plug 'ryanoasis/vim-devicons'
Plug 'ludovicchabant/vim-gutentags'
Plug 'gentoo/gentoo-syntax'

call plug#end()

" nerdtree
" \t to open/close NERDTree
" \f to focus on the NERDTree
" remap v to vertical split to match ctrlp
nmap <silent> <leader>t :NERDTreeToggle<CR>
nmap <silent> <leader>f :NERDTreeFocus<CR>
let g:NERDTreeMapOpenVSplit='v'
let g:NERDTreeAutoDeleteBuffer = 1
let g:NERDTreeDirArrowExpandable = ''
let g:NERDTreeDirArrowCollapsible = ''

" Syntastic settings
" \s to check syntax
" \r to reset
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_cpp_check_header = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_mode_map = {"mode": "passive"}
let g:syntastic_cpp_config_file = '.syntastic-cpp-includes'
nmap <leader>s :SyntasticCheck<CR>
nmap <leader>r :SyntasticReset<CR>

" airblade/vim-gitgutter settings
" required after having changed the colorscheme
hi clear SignColumn

" camelcasemotion
let g:camelcasemotion_key = '<leader>'

" iceberg stuff
colorscheme iceberg

" airline
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif
let g:airline_theme = 'iceberg'
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.maxlinenr = '並'
let g:airline_symbols.whitespace = '聾'

" targets
" include {} as open/close for argument
autocmd User targets#mappings#user call targets#mappings#extend({
      \ 'a': {'argument': [{'o': '[([{]', 'c': '[])}]', 's': ','}]},
      \ })
