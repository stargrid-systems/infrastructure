# Infrastructure

## Domains

### `stargrid.systems`

Registered and managed via [Cloudflare](https://cloudflare.com).

Email server is [Purelymail](https://purelymail.com).
It's cheap and we only really need it for sending emails from various services.

## Servers

### `trappist-1e.private.stargrid.systems`

Hosts Nextcloud AIO instance.

#### Manual Setup

The first setup of Nextcloud AIO requires some manual steps (This should only be required once).
After setting completing the AIO setup, there were some additional config steps on the machine via
SSH.
The firewall is configures to forbid SSH. SSH connections must be manually allowed in the firewall
for the duration of the setup.
This is done through the Hetzner Cloud Console.

```bash
occ='docker exec --user www-data nextcloud-aio-nextcloud php occ'

$occ maintenance:mode --on

# Set default phone region to get rid of the warning.
$occ config:system:set default_phone_region --value="CH"
# Run expensive maintenance repair to update mime database.
$occ maintenance:repair --include-expensive

# Enable S3 object storage
$occ config:system:set objectstore class --value 'OC\Files\ObjectStore\S3'
# $occ config:system:set objectstore arguments autocreate --value true --type bool
# $occ config:system:set objectstore arguments use_path_style --value true --type bool
$occ config:system:set objectstore arguments bucket --value '7fffb1c79408'
$occ config:system:set objectstore arguments hostname --value 'nbg1.your-objectstorage.com'
$occ config:system:set objectstore arguments region --value 'nbg1'
# Credentials
$occ config:system:set objectstore arguments key --value '<snip>'
$occ config:system:set objectstore arguments secret --value '<snip>'

$occ maintenance:repair
$occ maintenance:mode --off
```

## License

This repository is licensed under GNU Affero General Public License v3.0 or later (AGPL-3.0-or-later).
See the [LICENSE](LICENSE) file for details.
