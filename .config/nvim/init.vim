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

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
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
Plug 'gentoo/gentoo-syntax'
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'ms-jpq/coq_nvim', {'branch': 'coq'} " may need to run COQdeps when updating
Plug 'ms-jpq/coq.artifacts', {'branch': 'artifacts'}
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'ms-jpq/chadtree', {'branch': 'chad', 'do': 'python3 -m chadtree deps'} " may need to run CHADdeps when updating
Plug 'NMAC427/guess-indent.nvim'

call plug#end()

" chadtree
" \t to open/close CHADTree
" \f to focus CHADTree
" remap x to horizontal split and v to vertical split to match ctrlp
" remap cut(move) from x to m because of conflict also beacuse it make more sense
nmap <silent> <leader>t :CHADopen<CR>
nmap <silent> <leader>f :CHADopen --always-focus<CR>
let g:chadtree_settings = { 'keymap': {'v_split': ['v'], 'h_split': ['x'], 'cut': ['m'] }}

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
let g:airline#extensions#whitespace#mixed_indent_algo = 2 " allow spaces after tabs for aligning

" targets
" include {} as open/close for argument
autocmd User targets#mappings#user call targets#mappings#extend({
      \ 'a': {'argument': [{'o': '[([{]', 'c': '[])}]', 's': ','}]},
      \ })

" mason/lspconfig/coq/treesitter
" IMPORTANT: set up mason first, then lspconfig
lua << EOF
  require("mason").setup()
  require("mason-lspconfig").setup()
  require("nvim-treesitter.configs").setup {
    highlight = {
      enable = true,

      -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
      -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
      -- Using this option may slow down your editor, and you may see some duplicate highlights.
      -- Instead of true it can also be a list of languages
      additional_vim_regex_highlighting = {"markdown", "make"},
    },
    indent = {
      enable = false, -- this doesn't work quite right, maybe enable it a later time
    }
  }

  vim.g.coq_settings = {
    ["display.pum.fast_close"] = false, -- to reduce flickering or something
    keymap = {
      jump_to_mark = "", -- default of c-h conflicts with split switching
    },
  }

  -- Use an on_attach function to only map the following keys
  -- after the language server attaches to the current buffer
  local on_attach = function(client, bufnr)
    -- Mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local bufopts = { noremap=true, silent=true, buffer=bufnr }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', 'gh', vim.lsp.buf.hover, bufopts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
    -- vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
    -- vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
    -- vim.keymap.set('n', '<space>wl', function()
    --   print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    -- end, bufopts)
    -- vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
    vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, bufopts)

    -- only run coq for code
    -- this also speeds up startup time
    vim.api.nvim_command('COQnow')
  end

  -- :h mason-lspconfig-automatic-server-setup
  require("mason-lspconfig").setup_handlers {
    -- The first entry (without a key) will be the default handler
    -- and will be called for each installed server that doesn't have
    -- a dedicated handler.
    function (server_name) -- default handler (optional)
      require("lspconfig")[server_name].setup (require("coq").lsp_ensure_capabilities({
        on_attach = on_attach
      }))
    end,
    -- Next, you can provide a dedicated handler for specific servers.
    -- For example, a handler override for the `rust_analyzer`:
    -- ["rust_analyzer"] = function ()
    --   require("rust-tools").setup {}
    -- end
  }

  require('guess-indent').setup {}
EOF

