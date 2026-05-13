# Dotfiles Evaluation — Portability & Improvement Findings

*Evaluated 2026-05-13 across four perspectives: Vim expert, ZSH expert, fresh eyes, and Claude workflow.*

---

## Vim Expert Findings

### Plugin Ecosystem & Management

Your vim-plug setup is solid and remains a great choice for 2026. However, there are a few considerations:

- **vim-plug vs. alternatives**: vim-plug is lightweight and well-maintained. Lua-based managers (packer, lazy.nvim) shine for Neovim-only setups, but since you're maintaining both vim/ and config/nvim/, vim-plug's language-agnostic approach is the right call. No change needed.
- **One critical portability issue** (vimrc line 4): `Plug '/usr/local/opt/fzf'` is a hardcoded macOS Homebrew path. This will break on Linux or if someone installs fzf differently. Consider using `Plug 'junegunn/fzf'` instead and managing fzf via Homebrew/package manager separately, or use a conditional:
  ```vim
  if filereadable('/usr/local/opt/fzf')
    Plug '/usr/local/opt/fzf'
  endif
  ```

### Redundant & Overlapping Plugins

Several plugins duplicate or conflict with Vim 8+/Neovim builtins:

1. **vim-argumentative** — Modern Vim has native text objects. Check if you use this enough to justify it.
2. **vim-markdown** — Lightweight but dated (last update 2017?). Modern Neovim uses treesitter-based highlighting.
3. **vim-extradite** — Git history browser that overlaps with fugitive's newer `:Git log` features. Keep extradite (F11 binding is fast), but you could simplify.

### Language Server & Completion Setup

**Potential conflict detected** (vimrc lines 272–275 vs. coc.vim lines 33–37):

Both try to map `<Tab>` for completion. The coc.vim bindings will override the vimrc ones (coc.nvim plugin loads after vimrc). This is fine — coc's completion is what you want — but remove the vimrc `<Tab>` mapping to avoid confusion.

**coc-settings.json portability issue**: Your custom language servers (elixirLS at `/opt/bin/elixir-ls`, kotlin-language-server at `/opt/homebrew/bin/`) are hardcoded absolute paths that are Mac-specific. Document these in a README if you want portability.

### Neovim Transition (Incomplete)

You have both `vim/vimrc` and `config/nvim/init.vim`, and they're identical — a sign of a mid-transition. Pick a direction:

1. **Vim-only for now**: Delete `config/nvim/init.vim`, keep `vim/vimrc`.
2. **Neovim-first**: Move vimrc logic to `config/nvim/init.vim`, source it from `vim/vimrc` as a fallback.
3. **Full Neovim migration**: Migrate to Lua (`config/nvim/init.lua`), use lazy.nvim for better plugin management, and drop vim-plug. Neovim 0.10+ has native snippet support, better LSP, and treesitter integration.

The deleted files (vim/.vim, vim/init.vim, vim/plugin/ale.vim, vim/plugin/elm.vim) suggest you recently cleaned up. Good — rationalizing the plugin list is the right call.

### Workflow & Mapping Observations

**Strengths**:
- Leader-space is excellent (`let mapleader=" "`). Space as leader is modern and ergonomic.
- Custom test integration (vim-test + tbro) is clever for rapid iteration.
- Debug snippet mappings (`<Leader>dr` for pry, `<Leader>de` for Elixir Logger) are Elixir/Rails-specific power moves.

**Watch out**:
- `nnoremap z= i<C-x>s` — Smart vim idiom for spelling suggestions inline. Most users don't know about this — worth documenting.

### Missing from Modern Setup

1. **No statusline plugin** — coc status is commented out in coc.vim. Consider a lightweight statusline if you want coc diagnostics at the bottom.
2. **No snippet plugin** — coc has snippet support baked in, but no explicit snippet engine. If you use snippets heavily (Rails, HTML templates), consider coc-snippets.

### Portability Summary — Vim

**Current blockers for Linux/other systems**:
- FZF path hardcoded in vimrc line 4
- coc-settings.json hardcoded language server paths
- No fallback for missing tools (ag, ruby-lsp, crystalline, etc.)

**Quick wins**:
1. Add guards around system-specific settings using `executable()` checks
2. Document assumed tool versions in a README

---

## ZSH Expert Findings

### Executive Summary

Your bash setup is mature and well-structured. Converting to ZSH would modernize your shell with stronger globbing, built-in completions, superior history, and plugin ecosystems — while preserving 90% of your existing configuration.

### Framework Choice: Starship, Not Oh My Zsh

**Why not Oh My Zsh:**
- Bloated (200+ plugins, slow startup)
- Opinionated (overrides your carefully-built setup)
- You already have modular files; Oh My Zsh adds cruft

**Why Starship:**
- Installed once via Homebrew, runs everywhere (Bash, Fish, Nushell too)
- Drop-in replacement for your `prompt.bash` (1–2 minutes to configure)
- Native Rust implementation: fast, minimal overhead
- Auto-detects Node, Elixir, Ruby, Git — no custom parsing needed
- Single `starship.toml` config file — replaces 63 lines of custom prompt code

**Migration path:** Replace just `prompt.bash` — everything else moves as-is.

### File-by-File Conversion Breakdown

| File | Effort | Notes |
|------|--------|-------|
| `rc` | 30 min | Fix BREW path, remove bash_completion; rest copies verbatim |
| `prompt.bash` | Delete | Replace with `~/.config/starship.toml` |
| `color.bash` / `hex2rgb.bash` | Rename | 100% ZSH-compatible as-is |
| `fzf.bash` | 10 min | Update Homebrew path detection |
| `asdf.bash` | 10 min | Fix non-standard `/opt/bin/asdf` path |
| `chruby.bash` | 10 min | Detect path dynamically |
| `completions.bash` | 20 min | Full rewrite (bash `complete` doesn't exist in ZSH) |
| `tmux.bash` | 5 min | Rewrite for `compctl` |
| All others | Rename | `ruby.bash`, `elixir.bash`, `docker.bash`, `android.bash`, `heroku.bash` all copy verbatim |

**Key change for `bash/rc` line 26:**
```bash
# OLD (breaks on Intel Mac and Linux):
export BREW=/opt/homebrew/bin/brew

# NEW:
BREW=$(command -v brew)
BREW_HOME=$("$BREW" --prefix)
export PATH=./bin:$BREW_HOME/bin:$BREW_HOME/sbin:$PATH:$HOME/bin
```

**VI keybindings:** Change `set -o vi` → `bindkey -v` (trivial).

### Portability Issues Found in Current Bash Setup

#### High Priority (Will break on other systems)

1. **`/opt/homebrew` hardcoded** (`bash/rc`, line 26–27) — Apple Silicon only; Intel Macs use `/usr/local`
2. **`/opt/rubies` hardcoded** (`bash/chruby.bash`) — assumes custom install
3. **`/opt/bin/asdf` hardcoded** (`bash/asdf.bash`) — non-standard; asdf defaults to `~/.asdf`
4. **`/Applications/Docker.app` hardcoded** (`bash/docker.bash`) — macOS only
5. **`$HOME/Library/Android/sdk` hardcoded** (`bash/android.bash`) — macOS only
6. **`reattach-to-user-namespace` in `tmux.conf`** — macOS-only tool; add conditional on `uname -s`

#### Medium Priority

7. **Bash-specific completion syntax** (`completions.bash`, `tmux.bash`) — `COMP_WORDS`, `complete -F` don't exist in ZSH
8. **`ag` assumed installed** in `prompt.bash` — not universal

### Gains from ZSH

- **Starship:** Faster prompt, no maintenance, cross-shell
- **Extended globbing:** `**/*.js` works natively (bash needs `shopt -s globstar`)
- **Shared history:** All terminals share history in real-time (bash only does this on exit)
- **Menu completion:** Arrow keys to navigate completions
- **`zsh-autosuggestions` / `zsh-syntax-highlighting`:** Lightweight opt-in plugins

### Migration Roadmap (Estimated 1.5 Hours Total)

| Phase | Tasks | Time |
|-------|-------|------|
| 1: Scaffolding | Install ZSH, create `~/.zshrc`, create `~/.zsh/` | 30 min |
| 2: Core | Migrate `rc`, rename 8 simple files, install Starship | 30 min |
| 3: Advanced | Migrate fzf, completions, verify paths | 20 min |
| 4: Testing | Validate in `zsh` before `chsh` | 30 min |

**Conservative approach:** Set up ZSH alongside bash. Test thoroughly before switching. If problems arise, `bash` still works.

---

## Fresh Eyes Findings

### 1. Duplicate Bash Configuration Files

There are **two parallel hierarchies** of bash configuration:
- **Active**: `bash/*.bash` files (17 files at top level)
- **Stale**: `bash/.bash/*.bash` files (9 files — appears to be older copies from initial commit)

`bash/rc` sources from `~/.bash/*.bash`, not from `bash/.bash/`, so the subdirectory is **never sourced at runtime**. It's dead weight that would confuse anyone reading the repo.

**Action**: Delete `/Users/jyurek/.dot/bash/.bash/` entirely.

### 2. Install Script Bug

`.bin/install` produces symlink commands using `installdir='~'`:
```bash
echo "ln -sf '$file' '~/.bash'"
```
The shell **doesn't expand `~` in single quotes**, so running this output verbatim would fail or create incorrect paths. The script is also piped to `echo` (prints commands) rather than executing them.

**Action**: Fix the script to expand `~` properly, or clearly document usage (`bash .bin/install | bash`). CLAUDE.md doesn't mention this script at all.

### 3. Missing Bootstrap Documentation

CLAUDE.md documents the architecture but **doesn't explain how to set up on a new machine**:
- No mention of `.bin/install`
- No step-by-step bootstrap sequence
- No note about which tools must be pre-installed (asdf, Homebrew, etc.)
- No mention that `:PlugInstall` must be run in vim after clone

**Action**: Add a "Setup / Bootstrap" section to CLAUDE.md.

### 4. `viminfo` Should Not Be Committed

`vim/viminfo` is committed to git and symlinked from `~/.viminfo`. This is a runtime artifact containing user history, marks, and registers — it changes every vim session and doesn't belong in version control.

**Action**: Add `viminfo` to `.gitignore` and remove it from tracking: `git rm --cached vim/viminfo`.

### 5. Unused / Dead Files

| File | Status |
|------|--------|
| `bash/1.bash` | Empty file (0 bytes) — delete |
| `bash/hex2rgb.bash` | 138-line script never called anywhere — delete |
| `bash/dot.bash` | References a `dot` tool that doesn't appear to exist |
| `bash/alden.bash` | Client-specific AWS profile config — shouldn't be in shared dotfiles |

### 6. Two Conflicting `.tool-versions` Files

There's both `.tool-versions` (crystal, elixir 1.16.0, erlang 26.2.1, nodejs 20.10.0) and `tool-versions` (elixir 1.18.4-otp-26). The home directory symlink points to one; the other is orphaned.

**Action**: Consolidate to one authoritative file and delete the other.

### 7. Neovim Config Double-Indirection

`config/nvim/` contains symlinks pointing back to `~/.vim` and `~/.vimrc`. This creates confusing double-indirection: anyone looking at `~/.config/nvim/` would expect a real neovim config, not symlinks to elsewhere.

**Action**: Either use a proper neovim config in `config/nvim/`, or remove `config/nvim/` entirely (vim/neovim both work with the existing `~/.vim` / `~/.vimrc` symlinks).

### 8. Hardcoded Client-Specific Configs

`bash/android.bash` and `bash/alden.bash` contain machine/client-specific paths and AWS profiles. These are hardcoded and meaningless on a fresh machine or for anyone else who clones the repo.

**Action**: Move to `.local` files that are `.gitignore`d, or remove from the repo entirely.

### 9. `.gitignore` Gaps

`config/` contains app-generated directories (configstore, filezilla, devcert, gatsby, shopify) with some potentially sensitive data (filezilla credentials). The gitignore doesn't explicitly block these.

**Better approach**:
```
config/*
!config/git/
!config/kitty/
!config/nvim/
```

### 10. Mysterious `~/.dot-git` Directory

There's a `~/.dot-git` directory (15 items, last modified Dec 19 2024) that's not referenced anywhere. Purpose unclear.

**Action**: Document it if it serves a purpose (e.g., bare git repo), or delete it if stale.

---

## Claude Expert Findings

### 1. CLAUDE.md Structure & Quality

Your CLAUDE.md is **solid and well-organized**, covering repo overview, bash architecture, vim setup, and key tools. However, it's missing critical Claude Code guidance:

- **No validation steps**: Claude doesn't know that modifying `prompt.bash` requires understanding `color.bash`, or that `PROMPT_COMMAND` is the integration point
- **No Claude Code workflow section**: When should Claude use `/implement:adr`? When should it use worktrees? Not documented.
- **No troubleshooting**: What to do if `source ~/.bash_profile` fails.

**Suggested addition to CLAUDE.md**:
```markdown
## Claude Code Integration

When modifying bash files:
1. Always suggest running `rerc` after changes
2. Changes to prompt.bash, color.bash, or tool-detection files (asdf.bash, chruby.bash)
   must be validated interactively
3. Test isolated changes in a new shell session before committing

When adding new bash functionality:
- Follow the standalone-file pattern in existing *.bash files
- Add documentation to CLAUDE.md

File interdependencies:
- color.bash is loaded before prompt.bash (glob order)
- rc sources all *.bash via glob — new files are auto-included
```

### 2. Hooks Are Unconfigured

`claude/settings.json` has `skipAutoPermissionPrompt: true` and `effortLevel: "xhigh"` but **no `hooks` section**. This is a significant missed opportunity. Your setup has natural hook points:

- Editing any `bash/*.bash` file → should trigger `source ~/.bash_profile` to validate
- Editing `tmux.conf` → should trigger `tmux source-file ~/.tmux.conf`

**Recommended hooks to add to `claude/settings.json`**:
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "if [[ \"$CLAUDE_TOOL_INPUT_FILE_PATH\" == *bash/*.bash ]]; then bash -c 'source ~/.bash_profile && echo \"✓ bash reloaded\"' 2>&1; fi"
          }
        ]
      }
    ]
  }
}
```

### 3. Dotfiles Repo Structure vs. AI-Assisted Development

**Well-done**:
- Clear directory layout with single entry point (`bash/rc` → glob-sources all `*.bash`)
- Symlink-friendly architecture
- `.tool-versions` gives Claude version context
- `.gitignore` correctly excludes `vim/plugged/*`

**Improvements for Claude**:
- **Document the symlink map explicitly**: Add to CLAUDE.md — "Edit `.dot/bash/rc` (symlinked to `~/.bash_profile`). The home directory symlinks are in `.bin/install`."
- **No CONTRIBUTING.md**: No commit message conventions, testing expectations, or backwards-compatibility guidance for Claude to follow.

### 4. Underutilized Skills for Dotfiles Work

Your enabled plugins include `implement@gnar`, `ideate@gnar`, `ignite@gnar`, and `superpowers` — powerful tools that could enhance dotfiles maintenance:

- **`/implement:adr`**: Document decisions like "why vim-plug over pathogen", "why chruby alongside asdf"
- **`/superpowers:verification-before-completion`**: Run before merging bash changes to ensure `rerc` works and no syntax errors
- **`/ideate:prd`**: For larger refactors (e.g., ZSH migration, Neovim transition) — generate a plan before touching code

### 5. Specific Low-Hanging Wins

1. **Create `.claude/tasks/dotfiles/`** — lets Claude track maintenance tasks (e.g., "update vim plugins quarterly")
2. **Add a `vim/CONTRIBUTING.md`** — document that coc.nvim requires a specific Node.js version (hint: check `.tool-versions`)
3. **Create a `bash/rc.local` pattern** — `.gitignore`d file for machine-specific overrides (AWS profiles, client paths), preventing client-specific configs from polluting the shared repo
4. **Run `/fewer-permission-prompts`** — scan transcripts and add an allowlist to `settings.json` for common dotfiles operations (read-only, `source`, `rerc`, etc.)

### 6. Missing Permission Allowlist

`settings.json` has `skipAutoPermissionPrompt: true` but no explicit allowlist for safe dotfiles operations. Add:

```json
{
  "permissions": {
    "allow": [
      "Bash(bash --version:*)",
      "Bash(find ~/.dot*:*)",
      "Bash(grep*~/.dot*:*)",
      "Bash(vim --version:*)"
    ]
  }
}
```

---

## Priority Matrix

| Priority | Finding | Section | Action |
|----------|---------|---------|--------|
| HIGH | `bash/.bash/` duplicate hierarchy | Fresh Eyes | Delete directory |
| HIGH | `bash/rc` hardcodes `/opt/homebrew` | ZSH | Detect dynamically |
| HIGH | Install script doesn't expand `~` | Fresh Eyes | Fix or document |
| HIGH | Missing bootstrap docs in CLAUDE.md | Fresh Eyes | Add "Setup" section |
| HIGH | FZF hardcoded in vimrc line 4 | Vim | Use `Plug 'junegunn/fzf'` |
| MEDIUM | Hooks unconfigured in settings.json | Claude | Add PostToolUse hooks |
| MEDIUM | `viminfo` committed to git | Fresh Eyes | gitignore + `git rm --cached` |
| MEDIUM | Incomplete Neovim transition | Vim | Pick a direction |
| MEDIUM | `completions.bash` / `tmux.bash` bash-specific | ZSH | Rewrite for ZSH |
| MEDIUM | Dead files: `bash/1.bash`, `bash/hex2rgb.bash` | Fresh Eyes | Delete |
| MEDIUM | Client-specific configs in shared dotfiles | Fresh Eyes | Move to `.local` |
| LOW | Two `.tool-versions` files | Fresh Eyes | Consolidate |
| LOW | coc-settings.json hardcoded LS paths | Vim | Document in README |
| LOW | `config/nvim/` double-indirection | Fresh Eyes | Simplify or remove |
| LOW | CLAUDE.md missing Claude Code guidance | Claude | Add workflow section |
| LOW | ZSH migration | ZSH | ~1.5 hours, high payoff |
