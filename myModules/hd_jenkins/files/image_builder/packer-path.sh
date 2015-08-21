#!/bin/bash

PACKER="/opt/packer"

if [[ ":$PATH:" != *":$PACKER:"* ]]; then
  export PATH="${PATH:+"$PATH:"}$PACKER"
fi