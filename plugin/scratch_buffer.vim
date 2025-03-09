scriptencoding utf-8

if exists('g:loaded_scratch_buffer')
  finish
endif
let g:loaded_scratch_buffer = v:true

" Example:
" `:ScratchBufferOpen`
" `:ScratchBufferOpen --no-file-ext`
" `:ScratchBufferOpen sh`
" `:ScratchBufferOpen ts vsp`
" `:ScratchBufferOpen md sp 5`
command! -bar -nargs=* ScratchBufferOpen call scratch_buffer#open(<f-args>)

" Example:
" `:ScratchBufferOpenFile md`
" `:ScratchBufferOpenFile ts vsp`
command! -bar -nargs=* ScratchBufferOpenFile call scratch_buffer#open_file(<f-args>)

command! -bar ScratchBufferClean call scratch_buffer#clean()

let g:scratch_buffer_tmp_file_pattern = get(g:, 'scratch_buffer_tmp_file_pattern', '/tmp/vim-scratch-buffer-%d')
let g:scratch_buffer_auto_save_file_buffer = get(g:, 'scratch_buffer_auto_save_file_buffer', v:true)
let g:scratch_buffer_auto_hide_buffer = get(g:, 'scratch_buffer_auto_hide_buffer', v:false)
let g:scratch_buffer_use_default_keymappings = get(g:, 'scratch_buffer_use_default_keymappings', v:false)

function! s:is_scratch_bufer() abort
  return expand('%:p') =~# substitute(g:scratch_buffer_tmp_file_pattern, '%d', '*', '')
endfunction

augroup VimScratchBuffer
  autocmd!

  autocmd TextChanged *
    \ if g:scratch_buffer_auto_save_file_buffer && (&buftype !=# 'nofile') && s:is_scratch_bufer()
      \| silent! write
    \| endif

  autocmd WinLeave *
    \ if g:scratch_buffer_auto_hide_buffer && s:is_scratch_bufer()
      \| quit
    \| endif
augroup END

if g:scratch_buffer_use_default_keymappings
  nnoremap <silent> <leader>b :ScratchBufferOpen<CR>
  nnoremap <silent> <leader>B :ScratchBufferOpenFile<CR>
endif
