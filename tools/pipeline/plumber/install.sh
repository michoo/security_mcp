#!/bin/bash

VERSION=0.3.51

rm -f plumber

wget "https://github.com/getplumber/plumber/releases/download/v${VERSION}/checksums.txt"
wget "https://github.com/getplumber/plumber/releases/download/v${VERSION}/plumber-linux-amd64"

if sha256sum "plumber-linux-amd64" | grep -qF "$(grep "plumber-linux-amd64" "checksums.txt")"; then
  echo "Checksum matches! Installing..."
  mv plumber-linux-amd64 plumber
  chmod +x plumber
else
  echo "Checksum mismatch! Exiting."
  rm -f plumber-linux-amd64 checksums.txt
  exit 1
fi

rm "checksums.txt"