#!/usr/local/bin/bash
#
# utils, often use.


# virtual box guest addition plugin is require kernel update.
# this operation is only need fedora.
pkg install -y virtualbox-ose-additions

# # sysrc vboxguest_enable="YES"
# # sysrc vboxservice_enable="YES"
# In some situations, a panic will occur when the kernel module loads.
# Having no more than one virtual CPU might mitigate the issue.

# For features such as window scaling and clipboard sharing, membership of
# the wheel group is required. With username jerry as an example:

# # pw groupmod wheel -m jerry

# The settings dialogue for FreeBSD guests encourages use of the VMSVGA
# graphics controller. Whilst this might suit installations of FreeBSD
# without a desktop environment (a common use case), it is not appropriate
# where Guest Additions are installed.

# Where Guest Additions are installed:

# 1. prefer VBoxSVGA

# 2. do not enable 3D acceleration (doing so will invisibly
#    lose the preference for VBoxSVGA)

# – you may ignore the yellow alert that encourages use of VMSVGA.
