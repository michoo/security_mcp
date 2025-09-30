#!/bin/bash

VERSION=3.4.10

wget https://github.com/projectdiscovery/nuclei/releases/download/v${VERSION}/nuclei_${VERSION}_linux_amd64.zip
wget https://github.com/projectdiscovery/nuclei/releases/download/v${VERSION}/nuclei_${VERSION}_checksums.txt

if sha256sum "nuclei_${VERSION}_linux_amd64.zip" | grep -qF "$(grep "nuclei_${VERSION}_linux_amd64.zip" "nuclei_${VERSION}_checksums.txt")"; then
  echo "Checksum matches! Unzipping..."
  unzip "nuclei_${VERSION}_linux_amd64.zip"
else
  echo "Checksum mismatch! Exiting."
  exit 1
fi

rm nuclei_${VERSION}_linux_amd64.zip
rm nuclei_${VERSION}_checksums.txt
rm *.md