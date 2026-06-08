export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
# Rust/cargo env (guarded so shells without Rust don't error)
[[ -f "$XDG_DATA_HOME/cargo/env" ]] && . "$XDG_DATA_HOME/cargo/env"
