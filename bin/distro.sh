#!/bin/bash

echo "$(date +"[%b %d %H:%M:%S]#") $(basename "$0") $@" | sudo tee -a "/var/log/go/$(basename "$0").log" >/dev/null

# rclone copy backup:distro/ /var/lib/vz/template/cache/

cd /var/lib/vz/template/cache

echo "[1]"
sudo wget https://distro.d7l8.c12.e2-5.dev/almalinux-8.tar.zst
echo "[2]"
sudo wget https://distro.d7l8.c12.e2-5.dev/almalinux-9.2.tar.zst
echo "[3]"
sudo wget https://distro.d7l8.c12.e2-5.dev/archlinux.tar.zst
echo "[4]"
sudo wget https://distro.d7l8.c12.e2-5.dev/centos-8.5.tar.zst
echo "[5]"
sudo wget https://distro.d7l8.c12.e2-5.dev/centos-7.tar.zst
echo "[6]"
sudo wget https://distro.d7l8.c12.e2-5.dev/centos-stream-9.tar.zst
echo "[7]"
sudo wget https://distro.d7l8.c12.e2-5.dev/debian-10.tar.zst
echo "[8]"
sudo wget https://distro.d7l8.c12.e2-5.dev/debian-11.tar.zst
echo "[9]"
sudo wget https://distro.d7l8.c12.e2-5.dev/debian-11-xrdp.tar.zst
echo "[10]"
sudo wget https://distro.d7l8.c12.e2-5.dev/debian-12.tar.zst
echo "[11]"
sudo wget https://distro.d7l8.c12.e2-5.dev/fedora-37.tar.zst
echo "[12]"
sudo wget https://distro.d7l8.c12.e2-5.dev/fedora-38.tar.zst
echo "[13]"
sudo wget https://distro.d7l8.c12.e2-5.dev/opensuse-15.4.tar.zst
echo "[14]"
sudo wget https://distro.d7l8.c12.e2-5.dev/rockylinux-8.tar.zst
echo "[15]"
sudo wget https://distro.d7l8.c12.e2-5.dev/rockylinux-9.tar.zst
echo "[16]"
sudo wget https://distro.d7l8.c12.e2-5.dev/ubuntu-18.04.tar.zst
echo "[17]"
sudo wget https://distro.d7l8.c12.e2-5.dev/ubuntu-20.04.tar.zst
echo "[18]"
sudo wget https://distro.d7l8.c12.e2-5.dev/ubuntu-22.04.tar.zst
echo "[19]"
sudo wget https://distro.d7l8.c12.e2-5.dev/ubuntu-22.10.tar.zst
echo "[20]"
sudo wget https://distro.d7l8.c12.e2-5.dev/ubuntu-23.04.tar.zst
echo "[21]"
sudo wget https://distro.d7l8.c12.e2-5.dev/almalinux-9-go.tar.zst
echo "[22]"
sudo wget https://distro.d7l8.c12.e2-5.dev/almalinux-8-cpanel.tar.zst

echo "[23]"
# NethServer 7.9
sudo wget https://distro.d7l8.c12.e2-5.dev/vzdump-qemu-100-2023_08_28-04_48_32.vma.zst

echo "[24]"
# CentOS 7.9 (KVM)
sudo wget https://distro.d7l8.c12.e2-5.dev/vzdump-qemu-111-2023_08_22-04_32_14.vma.zst

echo "[25]"
# AlmaLinix 8 (KVM)
sudo wget https://distro.d7l8.c12.e2-5.dev/vzdump-qemu-100-2023_08_27-16_27_07.vma.zst

echo "[26]"
# AlmaLinix 8 (KVM GPT)
sudo wget https://distro.d7l8.c12.e2-5.dev/vzdump-qemu-100-2023_12_25-00_59_07.vma.zst

echo "[27]"
# Rocky Linix 8 (KVM)
sudo wget https://distro.d7l8.c12.e2-5.dev/vzdump-qemu-100-2023_08_30-08_09_55.vma.zst

echo "[28]"
# Debian 11 (KVM)
sudo wget https://distro.d7l8.c12.e2-5.dev/vzdump-qemu-100-2023_08_26-17_39_28.vma.zst

echo "[29]"
# Debian 12 (KVM GPT)
sudo wget https://distro.d7l8.c12.e2-5.dev/vzdump-qemu-100-2023_10_03-05_38_22.vma.zst

echo "[30]"
# Oracle Linux 8 (KVM)
sudo wget https://distro.d7l8.c12.e2-5.dev/vzdump-qemu-100-2023_08_30-03_44_02.vma.zst

echo "[31]"
# Windows 2016
sudo wget https://distro.d7l8.c12.e2-5.dev/vzdump-qemu-100-2023_09_01-00_27_23.vma.zst

echo "[32]"
# Windows Server 2019 Datacenter
sudo wget https://distro.d7l8.c12.e2-5.dev/vzdump-qemu-102-2023_10_16-10_02_27.vma.zst

echo "[33]"
# Windows 7
sudo wget https://distro.d7l8.c12.e2-5.dev/vzdump-qemu-100-2023_12_08-03_42_07.vma.zst

echo "[34]"
# Windows 10
sudo wget https://distro.d7l8.c12.e2-5.dev/vzdump-qemu-100-2023_12_09-15_32_24.vma.zst

echo "[33]"
# VICIBOX
sudo wget https://distro.d7l8.c12.e2-5.dev/vzdump-qemu-100-2023_09_28-17_33_09.vma.zst

# ISO
# cd /var/lib/vz/template/iso
# URL="https://windows.d7l8.c12.e2-5.dev"
# wget https://distro.d7l8.c12.e2-5.dev/windows-server-2019.iso
# wget https://distro.d7l8.c12.e2-5.dev/windows-server-2016.iso
# wget https://distro.d7l8.c12.e2-5.dev/en_windows_7_ultimate_x64_dvd.iso
# wget https://distro.d7l8.c12.e2-5.dev/Win10Pro.iso

# Debian 12
# https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.1.0-amd64-netinst.iso
