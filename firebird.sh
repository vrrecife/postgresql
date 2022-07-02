#!/bin/bash

# Firebird

sudo apt update 2> /dev/null && sudo apt upgrade 2> /dev/null && sudo apt-get install libstdc++5 libncurses5 libtommath1 2> /dev/null

wget -c -P $HOME https://github.com/FirebirdSQL/firebird/releases/download/R2_5_9/FirebirdSS-2.5.9.27139-0.amd64.tar.gz

cd $HOME

tar -xzvf FirebirdSS-2.5.9.27139-0.amd64.tar.gz

cd FirebirdSS-2.5.9.27139-0.amd64

sudo ./install.sh

cd 

rm FirebirdSS-2.5.9.27139-0.amd64.tar.gz

rm -rf FirebirdSS-2.5.9.27139-0.amd64/

systemctl start firebird.service

systemctl status firebird.service

