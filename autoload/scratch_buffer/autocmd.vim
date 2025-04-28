scriptencoding utf-8
scriptversion 3

function! scratch_buffer#autocmd#save_file_buffer_if_enabled() abort
  if g:scratch_buffer_auto_save_file_buffer && (&buftype !=# 'nofile')
    silent! write
  endif
endfunction

function! scratch_buffer#autocmd#hide_buffer_if_enabled() abort
  if (&buftype ==# 'nofile') && g:scratch_buffer_auto_hide_buffer.when_tmp_buffer
    quit
    return
  endif

  if g:scratch_buffer_auto_hide_buffer.when_file_buffer
    quit
    return
  endif
endfunction
