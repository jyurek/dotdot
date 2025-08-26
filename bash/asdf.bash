# source /opt/homebrew/opt/asdf/libexec/asdf.sh
export ASDF_DATA_DIR=/opt/bin/asdf
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
source <(asdf completion bash)
