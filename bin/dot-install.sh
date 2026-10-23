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
link bash/bash_profile "${HOME}/.bash_profile"
link bash/profile      "${HOME}/.profile"
link bash/logout       "${HOME}/.bash_logout"
link claude            "${HOME}/.claude"
link config            "${HOME}/.config"
link inputrc           "${HOME}/.inputrc"
link gitconfig         "${HOME}/.gitconfig"
link tmux.conf         "${HOME}/.tmux.conf"
link tool-versions     "${HOME}/.tool-versions"
link ruby-version      "${HOME}/.ruby-version"
link vim               "${HOME}/.vim"
link vim/vimrc         "${HOME}/.vimrc"
mkdir -p "${HOME}/bin"
shopt -s nullglob
for file in "${DOT}"/bin/*; do
  f=`basename "${file}"`
  if [[ ${f} != "`basename "$0"`" ]]; then # Not this installer
    link "bin/${f}" "${HOME}/bin/${f}"
  fi
done

echo
if [ "$backed_up" -eq 1 ]; then
  echo "Originals backed up to $BACKUP_DIR"
fi
echo "Done."
