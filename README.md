# What is it?
A repository containing dotfiles for my machines.

Note that it's based on MacOS and therefore it would not work on other OS.

## How to use the dotfiles

Run the following on a fresh machine. **Do not use `sudo`**: Homebrew refuses to run as root and will abort. The scripts call `sudo` only for the few steps that need it, so you will be prompted for your password once or twice along the way.

```sh
# 1. Download the bootstrap script
curl -O https://raw.githubusercontent.com/montanarograziano/dotfiles/main/scripts/bootstrap.sh
chmod +x bootstrap.sh

# 2. Run it as your normal user (NOT with sudo)
./bootstrap.sh

# 3. Load the freshly installed shell configuration
exec zsh -l
```

`bootstrap.sh` will:
- Install Xcode Command Line Tools
- Install Homebrew
- Install git through Homebrew
- Clone this repository into `~/.config`, backing up an existing one to `~/.config.bak/` first
- Run `install.sh`

`install.sh` runs, in order:
- `settings.sh` -> macOS defaults (tap to click, screenshots folder, show hidden files, etc.)
- `brew.sh` -> installs packages listed in `Brewfile` (a single failing cask does not abort the run)
- links `~/.config/.gitconfig` to `~/.gitconfig` (the existing one is backed up to `~/.gitconfig.bak`)
- `tools.sh` -> sets `ZDOTDIR=$HOME/.config/zsh` in `/etc/zshenv` (this is what makes zsh load this repo's config), then installs **uv**, Python **3.9**-**3.12**, dev tools (**mypy**, **pytest**, **pre-commit**, **ruff**, etc.), and **Rust**.

The shell config only takes effect in a new shell, hence step 3 (`exec zsh -l`). Re-running the chain is safe: every step is idempotent.

### Finishing an existing/partial install

If the repo is already at `~/.config` and you just need to complete the setup, skip `bootstrap.sh` and run:

```sh
~/.config/scripts/install.sh   # NOT with sudo
exec zsh -l
```

## Git identity and SSH keys

Git identity is **not** stored in the tracked `.gitconfig`. The tracked file holds only generic settings plus an `[include]` of an untracked, gitignored local file, so personal/work details are never committed.

How identity (and the SSH key) is selected per repo:
- `~/.config/git/local.gitconfig` sets the **default** identity. On a work machine this is your work account. It also sets the SSH key via `core.sshCommand`.
- An `includeIf "gitdir:~/.config/"` rule makes the **dotfiles repo itself** commit and authenticate with your **personal** account from `~/.config/git/personal.gitconfig`.
- Add more `includeIf` rules (e.g. `gitdir:~/personal/`) for personal projects kept elsewhere.

Do **not** use `git config --global user.name/email`: with `~/.gitconfig` symlinked to the tracked repo file, those writes land in version control. Edit the local files (below) instead.

`install.sh` seeds both local files from their `.example` templates on first run. Then fill them in:

```sh
vim ~/.config/git/local.gitconfig      # work identity + work SSH key path
vim ~/.config/git/personal.gitconfig   # personal identity (used for the dotfiles repo)
```

Generate one SSH key per account (the paths must match `core.sshCommand` in the files above):

```sh
ssh-keygen -t ed25519 -f ~/.ssh/work     -C "you@company.com"        # work
ssh-keygen -t ed25519 -f ~/.ssh/personal -C "you@personal.example"   # personal

eval "$(ssh-agent -s)"
ssh-add --apple-use-keychain ~/.ssh/work ~/.ssh/personal

# Add each PUBLIC key to the matching GitHub account (Settings > SSH and GPG keys)
pbcopy < ~/.ssh/work.pub     && open "https://github.com/settings/ssh"   # work account
pbcopy < ~/.ssh/personal.pub && open "https://github.com/settings/ssh"   # personal account

ssh -T git@github.com   # verify
```

Because the key is chosen by `core.sshCommand` based on repo location, you clone with normal `git@github.com:org/repo.git` URLs, no host aliases needed.

To push **this dotfiles repo** with your personal key, switch its remote from HTTPS to SSH:

```sh
git -C ~/.config remote set-url origin git@github.com:montanarograziano/dotfiles.git
```
