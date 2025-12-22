# Infrastructure

## Domains

### `stargrid.systems`

Registered and managed via [Cloudflare](https://cloudflare.com).

Email server is [Purelymail](https://purelymail.com).
It's cheap and we only really need it for sending emails from various services.

### `stargrid-modules.de`

Registered via [Hetzner's Domain Registration Robot](https://docs.hetzner.com/robot/domain-registration-robot) and managed via [Cloudflare](https://cloudflare.com).

## Servers

### `trappist-1e.private.stargrid.systems`

Hosts Nextcloud AIO instance.

#### Manual setup

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

# Disable Skeleton directory
$occ config:system:set skeletondirectory --value ''

$occ maintenance:repair
$occ maintenance:mode --off
```

#### Adding mail accounts

```bash
APP_CODE='<SNIP>' ACCOUNT='<SNIP>' USERNAME='<SNIP>' NAME='<SNIP>'; \
$occ mail:account:create "$ACCOUNT" "$NAME" "${USERNAME}@stargrid.systems" \
    'imap.purelymail.com' '993' 'ssl' "${USERNAME}@stargrid.systems" "$APP_CODE" \
    'smtp.purelymail.com' '587' 'tls' "${USERNAME}@stargrid.systems" "$APP_CODE" \
    'password'
```

## License

This repository is licensed under GNU Affero General Public License v3.0 or later (AGPL-3.0-or-later).
See the [LICENSE](LICENSE) file for details.
