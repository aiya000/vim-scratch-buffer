# :sparkles: scratch-buffer.vim :sparkles:

:rocket: **No more hassle with file paths!** The fastest way to open an instant scratch buffer.

For Vim/Neovim.

- - -

![](./readme/logo.jpg)

- - -

This Vim plugin is created by **Cline (Roo Code)** and me!

- - -

## :wrench: Quick Start

```vim
" Open a new scratch buffer without file extension and filetype
:ScratchBufferOpen
:ScratchBufferOpen --no-file-ext
```

```vim
" Open a new scratch buffer with Markdown filetype
:ScratchBufferOpen md
```

```vim
" Open a small buffer at the top for quick notes
:ScratchBufferOpen md sp 5
:ScratchBufferOpen --no-file-ext sp 5
```

Of course, you can open other file types too!

```vim
" Open a TypeScript buffer
:ScratchBufferOpen ts
```

## :fire: Why scratch-buffer.vim?

- **Open instantly!** Just run `:ScratchBufferOpen`!
- **No file management!** Perfect for quick notes and testing code snippets.
- **Works anywhere!** Whether in terminal Vim or GUI, it's always at your fingertips.

## :zap: Supercharge with vim-quickrun!

:bulb: **Combine it with [vim-quickrun](https://github.com/thinca/vim-quickrun) to execute code instantly!**

```vim
" Write TypeScript code...
:ScratchBufferOpen ts

" ...and run it immediately!
:QuickRun
```

## :balance_scale: Comparison with scratch.vim

[scratch.vim](https://github.com/mtth/scratch.vim) is a great plugin.
However, vim-scratch-buffer adds more features.

Compared to scratch.vim, vim-scratch-buffer provides these additional features:

- Open multiple buffers with sequential numbering
    - When you want to take notes on different topics, scratch.vim only allows one buffer
    - See [`:ScratchBufferOpen`](https://github.com/aiya000/vim-scratch-buffer/blob/736eef08b531b91c95497917ddb97ffbc2047c73/doc/vim-scratch-buffer.txt#L86)
- Choose between writeable buffers or temporary buffers
    - See [`:ScratchBufferOpen`](https://github.com/aiya000/vim-scratch-buffer/blob/736eef08b531b91c95497917ddb97ffbc2047c73/doc/vim-scratch-buffer.txt#L86) and [`:ScratchBufferOpenFile`](https://github.com/aiya000/vim-scratch-buffer/blob/736eef08b531b91c95497917ddb97ffbc2047c73/doc/vim-scratch-buffer.txt#L120)
- Specify filetype, opening method (`:split` or `:vsplit`), and buffer height (width)
    - Filetype specification enables syntax highlighting

## :gear: Other Features

```vim
" Delete all scratch files and buffers
:ScratchBufferClean
```

## :keyboard: Default Keymappings

By default (`g:scratch_buffer_use_default_keymappings` is enabled), the following keymappings are available:

```vim
nnoremap <silent> <leader>b <Cmd>ScratchBufferOpen<CR>
nnoremap <silent> <leader>B <Cmd>ScratchBufferOpenFile<CR>
nnoremap <leader><leader>b :<C-u>ScratchBufferOpen<Space>
nnoremap <leader><leader>B :<C-u>ScratchBufferOpenFile<Space>
```

You can disable these default keymappings by setting:

```vim
let g:scratch_buffer_use_default_keymappings = v:false
```

## :sparkles: scratch.vim Compatibility

To make the plugin behave like scratch.vim, you can enable automatic buffer hiding!
When enabled, scratch buffers will automatically hide when you leave the window.
You can configure this behavior separately for temporary buffers and file buffers.

Enable both types of buffer hiding with:

```vim
let g:scratch_buffer_auto_hide_buffer = #{
  \ when_tmp_buffer: v:true,
  \ when_file_buffer: v:true,
\ }
```

Or enable hiding for only temporary buffers:

```vim
let g:scratch_buffer_auto_hide_buffer = #{ when_tmp_buffer: v:true }
```

Or enable hiding for only file buffers:

```vim
let g:scratch_buffer_auto_hide_buffer = #{ when_file_buffer: v:true }
```
