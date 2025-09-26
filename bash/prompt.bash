function timer_start {
  timer=${timer:-$SECONDS}
}

function timer_stop {
  timer_show=$(($SECONDS - $timer))
  unset timer
}

trap 'timer_start' DEBUG

function parse_git_dirty {
  # [[ $(git status 2> /dev/null | tail -n1) != "nothing to commit, working tree clean" ]] && echo '✏ '
  $(git diff-index --quiet HEAD 2>/dev/null) && echo -n '' || echo -n '✏'
}

function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

function latest_command {
  history | tail -n 1 | sed 's/[0-9 ]*\(.*\)/\1/'
}

function color_text {
  echo "\[\e[$2m\]${1}\[\e[0m\]"
}

function prompt_command_function
{
  if [[ $? == 0 ]]; then
    last_result=$(color_text $? "90")
  else
    last_result=$(color_text $? "37")
  fi
  timer_stop
  color_runtime=$(color_text ${timer_show}s "33")

  cwd=$(pwd)
  cwd=$(echo $cwd | sed 's/\/Users\/jyurek\/Development\/clients/\+/')
  cwd=$(echo $cwd | sed 's/~\/Development\/clients/\+/')
  color_cwd=$(color_text $cwd "32")

  git_dirty=$(parse_git_dirty)
  color_git_dirty=${git_dirty:+" $git_dirty"}
  git_dirty=$(color_text "$color_git_dirty" "31")

  git_branch=$(parse_git_branch)
  color_git_branch=$(color_text "$git_branch" "31")
  git_branch=${git_branch:+" (${color_git_branch}${git_dirty})"}

  current_node=type nvm > /dev/null 2>&1 && current_node=$(nvm current)
  color_node=$(color_text $current_node "31")

  current_elixir=$(asdf list elixir | ag \\* | cut -d* -f2)
  color_elixir=$(color_text $current_elixir  "35")

  current_ruby=type chruby > /dev/null 2>&1 && current_ruby=$(chruby | ag \\\* | cut -d" " -f 3)
  # current_ruby=$(cat ~/.tool-versions | ag ruby | cut -d" " -f 2)
  color_ruby=$(color_text $current_ruby "34")

  PS1="$last_result $color_runtime $color_ruby $color_elixir $color_node $color_cwd$git_branch \$ "
}

export PROMPT_COMMAND=prompt_command_function
