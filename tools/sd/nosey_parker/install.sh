#!/bin/bash

VERSION=0.24.0

wget https://github.com/praetorian-inc/noseyparker/releases/download/v${VERSION}/noseyparker-v${VERSION}-x86_64-unknown-linux-gnu.tar.gz

tar -xzvf "noseyparker-v${VERSION}-x86_64-unknown-linux-gnu.tar.gz"

rm "noseyparker-v${VERSION}-x86_64-unknown-linux-gnu.tar.gz"