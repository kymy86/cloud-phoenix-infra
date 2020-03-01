#!/usr/bin/env bash

until [[ -f /var/lib/cloud/instance/boot-finished ]]; do
    sleep 1
done

sudo shutdown -h +1