# History

## 2025-11-17

Add `simon` to `sudo` and `docker` groups.

```bash
sudo apt install docker.io
```

Add sudoers rule to allow passwordless sudo:

```bash
$ cat /etc/sudoers.d/99-nopasswd
%sudo ALL=(ALL) NOPASSWD: ALL
```

## 2025-11-16

Add new user: `simon`.

```bash
apt install unattended-upgrades

dpkg-reconfigure unattended-upgrades
# Enabled unattended upgrades
```
