scriptencoding utf-8

if exists('g:loaded_scratch_buffer')
  finish
endif
let g:loaded_scratch_buffer = v:true

" Functions {{{

function! s:define_file_pattern_using_tmp_file_pattern() abort
  if !exists('g:scratch_buffer_tmp_file_pattern')
    throw 'g:scratch_buffer_tmp_file_pattern required'
  endif
  let g:scratch_buffer_file_pattern = get(g:, 'scratch_buffer_file_pattern', #{
    \ when_tmp_buffer: g:scratch_buffer_tmp_file_pattern,
    \ when_file_buffer: g:scratch_buffer_tmp_file_pattern,
  \ })
endfunction

function! s:define_file_pattern() abort
  let g:scratch_buffer_file_pattern = get(g:, 'scratch_buffer_file_pattern', #{})
  let g:scratch_buffer_file_pattern.when_tmp_buffer = get(
    \ g:scratch_buffer_file_pattern,
    \ 'when_tmp_buffer',
    \ '/tmp/vim-scratch-tmp-%d'
  \ )
  let g:scratch_buffer_file_pattern.when_file_buffer = get(
    \ g:scratch_buffer_file_pattern,
    \ 'when_file_buffer',
    \ '/tmp/vim-scratch-file-%d'
  \ )
endfunction

" }}}

" Denopsプラグインを使用するコマンド定義
command! -bar -nargs=* ScratchBufferOpen call denops#request('scratch_buffer', 'open', [v:true, v:false, <f-args>])
command! -bar -nargs=* ScratchBufferOpenFile call denops#request('scratch_buffer', 'open', [v:false, v:false, <f-args>])
command! -bar -nargs=* ScratchBufferOpenNext call denops#request('scratch_buffer', 'open', [v:true, v:true, <f-args>])
command! -bar -nargs=* ScratchBufferOpenFileNext call denops#request('scratch_buffer', 'open', [v:false, v:true, <f-args>])
command! -bar ScratchBufferClean call denops#request('scratch_buffer', 'clean', [])

if exists('g:scratch_buffer_tmp_file_pattern') && !exists('g:scratch_buffer_file_pattern')
  " For backward compatibility
  call s:define_file_pattern_using_tmp_file_pattern()
else
  " For the newer specs
  call s:define_file_pattern()
endif

let g:scratch_buffer_default_file_ext = get(g:, 'scratch_buffer_default_file_ext', 'md')
let g:scratch_buffer_default_open_method = get(g:, 'scratch_buffer_default_open_method', 'sp')
let g:scratch_buffer_default_buffer_size = get(g:, 'scratch_buffer_default_buffer_size', 15)
let g:scratch_buffer_auto_save_file_buffer = get(g:, 'scratch_buffer_auto_save_file_buffer', v:true)
let g:scratch_buffer_use_default_keymappings = get(g:, 'scratch_buffer_use_default_keymappings', v:true)

let g:scratch_buffer_auto_hide_buffer = get(g:, 'scratch_buffer_auto_hide_buffer', #{})
let g:scratch_buffer_auto_hide_buffer.when_tmp_buffer = get(g:scratch_buffer_auto_hide_buffer, 'when_tmp_buffer', v:false)
let g:scratch_buffer_auto_hide_buffer.when_file_buffer = get(g:scratch_buffer_auto_hide_buffer, 'when_file_buffer', v:false)

" Denopsプラグインの初期化
call denops#request('scratch_buffer', 'initialize', [])

if g:scratch_buffer_use_default_keymappings
  nnoremap <silent> <leader>b <Cmd>ScratchBufferOpen<CR>
  nnoremap <silent> <leader>B <Cmd>ScratchBufferOpenFile<CR>
  nnoremap <leader><leader>b :<C-u>ScratchBufferOpen<Space>
  nnoremap <leader><leader>B :<C-u>ScratchBufferOpenFile<Space>
endif
