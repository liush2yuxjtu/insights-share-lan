---
name: digest-insights
description: Run Haiku to automatically digest recent Claude Code session logs into team insights. Trigger when user says "digest my sessions", "run nightly digest", "生成今日心得", "digest", "自动分析"
---

# Digest Insights

Automatically extract insights from recent Claude Code session logs using Haiku.

## Usage

When user says:
- "digest my sessions"
- "run nightly digest"
- "生成今日心得"
- "digest"

## Process

1. **Check if digest should run**:
   - Last run timestamp in `~/.claude-team/.last_digest_run`
   - Interval: 24 hours (86400 seconds)

2. **Find recent jsonl files**:
   ```bash
   find ~/.claude/projects -name "*.jsonl" -type f -mtime -1
   ```

3. **For each jsonl file**, use Haiku to extract insights:
   ```
   Model: claude-haiku-4-20250514
   Max tokens: 300
   Prompt: Extract 1-3 actionable insights/traps from this session log
   Output format: JSON array of {name, when_to_use, description}
   ```

4. **Generate hashes and update index** (same as upload-insight)

5. **Save hourly snapshot**:
   ```bash
   cp ~/.claude-team/insights/index.json ~/.claude-team/insights/index-hourly/index-$(date +%Y%m%d%H).json
   ```

6. **Push to teammates**

## Cron Setup (Midnight Auto-Run)

Add to crontab:
```bash
0 0 * * * bash ~/.claude-team/scripts/haiku-digest.sh
```

## Requirements

- `ANTHROPIC_API_KEY` environment variable set
- `jq`, `curl`, `sha256sum` installed
