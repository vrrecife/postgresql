#!/bin/bash

yum -y update 2> /dev/null && yum -y upgrade 2> /dev/null

yum -y install samba samba-client samba-common cifs-utils firewalld 2> /dev/null

sleep 5

yum install -y -q https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
yum install -y -q postgresql12-server postgresql12-contrib

sleep 5

/usr/pgsql-12/bin/postgresql-12-setup initdb

systemctl enable postgresql-12
systemctl start postgresql-12

chkconfig postgresql-12 on

sleep 5

mkdir -p /vr/backup
chmod -R 777 /vr
chmod -R 775 /vr/backup
chcon -t samba_share_t /vr
chcon -t samba_share_t /vr/backup

cp /etc/samba/smb.conf /etc/samba/smb.conf.backup
cp /var/lib/pgsql/12/data/pg_hba.conf /var/lib/pgsql/12/data/pg_hba.conf.backup
cp /var/lib/pgsql/12/data/postgresql.conf /var/lib/pgsql/12/data/postgresql.conf.backup

echo -e "[global]\n\tworkgroup = WORKGROUP\n\tserver string = %h server (Samba %v)\n\tsecurity = user\n\tpassdb backend = tdbsam\n\tprinting = cups\n\tprintcap name = cups\n\tcups options = raw\n\tmap to guest = bad user\n\tguest ok = yes\n[vr]\n\tpath = /vr\n\tcomment = Compartilhamento VR\n\tpublic = yes\n\twritable = yes" > /etc/samba/smb.conf

sleep 5

firewall-cmd --set-default-zone=work
firewall-cmd --add-service=samba --permanent
firewall-cmd --add-port=137/tcp --permanent
firewall-cmd --add-port=138/tcp --permanent
firewall-cmd --add-port=139/tcp --permanent
firewall-cmd --add-port=445/tcp --permanent
firewall-cmd --add-service=postgresql --permanent
firewall-cmd --add-port=8745/tcp --permanent
firewall-cmd --reload

systemctl enable smb nmb
systemctl restart smb nmb firewalld

# para desativar o firewall
# systemctl disable firewalld
# systemctl stop firewalld

sleep 5
