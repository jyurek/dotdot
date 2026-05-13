# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal dotfiles for macOS. Files here are intended to be symlinked (or copied) into `$HOME`. The repo lives at `~/.dot`.

## Applying Changes

After editing any bash file, reload with:
```sh
source ~/.bash_profile
# or use the alias:
rerc
```

After editing `tmux.conf`, reload with `prefix + r` (bound to `source-file ~/.tmux.conf`).

After editing `vim/vimrc`, reload with `<Leader>rc` or `:source $MYVIMRC`.

## Bash Architecture

`bash/rc` is the entry point (sourced from `~/.bash_profile` or `~/.bashrc`). It sets environment variables, aliases, and then sources every `*.bash` file in `~/.bash/` automatically via a glob loop.

Each `*.bash` file is a standalone concern:
- `color.bash` — `color_text <text> <ansi-code>` and `rgb_text <hex> <text>` helpers used by `prompt.bash`
- `prompt.bash` — builds `PS1` with exit code, elapsed time, cwd (abbreviated), git branch + dirty marker, via `PROMPT_COMMAND`
- `asdf.bash` — configures asdf shims (`ASDF_DATA_DIR=/opt/bin/asdf`)
- `chruby.bash` — loads chruby from Homebrew, activates Ruby from `~/.ruby-version`; rubies live at `/opt/rubies`
- `fzf.bash` — fzf keybindings; uses `fd` for path completion; completion trigger is `\`
- `elixir.bash` — enables IEx/Erlang shell history via `ERL_AFLAGS`

Tool versions are tracked in `.tool-versions` (asdf format).

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
