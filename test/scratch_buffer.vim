const s:suite = themis#suite('scratch_buffer')
const s:expect = themis#helper('expect')

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

function! s:suite.after() abort
  call themis#log('')
  " Clean all created files
  for file in glob(g:scratch_buffer_tmp_file_pattern[:-3] .. '*')->split("\n")
    call themis#log($'Removing file: {file}')
    call system($'rm "{file}"')
  endfor
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

function! s:suite.uses_default_values() abort
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

function! s:suite.auto_saves_file_buffer() abort
  let g:scratch_buffer_auto_save_file_buffer = v:true

  " Create a file buffer
  ScratchBufferOpenFile md

  " Add some content
  call setline(1, 'test content')

  " Trigger TextChanged event
  doautocmd TextChanged

  " Check if file was saved
  const file_name = expand('%:p')
  call s:expect(filereadable(file_name)).to_equal(1)
  call s:expect(readfile(file_name)[0]).to_equal('test content')
endfunction

function! s:suite.auto_hide_buffer_behavior() abort
  " Test temporary buffer auto-hiding
  let g:scratch_buffer_auto_hide_buffer = #{
    \ when_tmp_buffer: v:true,
    \ when_file_buffer: v:false,
  \ }
  only
  ScratchBufferOpen md
  wincmd p  " Trigger WinLeave
  call s:expect(winnr('$')).to_be_same(1)

  " Test file buffer auto-hiding
  let g:scratch_buffer_auto_hide_buffer.when_tmp_buffer = v:false
  let g:scratch_buffer_auto_hide_buffer.when_file_buffer = v:true
  only
  ScratchBufferOpenFile md
  wincmd p " Trigger WinLeave
  call s:expect(winnr('$')).to_be_same(1)
endfunction
