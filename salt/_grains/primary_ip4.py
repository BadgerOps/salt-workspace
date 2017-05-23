#!/usr/bin/env python
import subprocess

def getipv4():  
    grains = {}
    ipv4 = subprocess.check_output("ip route get 1 | awk '{print $NF;exit}'", shell=True)
    grains['primary_ipv4'] = ipv4
    return grains
