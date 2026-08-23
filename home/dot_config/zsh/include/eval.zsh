COMPDIR="${XDG_CACHE_HOME}/zsh/zfunc"

[[ -d "${COMPDIR}" ]] || mkdir -p "${COMPDIR}"

fpath=(${COMPDIR} $fpath) # won't work if there are quotes

# Completion scripts are generated once and cached; delete the file under
# ${COMPDIR} to force a regen after upgrading a tool.
# python
[[ -f "${COMPDIR}/_uv" ]] || { command -v uv >/dev/null && uv generate-shell-completion zsh > "${COMPDIR}/_uv"; }
[[ -f "${COMPDIR}/_uvx" ]] || { command -v uvx >/dev/null && uvx --generate-shell-completion=zsh > "${COMPDIR}/_uvx"; }
[[ -f "${COMPDIR}/_ruff" ]] || { command -v ruff >/dev/null && ruff generate-shell-completion zsh > "${COMPDIR}/_ruff"; }
[[ -f "${COMPDIR}/_prek" ]] || { command -v prek >/dev/null && COMPLETE=zsh prek completion > "${COMPDIR}/_prek"; }

[[ -f "${COMPDIR}/_cz" ]] || { command -v register-python-argcomplete >/dev/null && command -v cz >/dev/null && register-python-argcomplete cz > "${COMPDIR}/_cz"; }

# rust
[[ -f "${COMPDIR}/_rustup" ]] || { command -v rustup >/dev/null && rustup completions zsh > "${COMPDIR}/_rustup"; }
[[ -f "${COMPDIR}/_cargo" ]] || { command -v cargo >/dev/null && rustup completions zsh cargo > "${COMPDIR}/_cargo"; }

if command -v starship >/dev/null; then
	export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
	eval "$(starship init zsh)"
fi


autoload -Uz compinit && compinit -d "${XDG_CACHE_HOME}/zsh/zcompdump"
autoload -Uz bashcompinit
