# Ballast

A dead-simple disk space emergency release system. ~200 lines of bash.

**What it does:** Pre-allocates disk space via a "ballast" file. When your disk fills up, it drops the ballast to buy you time and alerts your team.

## Install

```bash
curl -sSL https://raw.githubusercontent.com/cole-robertson/ballast/master/install.sh | sudo bash
```

Or manually:
```bash
sudo curl -o /usr/local/bin/ballast https://raw.githubusercontent.com/cole-robertson/ballast/master/ballast
sudo chmod +x /usr/local/bin/ballast
```

## Quick Start

```bash
# Interactive setup
sudo ballast setup

# Create the ballast file
sudo ballast init

# Run daemon
sudo ballast run

# Or use systemd
sudo systemctl enable --now ballast
```

## How It Works

```
┌─────────────────────────────────────────────────────────────────┐
│                         NORMAL STATE                            │
│  Ballast file exists (10GB) → Disk has emergency reserve        │
└─────────────────────────────────────────────────────────────────┘
                              │
                    Disk fills to 90%
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                        EMERGENCY                                │
│  Ballast dropped → 10GB freed → Alert sent → You have time      │
└─────────────────────────────────────────────────────────────────┘
                              │
                    Disk recovers to 80%
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                         RECOVERED                               │
│  Ballast recreated → Alert sent → Back to normal                │
└─────────────────────────────────────────────────────────────────┘
```

## Commands

```bash
ballast setup    # Interactive configuration wizard
ballast init     # Create the ballast file
ballast status   # Show disk usage and ballast state
ballast run      # Start the monitoring daemon
ballast drop     # Manually drop ballast (emergency)
ballast version  # Print version
ballast help     # Print help
```

## Configuration

Config file: `/etc/ballast.conf`

```ini
[ballast]
path = /var/lib/ballast/ballast.dat
size_gb = 10

[monitor]
path = /
interval = 30
threshold = 90
recovery = 80

[slack]
enabled = true
webhook = https://hooks.slack.com/services/XXX/YYY/ZZZ

[discord]
enabled = false
webhook =

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

## Alert Examples

**Slack/Discord:**
> ALERT: Disk usage at 92% on myserver. Ballast file dropped to free 10GB.

**Webhook JSON:**
```json
{
  "event": "dropped",
  "usage_percent": 92,
  "hostname": "myserver",
  "message": "ALERT: Disk usage at 92% on myserver. Ballast file dropped to free 10GB."
}
```

## Requirements

- Linux (uses `fallocate` or `truncate`)
- bash, curl, df, stat (standard on any Linux)

## License

MIT
