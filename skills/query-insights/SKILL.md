---
name: query-insights
description: Query the team insights database for relevant lessons. Trigger when user asks about a problem, says "any insights on X?", "what traps exist for Y?", "X 有什么坑", "帮我查一下"
---

# Query Insights

Search team insights database for relevant lessons and traps.

## Usage

When user says:
- "any insights on Python TDD?"
- "what traps exist for React hooks?"
- "X 有什么坑"
- "帮我查一下..."
- "is there a trap for using Claude Code with..."

## How It Works

1. User prompt is captured by `UserPromptSubmit` hook
2. `query-insights.sh` searches `index.json` for matches
3. Matches are displayed inline

## Search Logic

Searches three fields:
- `when_to_use`: Situation/context
- `description`: What to do/avoid
- `name`: Insight name

Uses case-insensitive substring match.

## Output Format

```
📚 Relevant Insights:

### Don't mock database in integration tests
**When:** Integration tests with real DB
**Uploader:** alice @ 192.168.1.101
**Description:** Mocks passed but prod migration failed. Always use real DB for integration tests.
---
```

## Cache

Results are cached in `~/.claude-team/cache/query_cache.json` to avoid repeated searches.

Clear cache: `rm ~/.claude-team/cache/query_cache.json`

## Manual Query

```bash
# Search for "Python" insights
jq -r '.[] | select(.when_to_use | test("Python"; "i"))' ~/.claude-team/insights/index.json

# Search for "rate limit" insights
jq -r '.[] | select(.description | test("rate limit"; "i"))' ~/.claude-team/insights/index.json
```
