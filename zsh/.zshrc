sources=(
	"paths"       # set path env variables
	"options"     # configure zsh
    "eval"        # shell hooks and completions
    "aliases"     # utility aliases
	"functions"   # frequently used functions
)

for s in "${sources[@]}"; do
	# shellcheck source-path=./include
	source "$ZDOTDIR/include/${s}.zsh"
done

# Find a better place to insert these?
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh