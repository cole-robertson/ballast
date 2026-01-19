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

**Zero-config (uses smart defaults):**
```bash
sudo ballast init    # Creates 10GB ballast (or 20% of disk if smaller)
sudo ballast run     # Monitors /, drops at 90%, recovers at 70%
```

**With configuration:**
```bash
sudo ballast setup   # Interactive wizard
sudo ballast init
sudo systemctl enable --now ballast
```

## Smart Defaults

Works out of the box with no config file:

| Setting | Default | Description |
|---------|---------|-------------|
| `ballast.path` | `/var/lib/ballast/ballast.dat` | Ballast file location |
| `ballast.size_gb` | 10 | Size in GB (auto: 20% of disk, min 1GB, max 10GB) |
| `monitor.path` | `/` | Mount point to monitor |
| `monitor.interval` | 30 | Check interval in seconds |
| `monitor.threshold` | 90 | Drop ballast when disk usage >= this % |
| `monitor.recovery` | 70 | Recreate ballast when usage <= this % |
| `monitor.auto_recover` | true | Auto-recreate ballast after recovery |

Config file (`/etc/ballast.conf`) overrides defaults. Only needed for alerts or custom settings.

**Why these defaults?**
- **10GB ballast**: Enough emergency room to SSH in and clean up
- **90% drop**: Disk is nearly full, time to act
- **70% recovery**: 20% buffer prevents oscillation on small disks where ballast is a large % of disk
- **Auto-recover on**: Set-and-forget, system stays protected

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
                    Disk recovers to 70%
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
recovery = 70
auto_recover = true  # set to false for one-shot mode

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
