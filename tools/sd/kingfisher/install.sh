#!/bin/bash

VERSION=1.54.0

wget https://github.com/mongodb/kingfisher/releases/download/v${VERSION}/kingfisher-linux-x64.tgz

tar -xzvf "kingfisher-linux-x64.tgz"

rm "kingfisher-linux-x64.tgz"