scriptencoding utf-8
scriptversion 3

" Params:
" - (first argument) {string | undefined} (Optional)
"     - File extension without '.', e.g., 'md', 'ts', or 'sh'
"     - Or '--no-file-ext' to create a buffer without file extension
"     - If omitted, creates a buffer without file extension
" - (second argument) {'sp' | 'vsp' | undefined} (Optional) An open method. How to open the new buffer
" - (third argument) {number | undefined} (Optional) A positive number to `:resize buffer_size`
function! scratch_buffer#open(opening_next_fresh_buffer, ...) abort
  return s:open_buffer(#{
    \ opening_temporary_buffer: v:true,
    \ opening_next_fresh_buffer: a:opening_next_fresh_buffer,
    \ args: a:000,
  \ })
endfunction

function! scratch_buffer#open_file(opening_next_fresh_buffer, ...) abort
  return s:open_buffer(#{
    \ opening_temporary_buffer: v:false,
    \ opening_next_fresh_buffer: a:opening_next_fresh_buffer,
    \ args: a:000,
  \ })
endfunction

function! s:open_buffer(options) abort
  const args = a:options.args
  const opening_temporary_buffer = a:options.opening_temporary_buffer
  const opening_next_fresh_buffer = a:options.opening_next_fresh_buffer

  const file_ext = get(args, 0, g:scratch_buffer_default_file_ext)
  const file_pattern = (file_ext ==# '--no-file-ext' || file_ext ==# '')
    \ ? $'{g:scratch_buffer_tmp_file_pattern}'
    \ : $'{g:scratch_buffer_tmp_file_pattern}.{file_ext}'

  const index = s:find_current_index(file_pattern) + (opening_next_fresh_buffer ? 1 : 0)
  const file_name = expand(printf(file_pattern, index))

  const open_method = get(args, 1, g:scratch_buffer_default_open_method)
  const buffer_size = get(args, 2, g:scratch_buffer_default_buffer_size)

  execute 'silent' open_method file_name

  if opening_temporary_buffer
    setlocal buftype=nofile
    setlocal bufhidden=hide
  else
    setlocal buftype=
    setlocal bufhidden=
  endif

  if buffer_size !=# v:null
    execute (open_method ==# 'vsp' ? 'vertical' : '') 'resize' buffer_size
  endif
endfunction

function! s:find_current_index(pattern) abort
  " NOTE: `[]->max()` returns 0
  const max_buffer_index = scratch_buffer#helper#get_all_buffer_names()
    \ ->mapnew({ _, buffer_name -> s:extract_index_from_name(buffer_name, a:pattern)})
    \ ->max()
  const max_file_index = glob(substitute(a:pattern, '%d', '*', ''), v:false, v:true)
    \ ->mapnew({ _, file_name -> s:extract_index_from_name(file_name, a:pattern) })
    \ ->max()
  return [max_buffer_index, max_file_index]->max()
endfunction

function! s:extract_index_from_name(name, pattern) abort
  const getting_index_regex = substitute(a:pattern, '%d', '\\(\\d\\+\\)', '')
  const matches = matchlist(a:name, getting_index_regex)
  return len(matches) > 1 ? str2nr(matches[1]) : v:null
endfunction

function! s:find_next_index(pattern) abort
  return  + 1
endfunction

" Clean up all scratch buffers and files
function! scratch_buffer#clean() abort
  const files = glob(
    \ substitute(g:scratch_buffer_tmp_file_pattern, '%d', '*', ''),
    \ v:false,
    \ v:true,
  \ )
  for file in files
    call delete(file)
  endfor

  const scratch_prefix = '^' .. substitute(
    \ g:scratch_buffer_tmp_file_pattern,
    \ '%d',
    \ '',
    \ '',
  \ )
  const buffers = scratch_buffer#helper#get_all_buffer_names()
    \ ->filter({ _, buffer_name -> buffer_name =~# scratch_prefix })
  for buffer in buffers
    execute ':bwipe!' bufnr(buffer)
  endfor
endfunction
