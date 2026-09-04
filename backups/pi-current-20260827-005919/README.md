# Pi configuration backup

Captured: 20260827-005919

This backup contains the live Pi settings, npm package manifest/lockfile, and local extension files. Secrets such as `auth.json` are intentionally excluded.

Restore settings and local extensions:

```sh
cp "/Users/montanarograziano/.local/share/chezmoi/backups/pi-current-20260827-005919/settings.json" ~/.pi/agent/settings.json
rm -rf ~/.pi/agent/extensions
cp -R "/Users/montanarograziano/.local/share/chezmoi/backups/pi-current-20260827-005919/extensions" ~/.pi/agent/extensions
```

Restore the npm manifest only if needed:

```sh
cp "/Users/montanarograziano/.local/share/chezmoi/backups/pi-current-20260827-005919/npm/package.json" ~/.pi/agent/npm/package.json
cp "/Users/montanarograziano/.local/share/chezmoi/backups/pi-current-20260827-005919/npm/package-lock.json" ~/.pi/agent/npm/package-lock.json
(cd ~/.pi/agent/npm && npm install --legacy-peer-deps)
```
