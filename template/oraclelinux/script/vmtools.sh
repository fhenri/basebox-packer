#!/bin/bash -eux

VAGRANT_USER=ariba
VAGRANT_HOME=/home/$VAGRANT_USER

if [ $PACKER_BUILDER_TYPE == 'vmware-iso' ]; then
    if grep -q -i "release 6" /etc/redhat-release ; then
        # Uninstall fuse to fake out the vmware install so it won't try to
        # enable the VMware blocking filesystem
        yum erase -y fuse
    fi
    # Assume that we've installed all the prerequisites:
    # kernel-headers-$(uname -r) kernel-devel-$(uname -r) gcc make perl
    # from the install media via ks.cfg

    cd /tmp
    mkdir -p /mnt/cdrom
    mount -o loop $VAGRANT_HOME/linux.iso /mnt/cdrom
    tar zxf /mnt/cdrom/VMwareTools-*.tar.gz -C /tmp/
    #/tmp/vmware-tools-distrib/vmware-install.pl -d
    /tmp/vmware-tools-distrib/vmware-install.pl
    rm $VAGRANT_HOME/linux.iso
    umount /mnt/cdrom
    rmdir /mnt/cdrom
elif [ $PACKER_BUILDER_TYPE == 'virtualbox' ]; then
    echo "Installing VirtualBox guest additions"

    # Assume that we've installed all the prerequisites:
    # kernel-headers-$(uname -r) kernel-devel-$(uname -r) gcc make perl
    # from the install media via ks.cfg

    VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
    mount -o loop $VAGRANT_HOME/VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
    sh /mnt/VBoxLinuxAdditions.run --nox11
    umount /mnt
    rm -rf $VAGRANT_HOME/VBoxGuestAdditions_$VBOX_VERSION.iso
fi
