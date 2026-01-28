# Slack Search - Advanced Usage

## Date Search Filters

### Exact Date
query="from:me on:2026-01-27"

### Date Range
query="after:2026-01-20 before:2026-01-28"

### Relative Dates
query="after:yesterday"

## Combining Filters

query="from:me in:#engineering after:2026-01-20 keyword"

## Performance Tips

1. Limit results: Add "limit=20" in searches
2. Cache channel IDs within session
3. Use specific date ranges

## Security Best Practices

1. Never commit ~/.slack/config.json
2. Rotate tokens periodically
3. Use minimum required scopes
4. Monitor API usage
