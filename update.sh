#!/usr/bin/env bash

# Update and upgrade all incl. kernel
dnf upgrade --refresh -y

# Delete orphanded packages
dnf autoremove -y

# Clean up DNF cache
dnf clean all
dnf remove $(dnf repoquery --installonly --latest-limit=-1 -q)

# Reload repository metadata
dnf makecache --refresh

# List all potentially unneeded packages.
echo 'List all potentially unneeded packages:'
dnf repoquery --installed --qf "%{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}" --unneeded
