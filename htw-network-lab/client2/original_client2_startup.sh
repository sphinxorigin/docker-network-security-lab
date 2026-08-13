#!/bin/bash

IF_CL=$(ip -br link | awk '$3=="00:00:10:11:21:11" {print $1}' | cut -d@ -f1)
[ -z "$IF_CL" ] && IF_CL="ensC0"

sudo dhclient -r "$IF_CL"
sudo dhclient "$IF_CL"

ip -br address
ip route show
cat /etc/resolv.conf