#!/bin/bash

# Microsoft SQL Server 2019

wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -

sudo add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/20.04/mssql-server-preview.list)"

sudo apt-get update 2> /dev/null && sudo apt-get install -y mssql-server 2> /dev/null && sudo /opt/mssql/bin/mssql-conf setup 2> /dev/null

systemctl status mssql-server --no-pager

sudo apt-get update 2> /dev/null && sudo apt install curl 2> /dev/null

curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add - |curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list | sudo tee /etc/apt/sources.list.d/msprod.list

sudo apt-get update 2> /dev/null && sudo apt-get install mssql-tools unixodbc-dev 2> /dev/null && sudo apt-get install mssql-tools 2> /dev/null