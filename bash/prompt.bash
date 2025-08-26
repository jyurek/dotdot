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
  $(git diff-index --quiet HEAD 2>/dev/null) && echo -n '' || echo -n '✏ '
}

function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

function parse_dot_dirty {
  $(dot diff-index --quiet HEAD 2>/dev/null) && echo -n '34m' || echo -n '35m'
}

function parse_dot_branch {
  dot branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

function latest_command {
  history | tail -n 1 | sed 's/[0-9 ]*\(.*\)/\1/'
}

function color_text {
  echo "\033[38;2;$2m\]$1\[\e[0m\]"
}

function prompt_command_function
{
  last_result=$?
  timer_stop

  last_result="\[\e[33m\]$last_result\[\e[0m\]"
  titlebar_last_command="\[\e]2;$(latest_command)\a\]"

  git_branch=$(parse_git_branch)
  git_dirty=$(parse_git_dirty)

  git_dirty=${git_dirty:+" \[\e[31m\]$git_dirty\[\e[0m\]"}
  git_branch=${git_branch:+" (\[\e[35m\]${git_branch}\[\e[0m\]${git_dirty})"}
  dot_dirty=$(parse_dot_dirty)
  dot_branch=$(parse_dot_branch)

  current_node=
  type nvm > /dev/null 2>&1 && current_node=$(nvm current)
  color_node=$(color_text $current_node "231;231;64")

  current_ruby=
  type chruby > /dev/null 2>&1 && current_ruby=$(chruby | ag \\\* | cut -d" " -f 3)
  # current_ruby=$(cat ~/.tool-versions | ag ruby | cut -d" " -f 2)
  color_ruby=$(color_text $current_ruby "231;64;64")

  current_elixir=$(asdf list elixir | ag \\* | cut -d* -f2)
  color_elixir=$(color_text $current_elixir  "255;192;128")

  PS1="$last_result \[\e[32m\]${timer_show}s\[\e[0m\] $color_ruby $color_elixir $color_node \[\e[32m\]\w\[\e[0m\]$git_branch \$ "
}

export PROMPT_COMMAND=prompt_command_function
