paths=(
    "${HOME}/.local/bin"
    "${XDG_DATA_HOME}/jetbrains/bin"
    "/usr/local/bin"
    "/usr/bin"
    "/bin"
    "/usr/sbin"
    "/sbin"
)
# shellcheck disable=SC2296 # zsh-only ${(j.:.)param} join flag, not a subshell; shellcheck has no zsh dialect
export PATH="${(j.:.)paths}" # join with colon, works in zsh

# MUST be before any "hash" call!
eval "$(/opt/homebrew/bin/brew shellenv)"

# Env variables
export COOKIECUTTER_CONFIG="${XDG_CONFIG_HOME}/cookiecutter/cookiecutter.yaml"

# Resolved via macOS's own JVM locator instead of a version-pinned Cellar
# path, so it keeps working across JDK upgrades/switches.
[[ -x /usr/libexec/java_home ]] && export JAVA_HOME="$(/usr/libexec/java_home 2>/dev/null)"
