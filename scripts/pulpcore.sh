#!/bin/bash

echo "
[powertools]
name=AlmaLinux \$releasever - BaseOS
# mirrorlist=https://mirrors.almalinux.org/mirrorlist/\$releasever/baseos
baseurl=https://repo.almalinux.org/almalinux/8/PowerTools/x86_64/os/
enabled=1
gpgcheck=1
countme=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-AlmaLinux
" > /etc/yum.repos.d/almalinux-powertools.repo

dnf update -y
dnf install -y epel-release

export LC_ALL="C"
export LC_CTYPE="C"

dnf install -y python38

dnf install -y gcc make cmake bzip2-devel expat-devel file-devel glib2-devel libcurl-devel libmodulemd-devel ninja-build libxml2-devel python38-devel python3-gobject rpm-devel openssl-devel sqlite-devel xz-devel zchunk-devel zlib-devel #dependencies pulp_rpm according to the wiki

pip3 install pulpcore pulp_rpm
