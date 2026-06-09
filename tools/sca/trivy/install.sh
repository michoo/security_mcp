#!/bin/bash

VERSION=0.71.0

wget https://github.com/aquasecurity/trivy/releases/download/v${VERSION}/trivy_${VERSION}_checksums.txt
wget https://github.com/aquasecurity/trivy/releases/download/v${VERSION}/trivy_${VERSION}_Linux-64bit.tar.gz

if sha256sum "trivy_${VERSION}_Linux-64bit.tar.gz" | grep -qF "$(grep "trivy_${VERSION}_Linux-64bit.tar.gz" "trivy_${VERSION}_checksums.txt")"; then
  echo "Checksum matches! Unzipping..."
  tar -xzvf "trivy_${VERSION}_Linux-64bit.tar.gz"
else
  echo "Checksum mismatch! Exiting."
  exit 1
fi

rm "trivy_${VERSION}_Linux-64bit.tar.gz"
rm "trivy_${VERSION}_checksums.txt"