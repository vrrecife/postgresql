#!/bin/bash

# MariaDB

sudo apt update 2> /dev/null && sudo apt -y install mariadb-server 2> /dev/null && sudo mysql_secure_installation 2> /dev/null
