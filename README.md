# Ouroboros

A Neovim plugin that makes switching between header & implementation files in `C/C++` quick and painless.

## Requirements

This should work with any version of Neovim that `plenary` currently supports.

## Installation

Using [vim-plug](https://github.com/junegunn/vim-plug)

```viml
Plug 'nvim-lua/plenary.nvim' " required dependency
Plug 'jakemason/ouroboros'
```

Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'jakemason/ouroboros',
  requires = { {'nvim-lua/plenary.nvim'} }
}
```

## Usage

Bind the command `:Ouroboros` as needed, or bind it as desired:

```viml
" Example binding
noremap <leader>sw :Ouroboros<CR>
```

*NOTE:* This command _does nothing_ unless used in a file ending in `.cpp`,`.hpp`,`.c` or `.h`.
Invoking Ouroboros in a file with a different extension will do nothing.

After the `Ouroboros` command is invoked, your working directory will be recursively searched until
a file matching the _same name_ with the _counterpart_ extension is discovered. Note that the
search also respects your `.gitignore` if one exists and any file ignored in `git` will be ignored
in the results. As such, I suggest working from the root of your project. Once that file is found,
it will automatically be opened in the current buffer. If no corresponding file is found, a message
will be logged to the messages buffer -- use `:messages` to review your recent messages.

## Assumptions

`Ouroboros` will only find a corresponding file if it has the same name and the counterpart
extension. If multiple files with the same name and counterpart extension are found, the first
result is opened. Conceivably in the future I'd like to present a window if more than one possible
match is found and allow the user to pick from the list.

## Debugging

Put `let g:ouroboros_debug = 1` into your `init.vim` file to enable additional logging that will
detail what Ouroboros is doing when running.

### Why? There's several other options that do this!

None of the alternatives worked well for me. I'd been using
[coc-clangd](https://github.com/clangd/coc-clangd) most recently and wasn't pleased with the results
that calling `:CocCommand clangd.switchSourceHeader` would return. Often the switch was noticeably
delayed (an entire _second or more_) _or_ I could switch from a header file to the implementation,
but if I called `switchSourceHeader` again it would not switch back to the header. This was
increasingly common if the folder structure of the project was several layers deep.

I'd also tried [CurtineIncSw.vim](https://github.com/ericcurtin/CurtineIncSw.vim) and had similar
problems: failure to find corresponding files in larger projects, slow performance, etc.


