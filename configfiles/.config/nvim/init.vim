set termguicolors
set tabstop=2
set shiftwidth=2
set expandtab
set smartindent
set guifont=Fira\ Code:h12

command Config e ~/.config/nvim/init.vim

" Neovide Customization "
let g:neovide_transparency=0.9
let g:neovide_fullscreen=v:false
let g:neovide_cursor_vfx_mode = "pixiedust"
let g:neovide_remember_window_size=v:true

call plug#begin(stdpath('data') . '/plugged')

" Spotify Controls "
Plug 'KadoBOT/nvim-spotify', { 'do': 'make' }

" Bottom line "
Plug 'feline-nvim/feline.nvim'

" Linting "
Plug 'dense-analysis/ale'

" Node Plugins "
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Kitty Configuration Support "
Plug 'fladson/vim-kitty'

" assuming you're using vim-plug: https://github.com/junegunn/vim-plug
Plug 'ncm2/ncm2'
Plug 'roxma/nvim-yarp'

" enable ncm2 for all buffers
autocmd BufEnter * call ncm2#enable_for_buffer()

" IMPORTANT: :help Ncm2PopupOpen for more information
set completeopt=noinsert,menuone,noselect

" NOTE: you need to install completion sources to get completions. Check
" our wiki page for a list of sources: https://github.com/ncm2/ncm2/wiki
Plug 'ncm2/ncm2-bufword'
Plug 'ncm2/ncm2-path'

"Lovely tree."
Plug 'preservim/nerdtree'

"Git"
Plug 'tpope/vim-fugitive'

"Comments"
Plug 'preservim/nerdcommenter'

"fzf <3"
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

"themes"
Plug 'morhetz/gruvbox'

"Buffers as tabs"
Plug 'ap/vim-buftabline'

call plug#end()

autocmd vimenter * ++nested colorscheme gruvbox

lua require('feline').setup()

nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv
