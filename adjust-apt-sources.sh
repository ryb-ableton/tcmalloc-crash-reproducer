#!/bin/bash

# https://android.googlesource.com/device/google/cuttlefish/+/HEAD/multiarch-howto.md

cp /etc/apt/sources.list ~/sources.list.bak
(
  (grep ^deb /etc/apt/sources.list | sed 's/deb /deb [arch=amd64] /') && \
  (grep ^deb /etc/apt/sources.list | sed -E 's/deb /deb [arch=armhf] /g; s/(archive|security)\.ubuntu/ports.ubuntu/g; s/ubuntu\//ubuntu-ports\//g') \
) | tee /tmp/sources.list
mv /tmp/sources.list /etc/apt/sources.list
