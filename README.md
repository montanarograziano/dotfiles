# dotfiles

Personal chezmoi-managed configuration for Apple Silicon (arm64) macOS only. Nothing here targets Intel Macs, Linux, or Windows, and none of it will be adapted to do so.

This repository doubles as both a plain git repo (holding `Brewfile`, `scripts/`, this `README.md`) and a chezmoi source state (everything under `home/`, selected via `.chezmoiroot`). The two coexist in the same checkout on purpose, see "How the pieces fit together" below. On a machine where this checkout currently lives at `~/.config` (as it does right now), that coexistence is transitional, see [Cutting over from a `~/.config` checkout to the standard chezmoi source](#cutting-over-from-a-config-checkout-to-the-standard-chezmoi-source).

## Contents

- [Fastest fresh install](#fastest-fresh-install)
- [Bootstrap alternative (manual)](#bootstrap-alternative-manual)
- [How the pieces fit together](#how-the-pieces-fit-together)
- [What `chezmoi apply` actually does](#what-chezmoi-apply-actually-does)
- [Git identity: work vs personal](#git-identity-work-vs-personal)
- [SSH: separate concern from identity](#ssh-separate-concern-from-identity)
- [Cutting over from a `~/.config` checkout to the standard chezmoi source](#cutting-over-from-a-config-checkout-to-the-standard-chezmoi-source)
- [Daily workflow](#daily-workflow)
- [Brewfile maintenance](#brewfile-maintenance)
- [Updating Pi (coding agent) settings](#updating-pi-coding-agent-settings)
- [Adding new files safely](#adding-new-files-safely)
- [What is intentionally unmanaged](#what-is-intentionally-unmanaged)
- [Reviewing npm install scripts for pi's plugins](#reviewing-npm-install-scripts-for-pis-plugins)
- [Rollback](#rollback)
- [Troubleshooting](#troubleshooting)
- [Security](#security)
- [Verification checklist](#verification-checklist)

## Fastest fresh install

Do **not** use `sudo`. Homebrew refuses to run as root. `bootstrap.sh` only calls `sudo` internally where strictly required.

```sh
curl -O https://raw.githubusercontent.com/montanarograziano/dotfiles/main/scripts/bootstrap.sh
chmod +x bootstrap.sh
./bootstrap.sh
exec zsh -l
```

`bootstrap.sh`:

1. Verifies you're on macOS/arm64, aborts otherwise.
2. Installs Xcode Command Line Tools if missing.
3. Installs Homebrew if missing.
4. Installs `chezmoi` via Homebrew if missing.
5. Runs `chezmoi init montanarograziano/dotfiles` (override with `DOTFILES_REPO=you/fork ./bootstrap.sh`). This clones the repo into chezmoi's own source directory, `~/.local/share/chezmoi` by default. It does **not** touch `~/.config` at this step, and there's no reason to point it anywhere else, see the cutover section if you ever end up on a machine where that's not true.
6. Shows `chezmoi diff` (read-only) and asks you to confirm before running `chezmoi apply`.

The `chezmoi init` step also renders `home/.chezmoi.toml.tmpl`, which prompts you once for:

- Work git name and email
- Personal git name and email
- Personal GitHub handle

These are stored in chezmoi's own local config file (`~/.config/chezmoi/chezmoi.toml`, machine-local, never committed) and only asked once (`promptStringOnce`); re-running `chezmoi init` or `chezmoi apply` later will not ask again unless you delete/edit that config. There is no `.chezmoidata.yaml` in this repo, identity data only ever lives in that local config file, never in git.

`exec zsh -l` is needed because the shell config only takes effect in a new shell.

## Bootstrap alternative (manual)

If Homebrew and chezmoi are already installed (or you'd rather not curl+run a script):

```sh
chezmoi init montanarograziano/dotfiles
chezmoi diff        # review before touching anything
chezmoi apply
exec zsh -l
```

Both paths are idempotent: re-running `chezmoi apply` (or `bootstrap.sh`) is safe, chezmoi only ever creates/updates the specific files and scripts tracked in its source state. It never deletes or wholesale-replaces `~/.config`.

## How the pieces fit together

- `.chezmoiroot` contains `home`, so chezmoi's source state root is `<source dir>/home/`, not the repo root.
- Everything **outside** `home/` (`Brewfile`, `scripts/`, this file) is plain git content that chezmoi never templates or applies. It's just colocated in the same repo for convenience.
- Inside `home/`, standard chezmoi naming applies: `dot_foo` → `.foo`, `dot_config/bar` → `.config/bar`, `private_bar` → `bar` applied with owner-only (`0600`/`0700`) permissions, `create_x.tmpl` → written once and never overwritten by `chezmoi apply`, `run_once_*` / `run_onchange_*` are scripts, not files, and the `_before_`/`_after_` part of a script's name controls whether it runs before or after every target file is materialized, not just relative to files with a similar filename prefix.
- Destination directory is always `$HOME` (chezmoi default). Source directory should be chezmoi's default, `~/.local/share/chezmoi`, on every machine. Some machines temporarily have this repo checked out directly at `~/.config` instead (this one, right now); that's a transitional state to cut over out of, not a supported long-term layout, see [Cutting over from a `~/.config` checkout to the standard chezmoi source](#cutting-over-from-a-config-checkout-to-the-standard-chezmoi-source) below.

## What `chezmoi apply` actually does

In this exact order, regardless of where the source directory lives:

1. `run_once_before_00-xcode-and-homebrew.sh`: re-verifies macOS/arm64, installs Xcode CLT and Homebrew if missing. Runs once ever (chezmoi tracks that by hash). This is the only script that runs *before* any target file is materialized.
2. Every regular file is materialized into `$HOME`: shell config (`zsh/`, `ZDOTDIR` layout, plus `~/.config/fish/conf.d/uv.env.fish` for the rare shell that isn't zsh), `~/.gitconfig`, `~/.config/git/ignore` (the global `core.excludesFile` target, see [Git identity](#git-identity-work-vs-personal)), `~/.vimrc`, `~/.pi/agent/settings.json`, `~/.config/pi/web-search.json` (see [Updating Pi](#updating-pi-coding-agent-settings) for why these two live at different roots), `btop`/`htop`/`starship`/`ghostty`/`marimo`/`cookiecutter` configs, `~/.config/Brewfile`, the wallpaper, and the two `create_*.gitconfig.tmpl` identity files (only if they don't already exist at the destination).
3. `run_onchange_after_10-macos-defaults.sh`: applies macOS user defaults (Finder, trackpad, dark mode, Dock hover, screenshot location). Per-user only, no `sudo`. Re-runs automatically whenever this script's own content changes.
4. `run_onchange_after_20-brew-bundle.sh.tmpl`: runs `brew bundle --file="$HOME/.config/Brewfile"`. Re-runs automatically whenever `Brewfile` changes (chezmoi embeds a hash of it in the script). A single failing formula/cask does not abort the run. `~/.config/Brewfile` was already written in step 2 above by the time this runs, on every install, regardless of whether the source directory is `~/.local/share/chezmoi` or anywhere else, there is no fresh-install gap here. The script's own `if [[ ! -f "$BREWFILE" ]]` guard is defensive, not something that's expected to trigger.
5. `run_onchange_after_30-dev-tools.sh`: installs/upgrades `uv`, Python 3.10–3.13, global `uv tool` CLIs (`ruff`, `mypy`, `pytest`, `pre-commit`, `commitizen`, `cookiecutter`, `marimo`), and Rust + `rust-analyzer`. Re-runs when this script's content changes (e.g. you add a tool to it).
6. `run_once_after_40-remove-legacy-zshenv-zdotdir.sh`: one-time cleanup for machines previously bootstrapped by the old, pre-chezmoi `scripts/tools.sh`, which appended a `ZDOTDIR` line to the system-wide `/etc/zshenv` (needing `sudo`, affecting every user on the machine). That mechanism is retired; this script removes the stale line if present. It deliberately runs dead last, *after* every other target and script, so the new `dot_zshenv` (which sets `ZDOTDIR` itself, per-user, no `sudo`) is already the live config before anything touches the old system-wide file. No-op if the legacy line isn't there.

None of these steps back up or delete unmanaged files in `~/.config` (`gcloud/`, `notion/`, `herdr/`, etc. are never touched).

## Git identity: work vs personal

`~/.gitconfig` (from `home/dot_gitconfig`) sets:

```gitconfig
[core]
 excludesFile = ~/.config/git/ignore

[user]
 useConfigOnly = true

[includeIf "gitdir:~/workspace/intella/"]
 path = ~/.config/git/work.gitconfig
[includeIf "gitdir:~/workspace/personal/"]
 path = ~/.config/git/personal.gitconfig
[includeIf "gitdir:~/.local/share/chezmoi/"]
 path = ~/.config/git/personal.gitconfig
[includeIf "gitdir:~/.config/"]
 path = ~/.config/git/personal.gitconfig
```

`core.excludesFile` points at `~/.config/git/ignore` (source `home/dot_config/git/ignore`), a small **portable** global gitignore, currently just `.DS_Store`. It's tracked and applied on every install specifically so `core.excludesFile` always resolves to a real file, git does not error if it's missing, but a dangling `excludesFile` silently ignores nothing, which defeats the point of setting it. Machine-local or secret ignore patterns still belong in a repo's own `.git/info/exclude`, not here.

What this means in practice:

- **`useConfigOnly = true` fails closed.** There is no default `[user] name/email` anywhere. If a repo isn't under one of the `includeIf` paths below, git refuses to commit ("Author identity unknown") instead of silently guessing from your OS username. This is deliberate: wrong identity on a commit is worse than a blocked commit.
- **Workspace roots are required, and must be lowercase exactly as written**: `~/workspace/intella/` for work repos, `~/workspace/personal/` for personal repos. `includeIf gitdir:` matching is a literal path/glob prefix match, `~/Workspace/Intella/` or any other casing will not match, and you'll silently get the fail-closed error above with no obvious cause. Create both directories and clone your repos under the matching one:

  ```sh
  mkdir -p ~/workspace/intella ~/workspace/personal
  ```

- **The chezmoi source directory itself gets the personal identity**, via two `includeIf` blocks: `gitdir:~/.local/share/chezmoi/` for the standard source location, and `gitdir:~/.config/` for the transitional state where this repo is checked out directly at `~/.config` (as it is right now), see the cutover section. Both are already tracked in `home/dot_gitconfig`, no manual step is needed on either layout, committing dotfile changes from `~/.config/` resolves the personal identity just like it does from `~/.local/share/chezmoi/`.
- The two identity files are created **once** by chezmoi from templates and are never overwritten by `chezmoi apply`:
  - `home/dot_config/git/create_work.gitconfig.tmpl` → `~/.config/git/work.gitconfig`
  - `home/dot_config/git/create_personal.gitconfig.tmpl` → `~/.config/git/personal.gitconfig`
  Edit them directly with your editor after the first apply; your edits survive future `chezmoi apply` runs.

**Warning about `chezmoi add` / `chezmoi re-add` on these two files.** Verified against chezmoi v2.72:

- `chezmoi re-add` (even `--force`, even targeted at the file) is safe: chezmoi refuses to overwrite `.tmpl`-sourced files, full stop. Your `{{ .personal.name }}` template markers are preserved.
- `chezmoi add` (not re-add) on an already-templated path is **not** safe: it asks "adding ... would remove template attribute, continue?", and answering yes (or passing `--force`) replaces the tracked template with the literal current file content, permanently baking your real name/email into git history and losing the templating.

Never run plain `chezmoi add` against `~/.config/git/work.gitconfig` or `~/.config/git/personal.gitconfig`. If you need to change what they contain, edit the destination files directly, or edit the `.tmpl` sources with `chezmoi edit --source`.

## SSH: separate concern from identity

Git identity above never touches SSH. Which key gets used for which host is entirely `~/.ssh/config`'s job, and that file is intentionally **not** managed by chezmoi (private, host-specific, differs per machine). You maintain it by hand.

The one thing worth knowing: if you have two accounts on the same SSH hostname (e.g. a personal and a work GitHub account, both `github.com`), you need a Host **alias** for the second one, since SSH can't otherwise tell which key to offer:

```sshconfig
# Personal account, direct hostname
Host github.com
 HostName github.com
 User git
 IdentityFile ~/.ssh/personal_key
 IdentitiesOnly yes

# Work account, same hostname as above -> needs an alias.
# Clone/set remotes as: git@work-github:org/repo.git
Host work-github
 HostName github.com
 User git
 IdentityFile ~/.ssh/work_key
 IdentitiesOnly yes
```

A distinct hostname (a self-hosted GitLab, a customer's server, etc.) doesn't need an alias, it matches by hostname directly. Add one `Host` block per key/hostname combination you actually use; this repo does not ship a template for this file because the actual host list is machine- and account-specific.

## Cutting over from a `~/.config` checkout to the standard chezmoi source

If `~/.config` on a machine is *already* a git checkout of this repo (as it is right now, on this machine), don't set chezmoi's source directory to `~/.config` and leave it there. That's a transitional layout this repo tolerates, not a destination. `~/.config` also holds a lot of real, unmanaged app runtime state (`gcloud/`, `notion/`, `herdr/`, `configstore/`, `.wrangler/`, caches, sockets, credentials, ...) that has nothing to do with this repo and must not be disturbed. Cut over to the standard source location instead:

1. **Commit and push whatever is pending** in the current checkout first, so nothing is lost:

   ```sh
   cd ~/.config
   git status
   git add -A && git commit -m "..." && git push
   ```

2. **Clone the pushed repo into chezmoi's standard source directory.** Clone fresh rather than moving `~/.config` itself, moving it would drag all that unrelated runtime state along with it:

   ```sh
   git clone git@github.com:montanarograziano/dotfiles.git ~/.local/share/chezmoi
   ```

3. **Point chezmoi at the new source and preview:**

   ```sh
   chezmoi init --source ~/.local/share/chezmoi
   chezmoi diff
   ```

   If an older version of this README ever led you to hand-pin `sourceDir = "$HOME/.config"` into chezmoi's own config file (`~/.config/chezmoi/chezmoi.toml`), remove that line (or delete the file entirely) before running `chezmoi init` above, otherwise the new source direction won't stick.

4. **Apply, then confirm the source actually moved:**

   ```sh
   chezmoi apply
   exec zsh -l
   chezmoi source-path   # must print .../.local/share/chezmoi/home, NOT anything under ~/.config
   ```

5. **Only after that succeeds**, remove the now-redundant repo scaffolding left behind at `~/.config`. This is deliberately a short, exact list, everything else in `~/.config` either just became a live chezmoi-managed destination in step 4 (chezmoi already overwrote it in place, e.g. `Brewfile`, `btop/`, `starship/`, `git/personal.gitconfig`) or is unrelated app state that was never part of this repo's job to touch (`gcloud/`, `jgit/`, etc.). Do not `rm -rf` broadly, only remove exactly this:

   ```sh
   cd ~/.config
   rm -rf .git .chezmoiroot home README.md .gitignore scripts
   ```

   Those six paths are pure repo/chezmoi-source bookkeeping (this repo's own `.git`, its `.chezmoiroot` marker, the `home/` source subtree, this file, its `.gitignore`, and the legacy `scripts/` directory). None of them is a real chezmoi destination or app runtime state, deleting them just removes the leftover checkout, nothing your shell or any app depends on.

   The stale `pi/agent/settings.json` copy (repo-root, superseded by `~/.pi/agent/settings.json`) can be removed too if you want (`rm -rf pi/agent`), but leave `pi/web-search.json` and `pi/web-search-cache/` alone, chezmoi now manages the former in place and the latter is real cache data.

## Daily workflow

```sh
chezmoi edit ~/.zshrc          # opens the SOURCE file in $EDITOR (not the destination)
chezmoi diff                   # preview pending changes, read-only
chezmoi apply                  # materialize source -> destination
chezmoi apply ~/.zshrc         # materialize just one target

chezmoi add ~/.config/newtool/config.toml   # start tracking a new destination file
chezmoi re-add                              # pull ALL your local destination edits back into source (skips templates, see warning above)
chezmoi re-add ~/.config/starship/starship.toml   # or just one file

chezmoi update                 # git pull --rebase --autostash in the source repo, then apply

chezmoi cd                     # drop into a shell inside the source directory
chezmoi git add -A
chezmoi git -- commit -m "..."
chezmoi git push
```

`chezmoi cd` / `chezmoi git ...` operate on whichever directory `chezmoi source-path` currently reports, this is normally `~/.local/share/chezmoi`, where plain `git`, `gh`, etc. also work directly without the `chezmoi` wrapper.

## Brewfile maintenance

The canonical Brewfile is `home/dot_config/Brewfile` (chezmoi source), applied to `~/.config/Brewfile`. Edit it like any other chezmoi-managed file:

```sh
chezmoi edit ~/.config/Brewfile   # opens the SOURCE file in $EDITOR, then...
chezmoi apply                     # run_onchange_after_20 re-runs automatically, the embedded hash changed

# or edit the destination directly and pull the change back into source:
$EDITOR ~/.config/Brewfile
chezmoi re-add ~/.config/Brewfile
```

To install/update it without waiting for a full `chezmoi apply`:

```sh
brew bundle --file="$HOME/.config/Brewfile"
```

On a machine where this checkout still lives at `~/.config` (see the cutover section), you'll also see a plain, non-chezmoi `Brewfile` at the repo root, at the exact same path. That one is a pre-chezmoi leftover, it is **not** canonical, chezmoi just overwrites it in place with the real content on every `chezmoi apply`. Never hand-edit it expecting the change to persist.

## Updating Pi (coding agent) settings

Pi (the `pi-coding-agent` Homebrew formula) reads two separate config files from two different roots, and they're managed differently on purpose:

- **Agent settings**, `~/.pi/agent/settings.json`, source `home/dot_pi/agent/create_settings.json`. Pi always resolves this from a fixed `~/.pi/agent/` path; it does not consult `$XDG_CONFIG_HOME`. It's a plain (non-templated) chezmoi-managed file, chezmoi writes a real file here, not a symlink. It uses the `create_` attribute on purpose: pi **rewrites this file itself** (`lastChangelogVersion` on upgrade, `defaultModel`/`defaultProvider` whenever you switch model in-session). Managed as an ordinary file it would drift permanently, and every `chezmoi apply` would silently revert your live model choice back to whatever was committed. `create_` means chezmoi writes it once on a fresh machine and never touches it again. The trade-off: changes to the committed `packages` list do **not** propagate to a machine that already has the file. Edit the live file there instead.
- **Web search config**, `~/.config/pi/web-search.json`, source `home/dot_config/private_pi/private_web-search.json`. Pi's web-search feature *does* honor `$XDG_CONFIG_HOME`, which this repo's `home/dot_zshenv` sets to `~/.config`, so pi resolves this one under `~/.config/pi/`, not `~/.pi/`. The `private_` prefix is applied on **both** path components: the `private_pi` directory makes `~/.config/pi/` owner-only (`0700`), and the `private_web-search.json` file makes `~/.config/pi/web-search.json` itself owner-only (`0600`); `private_` never appears in the applied path, only in permissions. Don't move this file under `dot_pi/`, that would put it at the wrong path on any shell where `$XDG_CONFIG_HOME` is set, which is every shell this repo configures.

Both are edited the same way:

```sh
chezmoi edit ~/.pi/agent/settings.json      # or: chezmoi edit ~/.config/pi/web-search.json
chezmoi apply

# or edit the live file directly, then pull the change back into source:
$EDITOR ~/.pi/agent/settings.json
chezmoi re-add ~/.pi/agent/settings.json    # safe: neither file is a template
# note: for the create_ agent-settings file, re-add updates the SOURCE only.
# It will still never be written back to an existing destination.
```

Whichever you pick, commit the result from the source checkout (`chezmoi cd`, or directly in `~/.local/share/chezmoi` if you're not there already).

A repo-root `pi/` directory may exist as a leftover on a `~/.config`-as-source machine, see [What is intentionally unmanaged](#what-is-intentionally-unmanaged), it is not where pi actually reads either file from.

## Adding new files safely

```sh
chezmoi add ~/.config/some-tool/config.yaml
```

- If the file might contain a secret, add `--encrypt` (requires an `age`/`gpg` key configured in chezmoi's config first) or just don't add it, see below.
- If it should be created once and then left alone (like the git identity files), rename the resulting source file with a `create_` prefix (`chezmoi chattr +create <path>` does this for you) before committing.
- If it should be readable only by you (like the web-search config), use `chezmoi chattr +private <path>` before committing.
- Never `chezmoi add` a file, then later `chezmoi add` it again with the intent of just refreshing content, if it's a `create_*` or otherwise templated source. Use `chezmoi re-add`, per the warning above.

## What is intentionally unmanaged

Not tracked by chezmoi or git, on purpose, generally because it's a secret, machine-local runtime state, or a cache:

- `~/.ssh/config`, SSH keys: private, host-specific.
- `gcloud/`, `notion/`, `herdr/`, `configstore/`, `.wrangler/`, `swiftpm/`, `k9s/`, `glab-cli/`, `helm/`, `cagent/`, `opencode/`, `zed/`, `.semgrep/`, `.opengrep/`, `containers/`: app runtime state/caches, see `.gitignore`.
- Everything under `~/.pi` except `settings.json` (auth, sessions, memory, npm cache, model cache): explicitly excluded via `.gitignore`.

On a machine where this checkout still lives at `~/.config` (a transitional state, see the cutover section), you'll also see a batch of pre-chezmoi, now-gitignored leftovers sitting at the repo root, all superseded by `home/`: `.gitconfig`, `.gitignore.global`, `Brewfile`, `btop/`, `cookiecutter/`, `fish/`, `ghostty/`, `git/` (old `local.gitconfig`/`personal.gitconfig` plus `.example` files, superseded by `create_work.gitconfig.tmpl`/`create_personal.gitconfig.tmpl`), `htop/`, `jgit/`, `marimo/`, `neofetch/`, `pi/agent/settings.json` (stale, superseded by `home/dot_pi/agent/create_settings.json`), `starship/`, `vim/`, `wallpapers/`, `zsh/`. Most of these paths coincide with real chezmoi destinations and simply get overwritten in place by `chezmoi apply` (`Brewfile`, `btop/`, `git/personal.gitconfig`, `pi/web-search.json`, etc.); a few have no chezmoi counterpart at all (`jgit/`, `vim/`, `.gitconfig`, `.gitignore.global`, `neofetch/`, `pi/agent/`) and are just dead weight. None of it is deleted for you automatically, see the cutover section for the exact, safe cleanup list.

## Reviewing npm install scripts for pi's plugins

`~/.pi/agent/settings.json`'s `packages` array lists `npm:`-prefixed plugin packages that `pi` installs for itself into `~/.pi/agent/npm`, separately from Homebrew/`brew bundle`. Recent `npm` blocks lifecycle (`preinstall`/`postinstall`/`install`) scripts by default for packages it hasn't approved before; some of pi's plugins (and their transitive dependencies) ship native builds or postinstall steps that trigger this.

Review and approve deliberately, package by package, never as a blanket action:

```sh
cd ~/.pi/agent/npm
npm install-scripts ls              # lists packages with pending/blocked install scripts, and prints each script
```

For each package listed, read what its script actually does before deciding:

```sh
npm install-scripts approve <pkg>   # only for a package you've reviewed and trust
npm install-scripts deny <pkg>      # for anything you don't recognize or don't trust
```

There is no "approve everything" step, and you should not improvise one. An unreviewed `postinstall` hook from a compromised or malicious transitive dependency is exactly the failure mode this mechanism exists to catch. After approving, verify things still work:

```sh
pi --version
```

If a specific plugin is actually broken (not just pending approval), reinstall it manually per that package's own instructions rather than approving scripts you haven't read.

## Rollback

- **Undo a destination file back to what source currently says:** `chezmoi apply <path>`.
- **Undo a bad edit already committed to source:** `chezmoi cd`, `git revert <sha>` (or `git reset` if unpushed), `chezmoi apply`.
- **Stop chezmoi from managing a file, without deleting it from disk:** `chezmoi forget <path>` (alias: `chezmoi unmanage`).
- **Permanently delete a file everywhere (source, destination, chezmoi's state):** `chezmoi destroy <path>`. Destructive, confirms before acting.
- **Reset chezmoi's own bookkeeping without touching already-applied files:** `chezmoi purge` removes chezmoi's config/cache/source directories but explicitly leaves the destination (your actual dotfiles on disk) intact. You'd need to re-run init/apply afterward to manage anything again.

## Troubleshooting

- **"Author identity unknown" / commit refused:** you're not inside `~/workspace/intella/`, `~/workspace/personal/`, `~/.local/share/chezmoi/`, or `~/.config/` (exact lowercase paths, all four are covered by `includeIf` blocks already, see above). `git config --get-all include.path` and `git config user.email` from inside the repo to check what actually resolved.
- **"Brewfile not found... Skipping" during `chezmoi apply`:** shouldn't happen in a normal run. Chezmoi always materializes `~/.config/Brewfile` (from `home/dot_config/Brewfile`) before `run_onchange_after_20-brew-bundle.sh.tmpl` runs, on every install regardless of source layout, this is not a fresh-install gap. If you see it anyway, something removed or moved `~/.config/Brewfile` between steps (e.g. you ran the script standalone). Fix: `chezmoi apply` again, or `brew bundle --file="$HOME/.config/Brewfile"` once the file exists.
- **`zsh` doesn't pick up this repo's config:** confirm `echo $ZDOTDIR` prints `$HOME/.config/zsh`, then `exec zsh -l`. If it's empty, `~/.zshenv` (which sets it) wasn't applied yet, run `chezmoi apply` again.
- **`chezmoi apply` prompts about a merge/conflict:** you edited a destination file directly without `chezmoi re-add` first. Answer the diff prompt, or run `chezmoi re-add <path>` beforehand next time.
- **`chezmoi: config file template has changed, run chezmoi init to regenerate config file`:** harmless warning if you've hand-edited `sourceDir` into the config (e.g. following an old, now-removed version of this README's migration advice). Fix it properly instead of ignoring it: follow the [cutover section](#cutting-over-from-a-config-checkout-to-the-standard-chezmoi-source) to move the source to `~/.local/share/chezmoi` and drop the hand-pinned line for good.
- **`pi` prints npm warnings about skipped install scripts:** expected the first time a plugin package needs review, see [Reviewing npm install scripts for pi's plugins](#reviewing-npm-install-scripts-for-pis-plugins). Not something to silence, something to act on.

## Security

- No secrets are committed. `.gitignore` explicitly excludes credential stores, tokens, `auth.db`, `access_tokens.db`, SSH keys, and machine-local app state.
- Work and personal git identity (name, email, GitHub handle) are captured once via interactive prompts in `home/.chezmoi.toml.tmpl` (`promptStringOnce`) and stored only in chezmoi's own local config file (`~/.config/chezmoi/chezmoi.toml`), which is machine-local and never committed (`/chezmoi/` is anchored in `.gitignore`). This repo has no `.chezmoidata.yaml`; identity data never lives in git.
- `user.useConfigOnly = true` exists specifically so a misconfigured or new repo never silently commits under the wrong identity (see above), review it if you ever see a commit authored oddly.
- No file in this repo automatically sources a `.env` file into your shell. An earlier version of the zsh config did this, and it was removed on purpose: auto-sourcing whatever `.env` happens to sit in a directory you `cd` into is an arbitrary-code-execution vector (a hostile repo could ship a `.env` containing a shell function/alias that runs the moment your shell sources it). If you need per-project env vars, load them explicitly (`set -a; source .env; set +a`) or use a tool that requires per-directory opt-in, like `direnv`.
- If you ever need to track a genuine secret in chezmoi, use `chezmoi add --encrypt` with `age`/`gpg` configured first. Nothing in this repo currently does this.

## Verification checklist

Run after any fresh install, bootstrap, or cutover:

```sh
# chezmoi itself
chezmoi doctor                                  # flags missing tools/config problems
chezmoi source-path                             # sanity-check where source actually is (should be ~/.local/share/chezmoi/home)

# shell
echo $ZDOTDIR                                   # -> $HOME/.config/zsh
exec zsh -l && echo ok                          # opens a clean login shell

# macOS defaults
defaults read com.apple.finder AppleShowAllFiles   # -> 1

# Homebrew
brew bundle check --file="$HOME/.config/Brewfile"  # -> "The Brewfile's dependencies are satisfied."

# dev tools
uv --version && python3 --version && rustc --version

# git identity, run from inside each workspace root
mkdir -p ~/workspace/intella/_check && (cd ~/workspace/intella/_check && git init -q && git config user.email) # -> your work email
mkdir -p ~/workspace/personal/_check && (cd ~/workspace/personal/_check && git init -q && git config user.email) # -> your personal email
rm -rf ~/workspace/intella/_check ~/workspace/personal/_check

# ssh (adjust host aliases to whatever you configured)
ssh -T git@github.com

# pi
pi --version
cat ~/.pi/agent/settings.json | head -5
cat ~/.config/pi/web-search.json
```
