#!/bin/sh

cd core-common-lib
git pull
cd ..

cd core-communication-lib
git pull
cd ..

cd core-firmware
rm -fr inc src
git checkout .
git checkout spark-master
git fetch
git checkout master
git merge spark-master
git rm build/core-firmware.bin build/core-firmware.elf build/core-firmware.hex
git commit -m "Merge branch 'spark-master'"
