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

## :gear: Other Features

```vim
" Delete all scratch files and buffers
:ScratchBufferClean
```
