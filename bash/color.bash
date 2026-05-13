# Reference
# https://stackoverflow.com/questions/4842424/list-of-ansi-color-escape-sequences
# https://gist.githubusercontent.com/nberlette/1f7357b4857f40c63b5148433c8b2619/raw/21a46dba88d6c79c48b840597dd237459e002895/hex2rgb.sh

function color_text {
  echo "\e[$2m${1}\e[0m"
}

function rgb_text {
  hex=${1/\#/}
  printf -v r "%d" 0x"${hex:0:2}"
  printf -v g "%d" 0x"${hex:2:2}"
  printf -v b "%d" 0x"${hex:4:2}"
  printf "\033[38;2;${r};${g};${b}m${2}\033[0m"
}
