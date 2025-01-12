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
# Hook into the 'chpwd' event to load .env whenever you change directories
add-zsh-hook chpwd load_dotenv
load_dotenv