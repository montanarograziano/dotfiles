paths=(
    "${HOME}/.local/bin"
    "${XDG_DATA_HOME}/bob/nvim-bin"
    "${XDG_DATA_HOME}/jetbrains/bin"
    "/usr/bin"
    "/bin"
    "/usr/sbin"
    "/sbin"
)
export PATH="${(j.:.)paths}" # join with colon, works in zsh

# MUST be before any "hash" call!
eval "$(/opt/homebrew/bin/brew shellenv)"

# Env variables
export COOKIECUTTER_CONFIG="${XDG_CONFIG_HOME}/cookiecutter/cookiecutter.yaml"
# trim space path like `Application Support/`
export PATH=$(echo $PATH | sed 's/\ /\\ /g')
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export PATH="~/.local/bin:$PATH"


if [[ -f "${XDG_DATA_HOME}/cargo/bin/rustup" ]]; then
	export RUSTUP_HOME="${XDG_DATA_HOME}/rustup"
	export CARGO_HOME="${XDG_DATA_HOME}/cargo"
	source "${CARGO_HOME}/env"
fi