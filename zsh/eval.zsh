COMPDIR="${XDG_CACHE_HOME}/zsh/zfunc"

[[ -d "${COMPDIR}" ]] || mkdir -p "${COMPDIR}"

fpath=(${COMPDIR} $fpath) # won't work if there are quotes

# python
command -v uv >/dev/null && uv generate-shell-completion zsh > "${COMPDIR}/_uv"
command -v uvx >/dev/null && uvx --generate-shell-completion=zsh > "${COMPDIR}/_uvx"
command -v ruff >/dev/null && ruff generate-shell-completion zsh > "${COMPDIR}/_ruff"

command -v cz >/dev/null && register-python-argcomplete cz > "${COMPDIR}/_cz"

# rust
command -v rustup >/dev/null && rustup completions zsh > "${COMPDIR}/_rustup"
command -v cargo >/dev/null && rustup completions zsh cargo > "${COMPDIR}/_cargo"

if command -v starship >/dev/null; then
	export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
	eval "$(starship init zsh)"
fi