#!/bin/bash

set -e

export DOCKER_SCAN_SUGGEST=false

# With qemu-user-static 1:4.2-3ubuntu6.17
docker build --platform linux/amd64 -f old-qemu-dockerfile -t old-qemu .
# With qemu-user-static 1:4.2-3ubuntu6.19
docker build --platform linux/amd64 -f new-qemu-dockerfile -t new-qemu .

run_in_docker="docker run --init -t --platform linux/amd64 --rm -v $PWD:/build"

mkdir -p gperftools-build
$run_in_docker old-qemu cmake -G Ninja -S /build/gperftools -B /build/gperftools-build \
    -DCMAKE_AR=/usr/bin/arm-linux-gnueabihf-ar \
    -DCMAKE_CXX_COMPILER=/usr/bin/arm-linux-gnueabihf-g++ \
    -DCMAKE_C_COMPILER=/usr/bin/arm-linux-gnueabihf-gcc \
    -DCMAKE_RANLIB=/usr/bin/arm-linux-gnueabihf-ranlib
$run_in_docker old-qemu ninja -C /build/gperftools-build tcmalloc_debug

$run_in_docker old-qemu arm-linux-gnueabihf-gcc -g -Wall -o test test.c \
    -Wl,-rpath=gperftools-build gperftools-build/libtcmalloc_debug.so
$run_in_docker old-qemu qemu-arm-static --version
$run_in_docker old-qemu qemu-arm-static -d page ./test

echo ""
$run_in_docker new-qemu qemu-arm-static --version
$run_in_docker new-qemu qemu-arm-static -d page ./test
