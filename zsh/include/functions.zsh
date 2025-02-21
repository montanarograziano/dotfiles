autoload -U add-zsh-hook

load_dotenv() {
  # Check if a .env file exists in the current directory
  if [[ -f .env ]]; then
    # Use dotenv-cli or parse .env file and export variables
    set -a  # Automatically export all variables
    source .env  # Load the .env file
    set +a  # Stop automatically exporting variables
  fi
}

# function auto_venv() {
#   if [[ -z "$VIRTUAL_ENV" ]]; then
#     # If no virtual environment is active and .venv exists, activate it
#     if [[ -d ./.venv ]]; then
#       source ./.venv/bin/activate
#     fi
#   else
#     # If a virtual environment is active, check if the current directory matches
#     parentdir="$(dirname "$VIRTUAL_ENV")"
#     if [[ "$PWD"/ != "$parentdir"/* ]]; then
#       deactivate
#     fi
#   fi
# }

# Hook into the 'chpwd' event to load .env whenever you change directories
add-zsh-hook chpwd load_dotenv
# add-zsh-hook chpwd auto_venv
load_dotenv
# auto_venv