---
name: sync-insights
description: Sync insights with LAN teammates. Trigger when user says "sync with teammates", "pull insights", "push insights", "同步心得", "拉取队友", "同步"
---

# Sync Insights

Synchronize insights with teammates on the LAN.

## Usage

When user says:
- "sync with teammates"
- "pull insights"
- "push insights"
- "同步心得"
- "拉取队友"

## Two Types of Sync

### Pull (Get teammates' insights)
```bash
bash ~/.claude-team/scripts/rsync-pull.sh
```
- Downloads each teammate's `index.json` to `~/.claude-team/cache/peer-indexes/`
- Does NOT auto-merge (user reviews first)
- To view peer indexes: `cat ~/.claude-team/cache/peer-indexes/*.index.json`

### Push (Share your insights)
```bash
bash ~/.claude-team/scripts/rsync-push.sh
```
- Uploads local `insights/` to all teammates
- Runs automatically after upload-insight or digest-insights

## Teammate Configuration

Edit `~/.claude-team/config/teammates.json`:
```json
{
  "teammates": [
    { "name": "Alice", "ip": "192.168.1.101" },
    { "name": "Bob", "ip": "192.168.1.102" }
  ]
}
```

## Merge Strategy

When pulling, if same `content_hash` exists locally:
- Keep both entries (different `raw_hashes` indicate different solutions)
- User can manually deduplicate by editing `index.json`

## Notes

- rsync uses `~/.ssh/config` for key-based auth
- Timeout: 30 seconds per peer
- Silent on success, verbose on error
