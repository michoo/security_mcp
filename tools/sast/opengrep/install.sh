#!/bin/bash

VERSION=1.10.0
wget https://github.com/opengrep/opengrep/releases/download/v${VERSION}/opengrep_manylinux_x86 -O opengrep

#git clone https://github.com/opengrep/opengrep-rules

chmod +x opengrep