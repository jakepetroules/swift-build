#!/bin/bash
set -e

if command -v apt-get >/dev/null 2>&1 ; then # bookworm, noble, jammy
    export DEBIAN_FRONTEND=noninteractive

    apt-get update -y

    # Build dependencies
    apt-get install -y libsqlite3-dev libncurses-dev

    # Debug symbols
    apt-get install -y libc6-dbg

    # Android NDK
    dpkg_architecture="$(dpkg --print-architecture)"
    if [[ "$dpkg_architecture" == amd64 ]] ; then
        eval "$(cat /etc/lsb-release)"
        case "$DISTRIB_CODENAME" in
            bookworm|jammy)
                : # Not available
                ;;
            noble)
                apt-get install -y google-android-ndk-r26c-installer
                ;;
            *)
                echo "Unknown distribution: $DISTRIB_CODENAME" >&2
                exit 1
        esac
    else
        echo "Skipping Android NDK installation on $dpkg_architecture" >&2
    fi
elif command -v dnf >/dev/null 2>&1 ; then # rhel-ubi9
    dnf update -y

    # Build dependencies
    dnf install -y sqlite-devel ncurses-devel

    # Debug symbols
    dnf debuginfo-install -y glibc
elif command -v yum >/dev/null 2>&1 ; then # amazonlinux2
    yum update -y

    # Build dependencies
    yum install -y sqlite-devel ncurses-devel

    # Debug symbols
    yum install -y yum-utils
    debuginfo-install -y glibc
fi
