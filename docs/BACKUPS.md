# Backups

Date: 2026-02-21

## Backup Directories (Full Snapshot)

1. `$HOME/.claude/backups/kimi-claude-code-20260221-100516`
2. `$HOME/.claude/backups/kimi-full-tune-20260221-101739`

## Additional Single-File Snapshot

3. `$HOME/.claude/backups/settings.json.20260221-105733.bak`
4. `$HOME/.claude/backups/settings.json.20260221-110129.pre-toolsearch-disable.bak`

## Files Included In Each Backup

- `SHA256SUMS`
- `home/ayaz/.claude/.credentials.json`
- `home/ayaz/.claude/settings.json`
- `home/ayaz/.claude/settings.local.json`
- `home/ayaz/.config/Claude/config.json`

## Quick Restore (Latest Backup)

```bash
cp -f $HOME/.claude/backups/kimi-full-tune-20260221-101739$HOME/.claude/settings.json $HOME/.claude/settings.json
cp -f $HOME/.claude/backups/kimi-full-tune-20260221-101739$HOME/.claude/settings.local.json $HOME/.claude/settings.local.json
cp -f $HOME/.claude/backups/kimi-full-tune-20260221-101739$HOME/.claude/.credentials.json $HOME/.claude/.credentials.json
cp -f $HOME/.claude/backups/kimi-full-tune-20260221-101739$HOME/.config/Claude/config.json $HOME/.config/Claude/config.json
chmod 600 $HOME/.claude/settings.local.json $HOME/.claude/.credentials.json
```

## Verify Backup Integrity

```bash
cd $HOME/.claude/backups/kimi-full-tune-20260221-101739
sha256sum -c SHA256SUMS
```

## Quick Restore (Single-File Snapshot)

```bash
cp -f $HOME/.claude/backups/settings.json.20260221-105733.bak $HOME/.claude/settings.json
```

```bash
cp -f $HOME/.claude/backups/settings.json.20260221-110129.pre-toolsearch-disable.bak $HOME/.claude/settings.json
```
