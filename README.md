# A collection of simple tools and scripts for Cloudflare

## Dynamic DNS

Mimic's a DDNS by updating a type A DNS Record in Cloudflare.

I run this script on a Raspberry Pi Zero on an hourly basis.

### Requirements

```bash
# Your account email:
export CLOUDFLARE_AUTH_EMAIL="<ACCOUNT_EMAIL>"
# API Key provided by Cloudflare. You can use the one available in the main dashbaord.
export CLOUDFLARE_AUTH_KEY="<API_KEY>"
```

### Crontab

You can set your `cron` to run the script hourly:

```bash
sudo crontab -e

# crontab 

# m h  dom mon dow   command
0 * * * * <PATH_TO_SCRIPT>/cloudflare-ddns.sh CLOUDFLARE_ZONE DNS_RECORD >> <PATH_TO_LOG_FILE> 2>&1
```