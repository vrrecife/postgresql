#!/bin/bash

# PostgreSQL

sudo apt update update 2> /dev/null && sudo apt upgrade
curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg
echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" |sudo tee /etc/apt/sources.list.d/pgdg.list
sudo apt update sudo apt -y install postgresql-12 postgresql-contrib
systemctl restart postgresql.service
sudo su - postgres
psql -c "alter user postgres with password 'VrPost@Server'"
systemctl restart postgresql.service
systemctl status postgresql.service
