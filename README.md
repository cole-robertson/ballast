# Ballast

A dead-simple disk space emergency release system. ~300 lines of bash.

**What it does:** Pre-allocates disk space via a "ballast" file. When your disk fills up, it drops the ballast to buy you time and alerts your team.

## Install

```bash
curl -sSL https://raw.githubusercontent.com/cole-robertson/ballast/master/install.sh | sudo bash
```

That's it. Works immediately with smart defaults.

## Quick Start

```bash
# Zero config - just works
sudo ballast init    # Creates 10GB ballast
sudo ballast run     # Monitors disk, alerts when needed

# Or use systemd
sudo systemctl enable --now ballast
```

## How It Works

```
┌─────────────────────────────────────────────────────────────────┐
│                         NORMAL STATE                            │
│  Ballast file exists (10GB reserved)                            │
└─────────────────────────────────────────────────────────────────┘
                              │
                    Free space drops below 15GB
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                        EMERGENCY                                │
│  Ballast dropped → 10GB freed → Alert sent → You have time      │
└─────────────────────────────────────────────────────────────────┘
                              │
                    Free space recovers above 30GB
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                         RECOVERED                               │
│  Ballast recreated → Alert sent → Back to normal                │
└─────────────────────────────────────────────────────────────────┘
```

## Smart Defaults

Works out of the box with **no config file**:

| Setting | Default | What it means |
|---------|---------|---------------|
| Ballast size | 10GB | Your emergency reserve (capped at 20% of disk) |
| Drop threshold | 1.5x ballast | Drop when < 15GB free |
| Recover threshold | 3.0x ballast | Recover when > 30GB free |
| Check interval | 30 seconds | How often to check disk |
| Auto-recover | true | Automatically recreate ballast |

**Why these multipliers?**

- **1.5x drop**: Triggers before disk is critically full. At 15GB free, you have breathing room.
- **3.0x recover**: Ensures no oscillation. After recreating 10GB ballast from 30GB free, you still have 20GB (above the 15GB drop threshold).

**The math:** `recover_buffer > drop_buffer + 1` prevents oscillation.

## Commands

```bash
ballast init     # Create the ballast file
ballast status   # Show disk and ballast state
ballast run      # Start the monitoring daemon
ballast drop     # Manually drop ballast (emergency)
ballast setup    # Interactive configuration wizard
ballast help     # Print help
```

## Configuration

Config file is **optional**. Only needed for alerts or custom settings.

Location: `/etc/ballast.conf`

```ini
[ballast]
path = /var/lib/ballast/ballast.dat
size_gb = 10

[monitor]
path = /
interval = 30
# Thresholds are multipliers of ballast size
drop_buffer = 1.5      # drop when free < 15GB (1.5 × 10GB)
recover_buffer = 3.0   # recover when free > 30GB (3.0 × 10GB)
auto_recover = true

[discord]
enabled = true
webhook = https://discord.com/api/webhooks/XXX/YYY

[slack]
enabled = false
webhook = https://hooks.slack.com/services/XXX/YYY/ZZZ

[email]
enabled = false
smtp = smtps://smtp.gmail.com:465
user = alerts@example.com
pass = app-password
from = alerts@example.com
to = ops@example.com

[webhook]
enabled = false
url = https://example.com/webhook
method = POST
```

Run `ballast setup` for an interactive wizard.

## Alert Examples

**Discord/Slack:**
> ALERT: Disk on myserver low (12GB free). Ballast dropped to free 10GB.

> OK: Disk on myserver recovered (35GB free). Ballast recreated.

**Webhook JSON:**
```json
{
  "event": "dropped",
  "free_gb": 22,
  "hostname": "myserver",
  "message": "ALERT: Disk on myserver low (12GB free). Ballast dropped to free 10GB."
}
```

## Manual Override

Auto-recovery too conservative? You can always manually recreate:

```bash
sudo ballast init
```

This works regardless of thresholds.

## Uninstall

```bash
curl -sSL https://raw.githubusercontent.com/cole-robertson/ballast/master/uninstall.sh | sudo bash
```

Prompts before removing config and data.

## Requirements

- Linux (uses `fallocate` or `truncate`)
- bash, curl, df, bc (standard on any Linux)

## License

MIT
