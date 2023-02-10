#!/bin/bash
# Attempt to automate the setup of a PXE server as documented on Ubuntu Discourse forums
# https://discourse.ubuntu.com/t/netbooting-the-server-installer-on-amd64/16620

# By Chaslinux, chaslinux@gmail.com
# I use pfsense rather than dnsmasq for DNS, so skipping that section

JAMMYSERVER=jammy-live-server-amd64.iso

# Make the tftp directory to hold Ubuntu Jammy Server
sudo mkdir -p /srv/tftp/ubuntu/jammy/server

# instructions don't use sudo, how are they doing this?
# get the boot images
sudo apt install cd-boot-images-amd64
sudo ln -s /usr/share/cd-boot-images-amd64 /srv/tftp/boot-amd64

# Get Ubuntu 22.04 Jammy Server ISO
cd ~
wget http://cdimage.ubuntu.com/ubuntu-server/jammy/daily-live/current/$JAMMYSERVER
sudo mount $JAMMYSERVER /mnt
sudo cp /mnt/casper/{vmlinuz,initrd} /srv/tftp/ubuntu/jammy/server

# set up files for UEFI booting
# note: sudo doesn't appear to be needed for this first part
apt download shim-signed
dpkg-deb --fsys-tarfile shim-signed*deb | tar x ./usr/lib/shim/shimx64.efi.signed -O > bootx64.efi
sudo mv bootx64.efi /srv/tftp
apt download grub-efi-amd64-signed
dpkg-deb --fsys-tarfile grub-efi-amd64-signed*deb | tar x ./usr/lib/grub/x86_64-efi-signed/grubnetx64.efi.signed -O > grubx64.efi
sudo mv grubx64.efi /srv/tftp
apt download grub-common
dpkg-deb --fsys-tarfile grub-common*deb | tar x ./usr/share/grub/unicode.pf2 -O > unicode.pf2
sudo mv unicode.pf2 /srv/tftp
