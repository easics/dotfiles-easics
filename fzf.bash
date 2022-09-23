# Setup fzf
# ---------
if [[ ! "$PATH" == */home/$USER/.fzf/bin* ]]; then
  export PATH="/home/$USER/.fzf/bin:${PATH:+${PATH}:}"
fi

# Auto-completion
# ---------------
# Auto-completion
# ---------------
_fzf_compgen_path() {
  dir=$(git root 2> /dev/null || echo "$1")
  if [ -z "$dir" ]; then
    dir="."
  fi
  command find -L "$dir" \
    -name .git -prune -o -name .hg -prune -o -name .svn -prune -o -name lib -prune -o \( -type d -o -type f -o -type l \) \
    -a -not -path "$dir" -print 2> /dev/null | sed 's@^\./@@'
}

_fzf_compgen_dir() {
  dir=$(git root 2> /dev/null || echo "$1")
  if [ -z "$dir" ]; then
    dir="."
  fi
  command find -L "$dir" \
    -name .git -prune -o -name .hg -prune -o -name .svn -prune -o -name lib -prune -o -type d \
    -a -not -path "$dir" -print 2> /dev/null | sed 's@^\./@@'
}

[[ $- == *i* ]] && source "/home/$USER/.fzf/shell/completion.bash" 2> /dev/null

# Key bindings
# ------------
source "/home/$USER/.fzf/shell/key-bindings.bash"
