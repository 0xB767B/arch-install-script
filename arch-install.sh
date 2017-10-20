#!/bin/bash

set -e

setup_network_connection() {
	WIRED_DEV=`ip link | grep "ens\|eno\|enp" | awk '{print $2}'| sed 's/://' | sed '1!d'`
	WIRELESS_DEV=`ip link | grep wlp | awk '{print $2}'| sed 's/://' | sed '1!d'`

	# Just DHCP supported for now
	systemctl start dhcpcd@${WIRED_DEV}.service

	# todo wireless!
}

package_install() {
}

################################################################################
# Basic packages
################################################################################

echo "Install basic packages..."
pacman -S --noconfirm --needed bc rsync mlocate bash-completion arch-wiki-lite
pacman -S --noconfirm --needed zip unzip unrar p7zip lzop cpio

