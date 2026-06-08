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

Two separate concerns, kept separate:
- **Identity** (commit author name/email) is chosen by git, per repo location.
- **Authentication** (which SSH key) is chosen by `~/.ssh/config`, per host.

### Identity (git)

Identity is **not** stored in the tracked `.gitconfig`. The tracked file holds only generic settings plus an `[include]` of an untracked, gitignored local file, so personal/work details are never committed.

- `~/.config/git/local.gitconfig` sets the **default** identity. On a work machine this is your work account.
- An `includeIf "gitdir:~/.config/"` rule makes the **dotfiles repo itself** commit with your **personal** account from `~/.config/git/personal.gitconfig`.
- Add more `includeIf` rules (e.g. `gitdir:~/personal/`) for personal projects kept elsewhere.

Do **not** use `git config --global user.name/email`: with `~/.gitconfig` symlinked to the tracked repo file, those writes land in version control. Edit the local files instead. `install.sh` seeds them from the `.example` templates on first run:

```sh
vim ~/.config/git/local.gitconfig      # work identity (default)
vim ~/.config/git/personal.gitconfig   # personal identity (dotfiles repo)
```

### Authentication (SSH keys)

Map each git host to the right key in `~/.ssh/config`. These files set no SSH key themselves, so keys never get tangled with identity, and different hosts can use different keys.

```sshconfig
# Personal GitHub
Host github.com
	HostName github.com
	User git
	IdentityFile ~/.ssh/personal
	IdentitiesOnly yes

# Work GitHub: same hostname as personal, so it needs an ALIAS.
# Clone work repos as: git@work-github:org/repo.git
Host work-github
	HostName github.com
	User git
	IdentityFile ~/.ssh/work
	IdentitiesOnly yes

# Work GitLab: a distinct hostname, so normal URLs work.
Host gitlab.company.tech
	HostName gitlab.company.tech
	User git
	IdentityFile ~/.ssh/work
	IdentitiesOnly yes
```

Generate a key per account and register each PUBLIC half on the matching server:

```sh
ssh-keygen -t ed25519 -f ~/.ssh/personal -C "you@personal.example"
ssh-keygen -t ed25519 -f ~/.ssh/work     -C "you@company.com"
eval "$(ssh-agent -s)"
ssh-add --apple-use-keychain ~/.ssh/personal ~/.ssh/work
pbcopy < ~/.ssh/personal.pub   # paste into the matching SSH key settings
ssh -T git@github.com          # verify
```

Two GitHub accounts share one hostname (`github.com`), so the work one needs a Host **alias** and you clone it as `git@work-github:org/repo.git`. A distinct host (your GitLab server) matches by hostname directly, so normal `git@host:org/repo.git` URLs just work.

To push **this dotfiles repo** with your personal key, set its remote to SSH:

```sh
git -C ~/.config remote set-url origin git@github.com:montanarograziano/dotfiles.git
```
