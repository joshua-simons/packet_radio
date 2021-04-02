#!/bin/bash
#Use kissutil to test serial connection to mobilinkd tnc3
kissutil -p /dev/rfcomm1 -f tx -o rx
