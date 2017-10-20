#!/bin/bash

set -e

################################################################################
# Common functions
################################################################################

configure_keyboard() {
	loadkeys de_CH-latin1
}

unmount_partitions () {
# Unmount partitions if alread mounted
mounted_partitions=(`lsblk | grep "/mnt" | awk '{print $7}' | sort -r`)
	for i in ${mounted_partitions[@]}; do
		umount $i
	done
	
	swapoff -a
}

configure_mirrorlist() {
	# This step is currently not implemented since we use the default mirrorlist
	# which should be good enough
	echo "Configuration of mirrorlist not implemented yet."
}

create_partitions() {
	# Create partitions 
	# Here we create three partitions:
	#  200 MB for UEFI
	# 8192 MB for Swap
	# Rest for root
	# todo: use variable for device!
	sgdisk -n 0:0:+200M -t 0:ef00 -c 0:"EFIBOOT" /dev/sda
	sgdisk -n 0:0:+1G -t 0:8200 -c 0:"SWAP" /dev/sda
	sgdisk -n 0:0:0 -t 0:8300 -c 0:"ROOT" /dev/sda
}

format_partitions() {
	# Format partitions
	mkfs.fat -F 32 -n "EFIBOOT" /dev/sda1
	mkswap -L SWAP /dev/sda2
	mkfs.ext4 -L ROOT /dev/sda3
}

mount_partitions() {
	# Mount partitions
	mount -L ROOT /mnt
	mkdir -p /mnt/boot
	mount -L EFIBOOT /mnt/boot
	swapon -L SWAP
}

install_system() {
	pacstrap /mnt base base-devel efibootmgr dosfstools gptfdisk
}

generate_fstab() {
	genfstab -U /mnt >> /mnt/etc/fstab
}

arch_chroot() {
	arch-chroot /mnt /bin/bash -c "${1}"
}

set_timezone() {
	arch_chroot "ln -sf /usr/share/zoneinfo/Europe/Zurich /etc/localtime"
}

generate_adjtime() {
	cp ./files/etc/locale.gen /mnt/etc/
	arch_chroot "locale-gen"
	cp ./files/etc/locale.conf /mnt/etc
}

set_keyboard_layout() {
	cp ./files/etc/vconsole.conf /mnt/etc
}

configure_hostname() {
	cp ./files/etc/hostname /mnt/etc/
}

configure_hosts() {
	cp ./files/etc/hosts /mnt/etc
}

create_initramfs() {
	arch_chroot "mkinitcpio -p linux"
}

set_root_password() {
	# todo
	echo "Setting of root password not implemented yet."
}

install_bootloader() {
	arch_chroot "bootctl install"
	cp ./files/boot/loader/entries/arch-uefi.conf /mnt/boot/loader/entries
	cp ./files/boot/loader/entries/arch-uefi-fallback.conf /mnt/boot/loader/entries
	cp ./files/boot/loader/loader.conf /mnt/boot/loader
}

installation_finished() {
	echo "It is now time for reboot"
	echo "Type reboot"
}

################################################################################
# Basic setup
################################################################################

configure_keyboard
unmount_partitions
configure_mirrorlist
create_partitions
format_partitions
mount_partitions
install_system
generate_fstab

################################################################################
# Basic setup in chroot
################################################################################

set_timezone
generate_adjtime
set_keyboard_layout
configure_hostname
configure_hosts
create_initramfs
set_root_password
install_bootloader
unmount_partitions
installation_finished

