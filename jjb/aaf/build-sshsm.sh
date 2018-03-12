#!/bin/bash
#

CURRENTDIR="$(pwd)"
echo $CURRENTDIR

echo 'Building the SoftHSMv2...'

cd SoftHSMv2
sh autogen.sh
./configure
make check
cd ..

echo 'Building the TPM2-Plugin...'

cd TPM2-Plugin
./bootstrap
./configure
make
