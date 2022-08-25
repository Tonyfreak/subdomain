#!/bin/bash

clear
./.banner.sh

sleep 2

read -p "Enter file name: " fl
read -p "Enter comany name: " comp
mkdir ~/recon/$comp
n=1
cd ~/recon/$comp
mkdir param
cd param
while read line;do
 echo " Domain $n : $line"
 echo $line | tee -a $fl.txt
python3 ~/tools/P4R4M-HUNT3R/param-hunter.py --domain $line > ~/recon/$comp/param/$line.txt
n=$((n+1))
done < $fl 
