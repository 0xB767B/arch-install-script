# Arch Installation Script

This is a set of basic scripts and template-files to install an Arch Linux
on e UEFI-system.

It first creates partitions, does basic configuration and installs the base-
system (script: arch-install-base.sh)

In a seconds step, it installs packages/applications and configures everything.

These scripts are obviously setting up a personally-configured system. Feel
free to change/modify to your needs.

## Usage

To get the scripts on your to-install computer you can either use a memory-stick
or you download it directy to your computer from github. This can be done as
follows:

```bash
# wget https://github.com/0xB767B/arch-install-script/tarball/master -O - | tar xz
```

After successfull download and extraction, change to the director 0XB767B....
and run:

```bash
# ./arch-install-base.sh
```

