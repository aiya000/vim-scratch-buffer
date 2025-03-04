const s:suite = themis#suite('scratch_buffer')
const s:expect = themis#helper('expect')

function! s:suite.before() abort
  let g:scratch_buffer_tmp_file_pattern = '/tmp/scratch-%d'
endfunction

function! s:suite.before_each() abort
  " Clean all created scratch files and buffers
  ScratchBufferClean
endfunction

function! s:suite.can_make_buffer() abort
  ScratchBufferOpen md

  const current_file_name = expand('%:p')
  const expected = printf(g:scratch_buffer_tmp_file_pattern, 0) .. '.md'
  call s:expect(current_file_name).to_equal(expected)
endfunction

function! s:suite.can_make_multiple_buffer() abort
  ScratchBufferOpen md
  ScratchBufferOpen md
  ScratchBufferOpen md

  const current_file_name = expand('%:p')
  const expected = printf(g:scratch_buffer_tmp_file_pattern, 2) .. '.md'
  call s:expect(current_file_name).to_equal(expected)
endfunction

function! s:suite.accept_open_method() abort
  ScratchBufferOpen md sp
  ScratchBufferOpen md vsp
endfunction

function! s:suite.accept_buffer_size() abort
  ScratchBufferOpen md sp 5
  ScratchBufferOpen md vsp 50
endfunction

function! s:suite.wipes_opened_files_and_buffer() abort
  ScratchBufferOpenFile md
  write
  ScratchBufferOpen md

  const all_buffer_names = scratch_buffer#helper#get_all_buffer_names()

  const first_file = printf(g:scratch_buffer_tmp_file_pattern, 0) .. '.md'
  call s:expect(filereadable(first_file)).to_equal(1)
  call s:expect(
    \ all_buffer_names->scratch_buffer#helper#contains(first_file),
  \ ).not.to_equal(-1)

  const second_file = printf(g:scratch_buffer_tmp_file_pattern, 1) .. '.md'
  call s:expect(filereadable(second_file)).not.to_equal(1)
  call s:expect(
   \ all_buffer_names->scratch_buffer#helper#contains(second_file),
  \ ).not.to_equal(-1)

  " Wipe all scratch buffers and files
  ScratchBufferClean
  const new_all_buffer_names = scratch_buffer#helper#get_all_buffer_names()

  call s:expect(filereadable(first_file)).not.to_equal(1)
  call s:expect(
    \ new_all_buffer_names->scratch_buffer#helper#contains(first_file),
  \ ).not.to_equal(-1)

  call s:expect(
    \ new_all_buffer_names->scratch_buffer#helper#contains(second_file),
  \ ).not.to_equal(-1)
endfunction
