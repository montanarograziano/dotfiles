histfile="${XDG_CACHE_HOME:-"$HOME/.cache"}/zsh/history"

if [ -f "$histfile" ]; then
	touch "$histfile"
fi

export HISTFILE="$histfile"
export HISTIZE=1000000
export HISTFILESIZE=1000000
export SAVEHIST=1000000

unset histfile

# share history across multiple zsh sessions
setopt SHARE_HISTORY

# adds commands as they are typed, not at shell exit
setopt INC_APPEND_HISTORY

# expire duplicates first
setopt HIST_EXPIRE_DUPS_FIRST

# Delete old recorded entry if new entry is a duplicate.
setopt HIST_IGNORE_ALL_DUPS

# Don't write duplicate entries in the history file.
setopt HIST_SAVE_NO_DUPS

# do not store duplications
setopt HIST_IGNORE_DUPS

#ignore duplicates when searching
setopt HIST_FIND_NO_DUPS

# removes blank lines from history
setopt HIST_REDUCE_BLANKS

bindkey ';5C' forward-word
bindkey ';5D' backward-word


zmodload zsh/complist

# colors for print
autoload -Uz colors && colors