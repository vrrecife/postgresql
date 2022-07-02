#!/bin/bash

# PostgreSQL

sudo apt update 2> /dev/null && sudo apt upgrade 2> /dev/null
curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg
echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" |sudo tee /etc/apt/sources.list.d/pgdg.list
sudo apt update 2> /dev/null && sudo apt -y install postgresql-12 postgresql-contrib 2> /dev/null
systemctl restart postgresql.service
