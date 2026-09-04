# Current terminal configuration backup

These files preserve the pre-rice configuration:

- `ghostty.config` → `home/dot_config/ghostty/config`
- `starship.toml` → `home/dot_config/starship/starship.toml`

Restore from the chezmoi source checkout:

```sh
cd ~/.local/share/chezmoi
cp backups/terminal-current/ghostty.config home/dot_config/ghostty/config
cp backups/terminal-current/starship.toml home/dot_config/starship/starship.toml
chezmoi apply
```

The wallpaper is not included or changed.
