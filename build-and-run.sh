#!/bin/bash

set -e

export DOCKER_SCAN_SUGGEST=false

# With qemu-user-static 1:4.2-3ubuntu6.17
docker build --platform linux/amd64 -f old-qemu-dockerfile -t old-qemu .
# With qemu-user-static 1:4.2-3ubuntu6.19
docker build --platform linux/amd64 -f new-qemu-dockerfile -t new-qemu .

run_in_docker="docker run --init -t --platform linux/amd64 --rm -v $PWD:/build"

$run_in_docker old-qemu arm-linux-gnueabihf-gcc -g -Wall -o test test.c -ltcmalloc
$run_in_docker old-qemu qemu-arm-static --version
$run_in_docker old-qemu qemu-arm-static -d page ./test

echo ""
$run_in_docker new-qemu qemu-arm-static --version
$run_in_docker new-qemu qemu-arm-static -d page ./test
