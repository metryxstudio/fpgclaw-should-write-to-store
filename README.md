# FPGCLAW - Should Write to Store

A server-side Google Tag Manager variable template that determines whether an FPGCLAW cookie value should be written to a key-value store (Firestore, Redis, Stape Store, etc.).

## Overview

This variable returns `true` only when all conditions are met:
- A valid FPGCLAW value exists in event data
- The gclid is new (different from stored value) or no stored value exists
- The FPGCLAW is within the configured maximum age limit

Use this template to prevent unnecessary write operations and avoid resetting TTL on existing values.

## Installation

1. In your server-side GTM container, go to **Templates** → **Variable Templates** → **Search Gallery**
2. Search for "FPGCLAW - Should Write to Store"
3. Click **Add to workspace**

## Configuration

| Field | Description |
|-------|-------------|
| **Current FPGCLAW (from Event Data)** | Variable that reads `custom_fpgclaw` directly from event data |
| **Stored FPGCLAW (from Store)** | Variable that reads FPGCLAW from your key-value store |
| **Max FPGCLAW Age** | Maximum age limit: No limit, 30/60/90 days, or Custom |
| **Custom Max Age (days)** | Number of days (only visible when "Custom" is selected) |

## FPGCLAW Format

The template parses FPGCLAW values in this format:
```
2.1.k{gclid}$i{timestamp}
```

Example: `2.1.kCj0KCQiA...TEST$i1767170762`

- `k` prefix indicates the gclid payload
- `$i` prefix indicates the Unix timestamp (seconds)

## Usage Example

1. Create a variable using this template
2. Configure inputs:
   - Current FPGCLAW: `{{Event Data - custom_fpgclaw}}`
   - Stored FPGCLAW: `{{Your Store Variable - FPGCLAW}}` (Firestore, Redis, Stape Store, etc.)
   - Max Age: Select desired limit
3. Use as a trigger condition for your Store Write tag:
   - Condition: `{{FPGCLAW - Should Write to Store}}` equals `true`

## Logic Flow

```
1. If no current FPGCLAW → return false
2. If max age is set and FPGCLAW is too old → return false
3. If no stored FPGCLAW → return true (first time)
4. If current gclid ≠ stored gclid → return true (new click)
5. Otherwise → return false (same gclid, no write needed)
```

## Author

**Metryx Studio**  
Website: [metryx.studio](https://metryx.studio)  
Contact: filip@metryx.studio

## License

Apache License 2.0
