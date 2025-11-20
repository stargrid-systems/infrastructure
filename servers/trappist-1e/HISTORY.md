# History

## 2025-11-19

Login as `root`.

```bash
apt update
apt upgrade -y

# Create user simon
adduser --disabled-password simon
usermod -aG sudo simon
user_home=/home/simon

# Add public key for simon
mkdir -p "$user_home/.ssh"
chown simon: "$user_home/.ssh"
chmod 700 "$user_home/.ssh"
cat >"$user_home/.ssh/authorized_keys" <<EOF
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGBjonbRt7T88d594gQJDO5qEKYd49z/uc8p+0IegXCp Triceratops
EOF
chown simon: "$user_home/.ssh/authorized_keys"
chmod 600 "$user_home/.ssh/authorized_keys"

# Add sudoers rule to allow passwordless sudo
cat >/etc/sudoers.d/99-nopasswd <<EOF
%sudo ALL=(ALL) NOPASSWD: ALL
EOF
logout
```

Login as `simon`.

```bash
# Disable root login (SSH and local)
sudo sed -i 's/^PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo systemctl reload sshd
sudo passwd -d root
sudo rm -f /root/.ssh/authorized_keys
```

```bash
# Enabled unattended upgrades
sudo apt install unattended-upgrades
sudo dpkg-reconfigure unattended-upgrades
```

```bash
# Add trappist-1e.private.stargrid.systems FQDN to /etc/hosts
sudo sed -i '/ trappist-1e$/ s/$/ trappist-1e.private.stargrid.systems/' /etc/hosts
```

```bash
# Install incus
sudo apt install -y incus
sudo usermod -aG incus-admin "$USER"
logout
```

```bash
sudo apt install dnsmasq-base ovmf qemu-system-modules-spice qemu-utils
incus admin init
```

```text
Would you like to use clustering? (yes/no) [default=no]: 
Do you want to configure a new storage pool? (yes/no) [default=yes]: 
Name of the new storage pool [default=default]: 
Name of the storage backend to use (dir, lvm, lvmcluster, btrfs) [default=btrfs]: 
Create a new BTRFS pool? (yes/no) [default=yes]: 
Would you like to use an existing empty block device (e.g. a disk or partition)? (yes/no) [default=no]: 
Size in GiB of the new loop device (1GiB minimum) [default=30GiB]: 
Would you like to create a new local network bridge? (yes/no) [default=yes]: 
What should the new bridge be called? [default=incusbr0]: 
What IPv4 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]: none
What IPv6 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]: 
Would you like the server to be available over the network? (yes/no) [default=no]: 
Would you like stale cached images to be updated automatically? (yes/no) [default=yes]: 
Would you like a YAML "init" preseed to be printed? (yes/no) [default=no]: 
```

```bash
# Enable IPv6 NDP proxying
cat <<EOF | sudo tee '/etc/sysctl.d/90-ipv6-enp9s0-proxy.conf'
net.ipv6.conf.all.proxy_ndp=1
net.ipv6.conf.all.forwarding=1
net.ipv6.conf.enp9s0.proxy_ndp=1
EOF
sudo sysctl --system
```

```bash
incus launch --vm -c limits.memory=4GB -c security.secureboot=false images:alpine/3.22 muhavura
incus config device add muhavura eth0 nic nictype=routed parent=enp9s0 ipv6.address=2a01:4f9:6a:20c9::2d3
cat <<EOF | incus config set muhavura cloud-init.network-config -
network:
    version: 2
    ethernets:
        eth0:
            addresses:
            - "2a01:4f9:6a:20c9::2d3/128"
            routes:
            - to: "default"
              via: "fe80::1"
              on-link: true
EOF
```

In the VM:

```bash
# TODO: had to get the network to actually work, FIXME
echo "nameserver 2001:4860:4860::8888" > /etc/resolv.conf

apk update
apk add docker

rc-update add docker default
service docker start

docker run \
  --init \
  --sig-proxy=false \
  --name nextcloud-aio-mastercontainer \
  --restart always \
  --publish 80:80 \
  --publish 8080:8080 \
  --publish 8443:8443 \
  --volume nextcloud_aio_mastercontainer:/mnt/docker-aio-config \
  --volume /var/run/docker.sock:/var/run/docker.sock:ro \
  ghcr.io/nextcloud-releases/all-in-one:latest
```

Okay the entire networking is kind of fucked without IPv4. Guess I'll just rent a ipv4 address specifically for the nextcloud server.
