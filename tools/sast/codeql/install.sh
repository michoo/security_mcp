#!/bin/bash

VERSION=2.25.6

rm -rf codeql

wget "https://github.com/github/codeql-cli-binaries/releases/download/v${VERSION}/codeql-linux64.zip.checksum.txt"
wget "https://github.com/github/codeql-cli-binaries/releases/download/v${VERSION}/codeql-linux64.zip"

if sha256sum "codeql-linux64.zip" | grep -qF "$(grep "codeql-linux64.zip" "codeql-linux64.zip.checksum.txt" | awk '{print $1}')"; then
  echo "Checksum matches! Unzipping..."
  unzip -q "codeql-linux64.zip"
else
  echo "Checksum mismatch! Exiting."
  rm -f "codeql-linux64.zip" "codeql-linux64.zip.checksum.txt"
  exit 1
fi

rm "codeql-linux64.zip"
rm "codeql-linux64.zip.checksum.txt"