#!/bin/bash

VERSION=2.2.2

wget https://github.com/google/osv-scanner/releases/download/v${VERSION}/osv-scanner_linux_amd64 -O osv-scanner

chmod +x osv-scanner