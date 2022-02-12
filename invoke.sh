#!/bin/sh
#
# this file invoke provision.ph

local file_path=$(dirname $0)

if ! command -v bash > /dev/null; then
  echo "install gnu bash!" >&2
  return 127
fi
bash ./provision.sh
