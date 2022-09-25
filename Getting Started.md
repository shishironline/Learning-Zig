---
id: 0sivfgxkw3c0ikx3makx1ng
title: Getting Started
desc: ''
updated: 1664079495993
created: 1664032820444
---
# [Getting Started](https://ziglang.org/learn/getting-started/)

**Tagged release or nightly build?**

we encourage you to upgrade to a nightly build

---
**Installing Zig**

Linux:

`sudo snap install zig --classic --edge`

`zig version`

0.10.0-dev.4166+cae76d829

Windows:

`D:\Extrapath\zig.exe version`

0.10.0-dev.4166+cae76d829

download:

https://ziglang.org/builds/zig-windows-x86_64-0.10.0-dev.4166+cae76d829.zip

unzip and add to path

## Recommended tools

### Syntax Highlighters and LSP

All major text editors have syntax highlight support for Zig. Some bundle it, some others require installing a plugin.

If you’re interested in a deeper integration between Zig and your editor, checkout [zigtools/zls](https://github.com/zigtools/zls).

If you’re interested in what else is available, checkout the [Tools](https://ziglang.org/learn/getting-started//../tools/) section.

## Run Hello World

If you completed the installation process correctly, you should now be able to invoke the Zig compiler from your shell.  
Let’s test this by creating your first Zig program!

Navigate to your projects directory and run:

```bash
mkdir hello-world
cd hello-world
zig init-exe
```

This should output:

```
info: Created build.zig
info: Created src/main.zig
info: Next, try `zig build --help` or `zig build run`
```

Running `zig build run` should then compile the executable and run it, ultimately resulting in:

```
info: All your codebase are belong to us.
```

Congratulations, you have a working Zig installation!


## Install zls - Zig Language Server


### For VSCode

To install zls - Zig Language Server - first get it:

`wget https://github.com/zigtools/zls-vscode/releases/downlo
ad/1.1.2/zls-vscode-1.1.2.vsix`

In VSCdoe window, press Ctrl+Shift+P -  

select Extensions: Install from VSIX

Navigate to the download folder - 

select and and press Enter

Confirm in Extensions window

You might need to update it in VSCode

### For Neovim

### Neovim/Vim8

#### [](https://github.com/zigtools/zls#vs-code#coc)CoC

-   Install the CoC engine from [here](https://github.com/neoclide/coc.nvim).

Then choose one of the following two ways

1.  Use extension
    
    Run `:CocInstall coc-zls` to install [coc-zls](https://github.com/xiyaowong/coc-zls), this extension supports the same functionality as the VS Code extension
    
2.  Manually register
    
    ```json
    {
       "languageserver": {
           "zls" : {
               "command": "command_or_path_to_zls",
               "filetypes": ["zig"]
           }
       }
    }
    ```
    

#### [](https://github.com/zigtools/zls#vs-code#youcompleteme)YouCompleteMe

-   Install YouCompleteMeFrom [here](https://github.com/ycm-core/YouCompleteMe.git).
-   Add these lines to your vimrc:

```viml
"ensure zig is a recognized filetype
autocmd BufNewFile,BufRead *.zig set filetype=zig

let g:ycm_language_server =
  \ [
  \{
  \     'name': 'zls',
  \     'filetypes': [ 'zig' ],
  \     'cmdline': [ '/path/to/zls_executable' ]
  \    }
  \ ]
```

#### [](https://github.com/zigtools/zls#vs-code#nvim-lspconfig)nvim-lspconfig

Requires Nvim 0.5 (HEAD)!

-   Install nvim-lspconfig from [here](https://github.com/neovim/nvim-lspconfig).
-   Install zig.vim from [here](https://github.com/ziglang/zig.vim).

nvim-lspconfig already ships a configuration for zls. A simple `init.vim` might look like this:

```viml
call plug#begin('~/.config/nvim/plugged')
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-lua/completion-nvim'
Plug 'ziglang/zig.vim'
call plug#end()

:lua << EOF
    local lspconfig = require('lspconfig')

    local on_attach = function(_, bufnr)
        vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
        require('completion').on_attach()
    end

    local servers = {'zls'}
    for _, lsp in ipairs(servers) do
        lspconfig[lsp].setup {
            on_attach = on_attach,
        }
    end
EOF

" Set completeopt to have a better completion experience
set completeopt=menuone,noinsert,noselect

" Enable completions as you type
let g:completion_enable_auto_popup = 1
```

#### [](https://github.com/zigtools/zls#vs-code#languageclient-neovim)LanguageClient-neovim

-   Install the LanguageClient-neovim from [here](https://github.com/autozimu/LanguageClient-neovim)
-   Edit your neovim configuration and add `zls` for zig filetypes:

```viml
let g:LanguageClient_serverCommands = {
       \ 'zig': ['~/code/zls/zig-out/bin/zls'],
       \ }
```
---

For vim-plug users:

" Use release branch (recommend)
Plug 'neoclide/coc.nvim', {'branch': 'release'}

**vscode-zig**

git clone https://github.com/ziglang/vscode-zig.git

npm install
npm run compile
npx vsce package

This will create vsix file.

Now open VSCode and press Ctrl+Shift+P

select extensions:install from vsix file

select the path to vsix file

press enter -> extension loaded

check from extensions window

---
[kristoff-it/zig-doctest](https://github.com/kristoff-it/zig-doctest)

A tool for testing snippets of code, useful for websites and books that talk about Zig.

this tool gives you the option of testing scripts that are expected to fail. This is something that the built-in testing framework of Zig doesn't allow to do in the same way. This is particularly useful when demoing things like runtime checks in safe release modes, which will cause the executable to crash.

git clone https://github.com/kristoff-it/zig-doctest.git

cd zig-doctest

$ zig build 

Available commands: syntax, build, test, run, inline, help.

Put the `--help` flag after the command to get command-specific
help.

Examples:

 ./doctest syntax --in_file=foo.zig
 ./doctest build --obj --fail "not handled in switch"
 ./doctest test --out_file bar.zig --zig_exe="/Downloads/zig/bin/zig"

 ---
 ## Introduction

These are all introductions to Zig aimed at programmers with different backgrounds.

-   [In-depth Overview](https://ziglang.org/learn//overview/)  
    Here’s an in-depth feature overview of Zig from a systems-programming perspective.
-   [Why Zig When There is Already C++, D, and Rust?](https://ziglang.org/learn//why_zig_rust_d_cpp/)  
    An introduction to Zig for C++, D, and Rust programmers.
-   [Code Examples](https://ziglang.org/learn//samples/)  
    A list of snippets to get a feeling for how Zig code looks.
-   [Tools](https://ziglang.org/learn//tools/)  
    A list of useful tools that can help you write Zig code.

## Getting started

If you’re ready to start programming in Zig, this guide will help you setup your environment.

-   [Getting started](https://ziglang.org//ziglang.org/learn/getting-started/)

## Online learning resources

-   [Zig Learn](https://ziglearn.org)  
    A structured introduction to Zig by [Sobeston](https://github.com/sobeston).
-   [Ziglings](https://github.com/ratfactor/ziglings)  
    Learn Zig by fixing tiny broken programs.

## Relevant videos and blog posts

-   [Road to Zig 1.0](https://www.youtube.com/watch?v=Gv2I7qTux7g) \[video\]  
    Video by [Andrew Kelley](https://andrewkelley.me) introducing Zig and its philosophy.
-   [Zig’s New Relationship with LLVM](https://kristoff.it/blog/zig-new-relationship-llvm/)  
    A blog post about the work towards building the Zig self-hosted compiler, also featured in [an article by lwn.net](https://lwn.net/Articles/833400/)

