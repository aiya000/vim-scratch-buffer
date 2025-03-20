const s:suite = themis#suite('scratch_buffer')
const s:expect = themis#helper('expect')
const s:assert = themis#helper('assert')

function! s:suite.before() abort
  " Backup default values
  let g:backup_scratch_buffer_default_file_ext = g:scratch_buffer_default_file_ext
  let g:backup_scratch_buffer_default_open_method = g:scratch_buffer_default_open_method
  let g:backup_scratch_buffer_default_buffer_size = g:scratch_buffer_default_buffer_size
  let g:backup_scratch_buffer_auto_save_file_buffer = g:scratch_buffer_auto_save_file_buffer
  let g:backup_scratch_buffer_use_default_keymappings = g:scratch_buffer_use_default_keymappings
  let g:backup_scratch_buffer_auto_hide_buffer = g:scratch_buffer_auto_hide_buffer
endfunction

function! s:suite.before_each() abort
  " Don't waste our environment
  let g:scratch_buffer_tmp_file_pattern = system('realpath "./test/tmp/scratch-%d"')[:-2]
  " Restore default values
  let g:scratch_buffer_default_file_ext = g:backup_scratch_buffer_default_file_ext
  let g:scratch_buffer_default_open_method = g:backup_scratch_buffer_default_open_method
  let g:scratch_buffer_default_buffer_size = g:backup_scratch_buffer_default_buffer_size
  let g:scratch_buffer_auto_save_file_buffer = g:backup_scratch_buffer_auto_save_file_buffer
  let g:scratch_buffer_use_default_keymappings=g:backup_scratch_buffer_use_default_keymappings
  let g:scratch_buffer_auto_hide_buffer = g:backup_scratch_buffer_auto_hide_buffer

  " Clean all created scratch files and buffers
  ScratchBufferClean
endfunction

function! s:suite.after_each() abort
  " Clean all created files
  for file in glob(g:scratch_buffer_tmp_file_pattern[:-3] .. '*', v:false, v:true)
    call system($'rm "{file}"')
  endfor
endfunction

function! s:suite.scratch_buffer_open_shoud_can_make_buffer() abort
  ScratchBufferOpen
  const file_name = expand('%:p')
  const expected = printf(g:scratch_buffer_tmp_file_pattern, 0) .. '.md'
  call s:expect(file_name).to_equal(expected)
endfunction

function! s:suite.scratch_buffer_open_next_can_make_multiple_buffer() abort
  ScratchBufferOpen
  const main_file = expand('%:p')
  ScratchBufferOpenNext
  const next_file = expand('%:p')
  call s:expect(main_file).not.to_equal(next_file)
endfunction

function! s:suite.scratch_buffer_open_should_open_recent_buffer_after_scratch_buffer_open_next() abort
  ScratchBufferOpenNext
  const first_file = expand('%:p')

  " Move to a different window
  new

  ScratchBufferOpen
  const second_file = expand('%:p')

  call s:expect(second_file).to_equal(first_file)
endfunction

function! s:is_scratch_buffer_open_buffer_writable() abort
  let is_written = v:false
  try
    ScratchBufferOpen
    write
    let is_written = v:true
  catch
  endtry
  return is_written
endfunction

function! s:suite.scratch_buffer_open_should_open_readonly_file() abort
  call s:expect(s:is_scratch_buffer_open_buffer_writable()).to_equal(v:false)
endfunction

function! s:is_scratch_buffer_open_file_buffer_writable() abort
  let is_written = v:false
  try
    ScratchBufferOpenFile
    write
    let is_written = v:true
  catch
  endtry
  return is_written
endfunction

function! s:suite.scratch_buffer_open_file_should_open_writable_file() abort
  call s:expect(s:is_scratch_buffer_open_file_buffer_writable()).to_equal(v:true)
endfunction

function! s:suite.scratch_buffer_open_file_should_make_tmp_buffer_to_file_buffer() abort
  const is_tmp_buffer_writable = s:is_scratch_buffer_open_buffer_writable()
  const first_file = expand('%:p')
  call s:expect(is_tmp_buffer_writable).to_equal(v:false)

  const is_file_buffer_writable = s:is_scratch_buffer_open_file_buffer_writable()
  const second_file = expand('%:p')
  call s:expect(is_file_buffer_writable).to_equal(v:true)

  call s:expect(first_file).to_equal(second_file)
endfunction

function! s:suite.scratch_buffer_open_should_make_file_buffer_to_tmp_buffer() abort
  const is_file_buffer_writable = s:is_scratch_buffer_open_file_buffer_writable()
  const first_file = expand('%:p')
  call s:expect(is_file_buffer_writable).to_equal(v:true)

  const is_tmp_buffer_writable = s:is_scratch_buffer_open_buffer_writable()
  const second_file = expand('%:p')
  call s:expect(is_tmp_buffer_writable).to_equal(v:false)

  call s:expect(first_file).to_equal(second_file)
endfunction

function! s:suite.scratch_buffer_clean_should_wipe_opened_files_and_buffers() abort
  ScratchBufferOpenFile md
  const first_file = expand('%:p')
  write
  ScratchBufferOpen md
  const second_file = expand('%:p')

  " Check the created files stil exist
  const all_buffer_names = scratch_buffer#helper#get_all_buffer_names()
  call s:expect(filereadable(first_file)).to_equal(1)
  call s:expect(
    \ all_buffer_names->scratch_buffer#helper#contains(first_file),
  \ ).not.to_equal(-1)
  call s:expect(
   \ all_buffer_names->scratch_buffer#helper#contains(second_file),
  \ ).not.to_equal(-1)

  " Wipe all scratch buffers and files
  ScratchBufferClean

  " Check the created files are removed
  const new_all_buffer_names = scratch_buffer#helper#get_all_buffer_names()
  call s:expect(filereadable(first_file)).not.to_equal(1)
  call s:expect(
    \ new_all_buffer_names->scratch_buffer#helper#contains(first_file),
  \ ).not.to_equal(-1)
  call s:expect(
    \ new_all_buffer_names->scratch_buffer#helper#contains(second_file),
  \ ).not.to_equal(-1)
endfunction

function! s:suite.scratch_buffer_should_accept_file_extension() abort
  ScratchBufferOpen md
endfunction

function! s:suite.scratch_buffer_should_accept_open_method() abort
  ScratchBufferOpen md sp
  ScratchBufferOpen md vsp
endfunction

function! s:suite.scratch_buffer_should_accept_buffer_size() abort
  ScratchBufferOpen md sp 5
  ScratchBufferOpen md vsp 50
endfunction

function! s:suite.scratch_buffer_should_use_default_values() abort
  let g:scratch_buffer_default_file_ext = 'ts'
  let g:scratch_buffer_default_open_method = 'vsp'
  let g:scratch_buffer_default_buffer_size = 20

  " Open another window to resize a scratch buffer
  new
  " Open buffer without arguments
  ScratchBufferOpen

  const file_name = expand('%:p')
  const expected = printf(g:scratch_buffer_tmp_file_pattern, 0) .. '.ts'
  call s:expect(file_name).to_equal(expected)
  call s:expect(winwidth(0)).to_be_same(20)
endfunction

function! s:suite.scratch_buffer_should_support_auto_saving_file_buffer() abort
  let g:scratch_buffer_auto_save_file_buffer = v:true
  ScratchBufferOpenFile md
  call setline(1, 'test content')
  doautocmd TextChanged

  const file_name = expand('%:p')
  call s:expect(filereadable(file_name)).to_equal(1)
  call s:expect(readfile(file_name)[0]).to_equal('test content')
endfunction

function! s:suite.scratch_buffer_should_support_auto_hiding_buffer() abort
  let g:scratch_buffer_auto_hide_buffer = {}

  " Temporary buffer auto-hiding
  let g:scratch_buffer_auto_hide_buffer.when_tmp_buffer = v:true
  let g:scratch_buffer_auto_hide_buffer.when_file_buffer = v:false
  only
  ScratchBufferOpen md
  wincmd p  " Trigger WinLeave
  call s:expect(winnr('$')).to_be_same(1)

  " File buffer auto-hiding
  let g:scratch_buffer_auto_hide_buffer.when_tmp_buffer = v:false
  let g:scratch_buffer_auto_hide_buffer.when_file_buffer = v:true
  only
  ScratchBufferOpenFile md
  wincmd p  " Trigger WinLeave
  call s:expect(winnr('$')).to_be_same(1)
endfunction
