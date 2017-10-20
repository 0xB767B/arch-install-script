#!/bin/bash

set -e

################################################################################
# Common functions
################################################################################
arch_chroot() {
	arch-chroot /mnt /bin/bash -c "${1}"
}

################################################################################
# Basic setup
################################################################################

# Set keyboard layout
loadkeys de_CH-latin1

# Install vim just in case we have to configure something during installation
#pacman -S --noconfirm --needed vim git

# Configure mirrorlist
# This step is currently not implemented since we use the default mirrorlist
# which should be good enough

# Unmount partitions if alread mounted
mounted_partitions=(`lsblk | grep "/mnt" | awk '{print $7}' | sort -r`)
for i in ${mounted_partitions[@]}; do
	umount $i
done

swapoff -a

# Create partitions 
# Here we create three partitions:
#  200 MB for UEFI
# 8192 MB for Swap
# Rest for root
# todo: use variable for device!
sgdisk -n 0:0:+200M -t 0:ef00 -c 0:"EFIBOOT" /dev/sda
sgdisk -n 0:0:+1G -t 0:8200 -c 0:"SWAP" /dev/sda
sgdisk -n 0:0:0 -t 0:8300 -c 0:"ROOT" /dev/sda

# Format partitions
mkfs.fat -F 32 -n "EFIBOOT" /dev/sda1
mkswap -L SWAP /dev/sda2
mkfs.ext4 -L ROOT /dev/sda3

# Mount partitions
mount -L ROOT /mnt
mkdir -p /mnt/boot
mount -L EFIBOOT /mnt/boot
swapon -L SWAP

# Install system
pacstrap /mnt base base-devel efibootmgr dosfstools gptfdisk

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

################################################################################
# Basic setup in chroot
################################################################################

# Set timezone
arch_chroot "ln -sf /usr/share/zoneinfo/Europe/Zurich /etc/localtime"

# Run hwclock to generate /etc/adjtime
arch_chroot "hwclock --systohc"

# Locale
cp locale.gen /mnt/etc/
arch_chroot "locale-gen"
cp locale.conf /mnt/etc

# Set keyboard layout
cp vconsole.conf /mnt/etc

# Hostname
cp hostname /mnt/etc/
cp hosts /mnt/etc

# Create initramfs
arch_chroot "mkinitcpio -p linux"

# Password for root
# todo

# Install bootloader
arch_chroot "bootctl install"
cp arch-uefi.conf /mnt/boot/loader/entries
cp arch-uefi-fallback.conf /mnt/boot/loader/entries
cp loader.conf /mnt/boot/loader

# Unmount partitions
mounted_partitions=(`lsblk | grep "/mnt" | awk '{print $7}' | sort -r`)
for i in ${mounted_partitions[@]}; do
	umount $i
done

swapoff -a

echo "It is now time for reboot"
echo "Type reboot"

