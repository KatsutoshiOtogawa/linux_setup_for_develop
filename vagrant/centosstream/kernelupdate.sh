#!/usr/bin/bash
#
# utils, often use.

yum update -y

# virtual box guest addition plugin is require kernel update.
# this operation is only need fedora.
yum -y update kernel-core kernel-devel kernel-headers
