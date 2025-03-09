scriptencoding utf-8
scriptversion 3

function! s:is_scratch_buffer() abort
  return expand('%:p') =~# substitute(g:scratch_buffer_tmp_file_pattern, '%d', '*', '')
endfunction

function! scratch_buffer#autocmd#save_file_buffer() abort
  if g:scratch_buffer_auto_save_file_buffer && (&buftype !=# 'nofile') && s:is_scratch_buffer()
    silent! write
  endif
endfunction

function! scratch_buffer#autocmd#hide_buffer() abort
  if !s:is_scratch_buffer()
    return
  endif

  if (&buftype ==# 'nofile') && g:scratch_buffer_auto_hide_buffer.when_tmp_buffer
    quit
    return
  endif

  if g:scratch_buffer_auto_hide_buffer.when_file_buffer
    quit
    return
  endif
endfunction
