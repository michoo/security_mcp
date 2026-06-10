#!/bin/bash

VERSION=1.4.1

rm -f betterleaks

wget "https://github.com/betterleaks/betterleaks/releases/download/v${VERSION}/checksums.txt"
wget "https://github.com/betterleaks/betterleaks/releases/download/v${VERSION}/betterleaks_${VERSION}_linux_x64.tar.gz"

if sha256sum "betterleaks_${VERSION}_linux_x64.tar.gz" | grep -qF "$(grep "betterleaks_${VERSION}_linux_x64.tar.gz" "checksums.txt")"; then
  echo "Checksum matches! Unzipping..."
  tar -xzvf "betterleaks_${VERSION}_linux_x64.tar.gz"
else
  echo "Checksum mismatch! Exiting."
  exit 1
fi

rm "betterleaks_${VERSION}_linux_x64.tar.gz"
rm "checksums.txt"
