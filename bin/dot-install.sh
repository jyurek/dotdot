#!/usr/bin/env bash
set -euo pipefail

DOT="${HOME}/.dot"
BACKUP_DIR="${HOME}/.dot-backup-$(date +%Y%m%d%H%M%S)"
backed_up=0

link() {
  local src="$1"   # path inside .dot
  local dst="$2"   # destination in $HOME

  local target="${DOT}/${src}"

  if [ -L "$dst" ]; then
    if [ "$(readlink "$dst")" = "$target" ]; then
      echo "  skip  $dst (already linked)"
      return
    fi
    # Wrong symlink — replace it
    rm "$dst"
  elif [ -e "$dst" ]; then
    # Real file or directory — back it up
    mkdir -p "$BACKUP_DIR"
    mv "$dst" "${BACKUP_DIR}/$(basename "$dst")"
    backed_up=1
    echo "backup  $dst -> ${BACKUP_DIR}/$(basename "$dst")"
  fi

  ln -sf "$target" "$dst"
  echo "  link  $dst -> $target"
}

if [ ! -d "$DOT" ]; then
  echo "error: $DOT not found — clone the repo there first"
  exit 1
fi

echo "Installing dotfiles from $DOT"
echo

link bash              "${HOME}/.bash"
link bash/rc           "${HOME}/.bash_profile"
link bash/rc           "${HOME}/.bashrc"
link bash/logout       "${HOME}/.bash_logout"
link claude            "${HOME}/.claude"
link claude.json       "${HOME}/.claude.json"
link config            "${HOME}/.config"
link inputrc           "${HOME}/.inputrc"
link tmux.conf         "${HOME}/.tmux.conf"
link tool-versions     "${HOME}/.tool-versions"
link vim               "${HOME}/.vim"
link vim/vimrc         "${HOME}/.vimrc"

echo
if [ "$backed_up" -eq 1 ]; then
  echo "Originals backed up to $BACKUP_DIR"
fi
echo "Done."
