# Ballast

Dead-simple disk space emergency release. ~250 lines of bash.

Pre-allocates disk space. When disk fills up, drops it to buy you time and alerts your team.

## Install

```bash
curl -sSL https://raw.githubusercontent.com/cole-robertson/ballast/master/install.sh | sudo bash
```

## Usage

```bash
sudo ballast init     # Create 10GB ballast file
sudo ballast status   # Check disk and ballast state
sudo ballast run      # Start daemon (or use systemd)
sudo ballast drop     # Emergency manual drop
```

## How It Works

```
Normal:     10GB ballast file reserves space
               ↓
Disk fills: Free space < 15GB → drop ballast → alert sent → 10GB freed
               ↓
Recovery:   Free space > 30GB → recreate ballast → alert sent
```

## Defaults

Works with **zero config**:

| Setting | Default |
|---------|---------|
| Ballast | 10GB (capped at 20% of disk) |
| Drop | when free < 15GB (1.5× ballast) |
| Recover | when free > 30GB (3× ballast) |

## Configuration

Only needed for alerts. Edit `/etc/ballast.conf`:

```ini
[discord]
enabled = true
webhook = https://discord.com/api/webhooks/XXX/YYY

[slack]
enabled = true
webhook = https://hooks.slack.com/services/XXX/YYY/ZZZ

[webhook]
enabled = true
url = https://example.com/hook
```

Then restart: `sudo systemctl restart ballast`

## Uninstall

```bash
curl -sSL https://raw.githubusercontent.com/cole-robertson/ballast/master/uninstall.sh | sudo bash
```

## License

MIT
