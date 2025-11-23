#!/usr/bin/env bash

dnf upgrade --refresh -y
dnf autoremove -y
dnf clean all
dnf remove $(dnf repoquery --installonly --latest-limit=-1 -q)

# Reload repository metadata
dnf makecache --refresh

echo 'potentially unneeded packages:'
dnf repoquery --installed --qf "%{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}" --unneeded

## Flatpack
# flatpak list --app
# flatpak update
