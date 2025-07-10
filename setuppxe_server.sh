#!/bin/bash

set -e

echo "[+] Installing PXE server packages..."
sudo apt update
sudo apt install -y dnsmasq syslinux-common pxelinux syslinux pxelinux

echo "[+] Creating TFTP root directory at /srv/tftp..."
sudo mkdir -p /srv/tftp/pxelinux.cfg

echo "[+] Copying PXE bootloader files..."
sudo cp /usr/lib/PXELINUX/pxelinux.0 /srv/tftp/
sudo cp /usr/lib/syslinux/modules/bios/* /srv/tftp/
sudo cp /usr/lib/syslinux/memdisk /srv/tftp/
sudo cp /usr/lib/syslinux/menu.c32 /srv/tftp/
sudo cp /usr/lib/syslinux/vesamenu.c32 /srv/tftp/

echo "[+] Creating default PXE menu config..."
cat <<EOF | sudo tee /srv/tftp/pxelinux.cfg/default > /dev/null
DEFAULT menu.c32
PROMPT 0
TIMEOUT 50
ONTIMEOUT WinPE

MENU TITLE PXE Boot Menu

LABEL WinPE
  MENU LABEL WinPE Hardware Test
  KERNEL memdisk
  INITRD WinPE_HardwareTest.iso
  APPEND iso raw

LABEL LinuxDiag
  MENU LABEL Linux Diagnostics
  KERNEL linux
  INITRD initrd.img
  APPEND root=/dev/ram0 ramdisk_size=1500000

LABEL Local
  MENU LABEL Boot from local disk
  LOCALBOOT 0
EOF

echo "[+] Creating basic dnsmasq config..."
cat <<EOF | sudo tee /etc/dnsmasq.d/pxe.conf > /dev/null
port=0
interface=eth0
dhcp-range=192.168.1.100,192.168.1.200,12h
enable-tftp
tftp-root=/srv/tftp
dhcp-boot=pxelinux.0
pxe-service=x86PC, "PXE Boot", pxelinux
EOF

echo "[+] Restarting dnsmasq service..."
sudo systemctl restart dnsmasq

echo "[✔] PXE server setup complete!"
echo "➡ Place your ISO or Linux kernel/initrd files into /srv/tftp/"