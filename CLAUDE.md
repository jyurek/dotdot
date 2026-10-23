# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal dotfiles for macOS. Files here are intended to be symlinked (or copied) into `$HOME`. The repo lives at `~/.dot`.

## Layout

- `bash/` — shell config (linked to `~/.bash`); `bash/bash_profile` is the entry point
- `bin/` — scripts: `dot-install.sh` (symlinks everything into `$HOME`, backing up existing files), `tm` (tmux session create/switch), `rotate` (keep last N lines of a file)
- `claude/` — Claude Code `settings.json` (deny list for destructive git commands) and plugin manifests; everything else is gitignored
- `claude.json` — `~/.claude.json`
- `config/` — linked to `~/.config`: `kitty`, `nvim` (`init.lua`, uses `vim.pack` and `ty` LSP, then sources `~/.vimrc`), `gh`, `git/ignore`, `op`, `shopify`, `uv`, `fish`, `cmux`, plus app state dumps (coc, filezilla, gatsby, configstore, cagent, yarn)
- `vim/` — linked to `~/.vim` (vimrc, gvimrc, coc, plugin/, spell files)
- `gitconfig`, `inputrc`, `profile`, `tmux.conf`, `tool-versions`, `ruby-version` — top-level dotfiles
- `.gitignore` excludes `vim/plugged/*`, `node_modules`, viminfo, and most of `claude/`

Note: `bin/dot-install.sh` links `bash/rc` to `~/.bash_profile`/`~/.bashrc`, but `bash/rc` no longer exists; the entry point is now `bash/bash_profile`. `gitconfig`, `profile`, and `ruby-version` are not linked by the installer.

## Applying Changes

After editing any bash file, reload with:
```sh
source ~/.bash_profile
# or use the alias (currently sources ~/.bashrc):
rerc
```

After editing `tmux.conf`, reload with `prefix + r` (bound to `source-file ~/.tmux.conf`).

After editing `vim/vimrc`, reload with `<Leader>rc` or `:source $MYVIMRC`.

## Bash Architecture

`bash/bash_profile` returns early when non-interactive, sets `PATH`, `EDITOR` (nvim), `CDPATH` (`.:~:~/Development`), `DEV_HOME`, aliases (`be`, `g`, `rerc`, `uvr`...), `set -o vi`, starts ssh-agent if needed, loads bash-completion, then sources every `*.bash` file in `~/.bash/` via a glob loop (alphabetical, so `00.bash` and `01_color.bash` load first).

Each `*.bash` file is a standalone concern:
- `00.bash` — empty placeholder
- `01_color.bash` — `color_text <text> <ansi-code>` and `rgb_text <hex> <text>` helpers used by `prompt.bash`
- `hex2rgb.bash` — `hex2rgb` helper
- `prompt.bash` — builds `PS1` with exit code, elapsed time, cwd (abbreviated), git branch + dirty marker, via `PROMPT_COMMAND`
- `cd.bash` — overrides `cd` to activate/deactivate a `.venv` found in parent directories
- `python.bash` — uv env and aliases (`uvr`, `uvm`)
- `git.bash` — `MAIN_WORK_BRANCH=develop`
- `fzf.bash` — fzf keybindings; uses `fd` for path completion; completion trigger is `\`
- `completion.bash` / `completions.bash` — Homebrew bash-completion and custom completions (running processes, etc.)
- `tmux.bash` — tmux session tab completion
- `nvm.bash` — loads nvm from Homebrew
- `docker.bash`, `android.bash` — PATH additions
- `ollie.bash` — `OLLIEMAIN_ROOT` for the work repo
- `dot.bash` — currently only `ghistory`/`gemcd` helpers
- `anthropic.bash`, `aws.bash`, `asdf.bash`, `chruby.bash`, `ruby-build.bash` — empty or fully commented out (asdf/chruby are disabled); `ruby.bash` sets Ruby GC env vars
- `bash_profile` is the entry point; `logout` is `~/.bash_logout`

Tool versions are tracked in `tool-versions` (asdf format: crystal, elixir, erlang, nodejs); `ruby-version` is `4`.

## Vim Setup

Plugin manager: **vim-plug** (`~/.vim/plugged`). Install/update plugins with `:PlugInstall` / `:PlugUpdate`.

LSP: **coc.nvim** with settings in `vim/coc-settings.json`. Language server config in `vim/plugin/languages.vim`.

Testing: **vim-test** using **tbro** as the send strategy (sends commands to a tmux pane). Key mappings:
- `<Leader>t` — test nearest
- `<Leader>T` — test file
- `<Leader>a` — test suite
- `<Leader>l` — re-run last test

Colorscheme: **gruvbox** (dark).

Notable mappings:
- `K` — grep project for word under cursor (uses `ag` if available)
- `<Leader>fg` — grep for Elixir HTML function component under cursor
- `<Leader>u` — UndotreeToggle
- `!` — send command to tbro pane
- `<Leader>x` — convert decimal integers to hex in current line

Auto-formatting: Prettier runs on save for JS/TS/JSX/TSX/JSON files.

## tmux

Prefix: `C-a`. VI copy mode. Mouse enabled. Uses `reattach-to-user-namespace` for pbcopy/pbpaste integration. Smart pane switching integrates with vim-tmux-navigator.

## Key Tools & Paths

- Homebrew: `/opt/homebrew`
- Terminal: kitty (`config/kitty/kitty.conf`) with Dank Mono font, gruvbox colors
- Search: `ag` (The Silver Searcher) — aliased as `grep` in vim; `fd` for fzf
- `CDPATH` includes `~/Development` for quick directory jumping
