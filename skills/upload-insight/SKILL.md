---
name: upload-insight
description: Upload a Claude Code insight, trap or lesson learned to the team shared knowledge base. Trigger when user says "I hit a trap", "I discovered this works better", "share my finding", "记录这个坑", "分享心得", "我发现", "踩坑了"
---

# Upload Insight

Capture and share a Claude Code insight with teammates.

## Usage

When user says something like:
- "I hit a trap when using Tool X"
- "I discovered this works better than that"
- "记录这个坑：..."
- "分享心得：..."
- "我发现..."

## Process

1. **Extract the insight** from user's message:
   - `name`: Short descriptive title
   - `when_to_use`: Situation/context when this applies
   - `description`: What to do or avoid
   - `uploader`: Current user (from `whoami`)
   - `uploader_ip`: Host IP (from `hostname -I`)

2. **Generate content hash**:
   ```bash
   CONTENT_HASH=$(echo "${NAME}${WHEN}${DESC}" | sha256sum | awk '{print $1}')
   ```

3. **Generate raw hash** for original content:
   ```bash
   RAW_HASH=$(echo "${ORIGINAL_MESSAGE}" | sha256sum | awk '{print $1}')
   ```

4. **Create entry JSON**:
   ```json
   {
     "name": "Insight name",
     "uploader": "username",
     "uploader_ip": "192.168.1.x",
     "when_to_use": "Python TDD with mocks",
     "description": "Don't import production code in tests",
     "content_hash": "abc123...",
     "raw_hashes": ["raw1", "raw2"],
     "created_at": "2026-04-27T10:00:00Z"
   }
   ```

5. **Save raw content** to `~/.claude-team/insights/raw/${RAW_HASH}.json`

6. **Update index**:
   ```bash
   bash ~/.claude-team/scripts/generate-index.sh '${ENTRY_JSON}'
   ```

7. **Push to teammates**:
   ```bash
   bash ~/.claude-team/scripts/rsync-push.sh
   ```

## Index Location

- Main index: `~/.claude-team/insights/index.json`
- Raw content: `~/.claude-team/insights/raw/${RAW_HASH}.json`
- Peers config: `~/.claude-team/config/teammates.json`
