#!/bin/bash

VERSION=1.2.1

rm -f titus

wget "https://github.com/praetorian-inc/titus/releases/download/v${VERSION}/checksums.txt"
wget "https://github.com/praetorian-inc/titus/releases/download/v${VERSION}/titus-linux-amd64"

if sha256sum "titus-linux-amd64" | grep -qF "$(grep "titus-linux-amd64" "checksums.txt")"; then
  echo "Checksum matches! Installing..."
  mv titus-linux-amd64 titus
  chmod +x titus
else
  echo "Checksum mismatch! Exiting."
  rm -f titus-linux-amd64 checksums.txt
  exit 1
fi

rm "checksums.txt"