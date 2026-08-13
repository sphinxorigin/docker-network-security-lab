#!/bin/bash

sudo ip address add 100.96.0.8/32 dev lo
sudo ip address add 100.24.0.8/24 dev ensD0

# default route Richtung i4
sudo ip route replace default via 100.24.0.1 dev ensD0

ip -br address
ip route show