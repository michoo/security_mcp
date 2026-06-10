#!/bin/bash

VERSION=3.95.5

rm -f trufflehog

wget "https://github.com/trufflesecurity/trufflehog/releases/download/v${VERSION}/trufflehog_${VERSION}_checksums.txt"
wget "https://github.com/trufflesecurity/trufflehog/releases/download/v${VERSION}/trufflehog_${VERSION}_linux_amd64.tar.gz"

if sha256sum "trufflehog_${VERSION}_linux_amd64.tar.gz" | grep -qF "$(grep "trufflehog_${VERSION}_linux_amd64.tar.gz" "trufflehog_${VERSION}_checksums.txt")"; then
  echo "Checksum matches! Unzipping..."
  tar -xzvf "trufflehog_${VERSION}_linux_amd64.tar.gz" trufflehog
else
  echo "Checksum mismatch! Exiting."
  exit 1
fi

rm "trufflehog_${VERSION}_linux_amd64.tar.gz"
rm "trufflehog_${VERSION}_checksums.txt"
