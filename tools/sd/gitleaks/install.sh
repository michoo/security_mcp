#!/bin/bash

VERSION=8.28.0

rm gitleaks

wget "https://github.com/gitleaks/gitleaks/releases/download/v8.28.0/gitleaks_${VERSION}_checksums.txt"
wget "https://github.com/gitleaks/gitleaks/releases/download/v8.28.0/gitleaks_${VERSION}_linux_x64.tar.gz"

if sha256sum "gitleaks_${VERSION}_linux_x64.tar.gz" | grep -qF "$(grep "gitleaks_${VERSION}_linux_x64.tar.gz" "gitleaks_${VERSION}_checksums.txt")"; then
  echo "Checksum matches! Unzipping..."
  tar -xzvf "gitleaks_${VERSION}_linux_x64.tar.gz"
else
  echo "Checksum mismatch! Exiting."
  exit 1
fi

rm "gitleaks_${VERSION}_linux_x64.tar.gz"
rm "gitleaks_${VERSION}_checksums.txt"