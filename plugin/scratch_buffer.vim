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
let g:scratch_buffer_default_file_ext = get(g:, 'scratch_buffer_default_file_ext', 'md')
let g:scratch_buffer_default_open_method = get(g:, 'scratch_buffer_default_open_method', 'sp')
let g:scratch_buffer_default_buffer_size = get(g:, 'scratch_buffer_default_buffer_size', 15)
let g:scratch_buffer_auto_save_file_buffer = get(g:, 'scratch_buffer_auto_save_file_buffer', v:true)
let g:scratch_buffer_use_default_keymappings = get(g:, 'scratch_buffer_use_default_keymappings', v:true)

let g:scratch_buffer_auto_hide_buffer = get(g:, 'scratch_buffer_auto_hide_buffer', #{})
let g:scratch_buffer_auto_hide_buffer.when_tmp_buffer = get(g:scratch_buffer_auto_hide_buffer, 'when_tmp_buffer', v:false)
let g:scratch_buffer_auto_hide_buffer.when_file_buffer = get(g:scratch_buffer_auto_hide_buffer, 'when_file_buffer', v:false)

augroup VimScratchBuffer
  autocmd!
  autocmd TextChanged * call scratch_buffer#autocmd#save_file_buffer()
  autocmd WinLeave * call scratch_buffer#autocmd#hide_buffer()
augroup END

if g:scratch_buffer_use_default_keymappings
  nnoremap <silent> <leader>b <Cmd>ScratchBufferOpen<CR>
  nnoremap <silent> <leader>B <Cmd>ScratchBufferOpenFile<CR>
  nnoremap <leader><leader>b :<C-u>ScratchBufferOpen<Space>
  nnoremap <leader><leader>B :<C-u>ScratchBufferOpenFile<Space>
endif
