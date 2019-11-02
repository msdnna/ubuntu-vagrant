#!/bin/bash
# this will update the ubuntu.json file with the current netboot image checksum.
# see https://help.ubuntu.com/community/VerifyIsoHowto
# abort this script when a command fails or a unset variable is used and echo
# the executed commands.
set -eux
iso_url=$(jq -r '.variables.iso_url' ubuntu.json)
iso_checksum_url="$(dirname $(dirname $iso_url))/SHA256SUMS"
curl -O --silent --show-error $iso_checksum_url
curl -O --silent --show-error $iso_checksum_url.gpg
gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 0x871920D1991BC93C
gpg --verify SHA256SUMS.gpg SHA256SUMS
iso_checksum=$(grep mini.iso SHA256SUMS | awk '{print $1}')
sed -i -E "s,(\"iso_checksum\": \")([a-f0-9]+)(\"),\\1$iso_checksum\\3,g" ubuntu.json
rm SHA256SUMS*
echo 'iso_checksum updated successfully'
