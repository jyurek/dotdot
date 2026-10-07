function cd {
  builtin cd $@
  stop_at=$HOME
  dir=`pwd`
  while [[ ! -d "$dir/.venv" && $dir != $stop_at ]]; do
    dir=`dirname "$dir"`
  done
  [[ -d $dir/.venv ]] && source $dir/.venv/bin/activate
}
