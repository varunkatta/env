# Generated zsh completion files belong in the XDG cache, not $HOME.
# This file is intended to be sourced before Oh My Zsh initializes compinit.
typeset -g _completion_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
mkdir -p "$_completion_cache_dir" 2>/dev/null
export ZSH_COMPDUMP="$_completion_cache_dir/zcompdump-${HOST}-${ZSH_VERSION}"
unset _completion_cache_dir
