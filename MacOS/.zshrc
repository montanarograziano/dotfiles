source ~/.alias

source ~/.autoloads

export HISTSIZE=1000000   # the number of items for the internal history list
export SAVEHIST=1000000   # maximum number of items for the history file

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

# Env variables
export COOKIECUTTER_CONFIG=~/cookiecutter.yaml
# trim space path like `Application Support/`
export PATH=$(echo $PATH | sed 's/\ /\\ /g')
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export PATH="~/.local/bin:$PATH"

# Autocomplete
fpath+=("$(brew --prefix)/share/zsh/site-functions")
eval "$(rbenv init - zsh)"
eval "$(uv generate-shell-completion zsh)"
eval "$(starship init zsh)"

source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh