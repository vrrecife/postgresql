#!/bin/bash

clear

# Definição de hostname personalizado.

echo -en "Qual o nome do cliente? "
read CLIENT
CLIENT=`echo $CLIENT | sed 's/^.*$/\L&/ ; s/\s//g'`
HOSTNAME_CLIENT="srv-"$CLIENT"-database"
hostname $HOSTNAME_CLIENT
hostnamectl set-hostname $HOSTNAME_CLIENT
echo -e "127.0.0.1\t$HOSTNAME_CLIENT\n::1\t\t$HOSTNAME_CLIENT" > /etc/hosts

# Inclusão do DNS, caso necessário.

echo -e "\nTestando conexão com a internet..."
ping 8.8.8.8 -c4 > /dev/null 2> /dev/null
if [ $? -eq 0 ]; then
	echo -e "\nConexão bem-sucedida, ignorando inclusão do DNS."
else
	echo -e "\nIncluindo DNS para resolução de nomes."
	echo "nameserver 8.8.8.8" > /etc/resolv.conf
	echo "nameserver 8.8.4.4" >> /etc/resolv.conf
	sleep 2
fi

echo -e "\nAtualizando os repositórios YUM."

yum -y update 2> /dev/null && yum -y upgrade 2> /dev/null

echo -e "\nInstalando utilitários e dependências necessárias..."
sleep 2

yum -y install samba samba-client samba-common cifs-utils firewalld 2> /dev/null

# Instalação POSTGRESQL12

echo -e "\nInstalando PostgreSQL 12..."

yum install -y -q https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
yum install -y -q postgresql12-server postgresql12-contrib

/usr/pgsql-12/bin/postgresql-12-setup initdb

systemctl enable postgresql-12

cp /etc/samba/smb.conf /etc/samba/smb.conf.backup
cp /var/lib/pgsql/12/data/pg_hba.conf /var/lib/pgsql/12/data/pg_hba.conf.backup
cp /var/lib/pgsql/12/data/postgresql.conf /var/lib/pgsql/12/data/postgresql.conf.backup

# A variável STORAGE_TYPE corresponde ao tipo de armazenamento, onde 0 seria HDD e 1 SSD.
# Parâmetros para o arquivo 'postgresql.conf'.

if [ -z $MAX_CONNECTIONS ]; then
	clear ; echo -en "Qual será o número de conexões? "
	read MAX_CONNECTIONS
	while [ -z $MAX_CONNECTIONS ]; do
		echo -en "\nA variável não pode ser vazia, insira um valor válido: "
		read MAX_CONNECTIONS
	done
fi
STORAGE_TYPE=`cat /sys/block/sda/queue/rotational > /dev/null 2> /dev/null ; echo $?`
CPU_CORES=`cat /proc/cpuinfo | grep cores | wc -l`

MEM_TOTAL_KB=`cat /proc/meminfo | grep MemTotal | grep -o '[0-9]*'`

MEM_TOTAL_MB=$(($MEM_TOTAL_KB/1024))
SHARED_BUFFERS=$(($MEM_TOTAL_MB/4))
EFFECTIVE_CACHE_SIZE=$(($MEM_TOTAL_MB/4*3))
MAINTENANCE_WORK_MEM=$(($MEM_TOTAL_MB/16))
MAX_PARALLEL_CORES=$(($CPU_CORES/2))
WORK_MEM=$(($MEM_TOTAL_KB/16/$MAX_CONNECTIONS))

if [ $STORAGE_TYPE -eq 0 ]; then
	RANDOM_PAGE_COST=4
	EFFECTIVE_IO_CONCURRENCY=2
else
	RANDOM_PAGE_COST="1.1"
    EFFECTIVE_IO_CONCURRENCY=200
fi

# Parâmetros para o arquivo 'pg_hba.conf'.

NETWORKS=`hostname -I | sed 's/ /\n/g' | wc -l | bc`

i=1

if [ "$NETWORKS" -gt 2 ]; then
	while [ "$i" -lt "$NETWORKS" ]; do
		IPADDRESS=`hostname -I | sed 's/ /\n/g' | sed -n "$i p"`
		echo -e "host\tall\t\tall\t\t$IPADDRESS/24\t\tmd5" >> /var/lib/pgsql/12/data/pg_hba.conf
		LAST_IP=`tail -n1 /var/lib/pgsql/12/data/pg_hba.conf | cut -d . -f 4`
		ALTER_IP=`echo -e "0/24\t\tmd5"`
		sed -i "s|$LAST_IP|$ALTER_IP|g" /var/lib/pgsql/12/data/pg_hba.conf
		i=$(($i+1))
	done
else
	IPADDRESS=`hostname -I | sed 's/ /\n/g' | sed -n "$i p"`
	echo -e "host\tall\t\tall\t\t$IPADDRESS/24\t\tmd5" >> /var/lib/pgsql/12/data/pg_hba.conf
	LAST_IP=`tail -n1 /var/lib/pgsql/12/data/pg_hba.conf | cut -d . -f 4`
	ALTER_IP=`echo -e "0/24\t\tmd5"`
	sed -i "s|$LAST_IP|$ALTER_IP|g" /var/lib/pgsql/12/data/pg_hba.conf
fi

sed -i '/#listen_addresses/ s/localhost/*/' /var/lib/pgsql/12/data/postgresql.conf
sed -i '/#listen_addresses/ s/#listen_addresses/listen_addresses/' /var/lib/pgsql/12/data/postgresql.conf

sed -i '/#port/ s/5432/8745/' /var/lib/pgsql/12/data/postgresql.conf
sed -i '/#port/ s/#port/port/' /var/lib/pgsql/12/data/postgresql.conf

sed -i "/max_connections/ s/100/$MAX_CONNECTIONS/" /var/lib/pgsql/12/data/postgresql.conf

sed -i "/shared_buffers/ s/128/$SHARED_BUFFERS/" /var/lib/pgsql/12/data/postgresql.conf

sed -i "/#work_mem/ s/4/$WORK_MEM/" /var/lib/pgsql/12/data/postgresql.conf
sed -i '/#work_mem/ s/MB/kB/' /var/lib/pgsql/12/data/postgresql.conf
sed -i '/#work_mem/ s/#work_mem/work_mem/' /var/lib/pgsql/12/data/postgresql.conf

sed -i "/#max_worker_processes/ s/8/$CPU_CORES/" /var/lib/pgsql/12/data/postgresql.conf
sed -i '/#max_worker_processes/ s/#max_worker_processes/max_worker_processes/' /var/lib/pgsql/12/data/postgresql.conf

sed -i "/#max_parallel_workers/ s/8/$CPU_CORES/" /var/lib/pgsql/12/data/postgresql.conf
sed -i '/#max_parallel_workers/ s/#max_parallel_workers/max_parallel_workers/' /var/lib/pgsql/12/data/postgresql.conf

sed -i "/#max_parallel_workers_per_gather/ s/2/$MAX_PARALLEL_CORES/" /var/lib/pgsql/12/data/postgresql.conf
sed -i '/#max_parallel_workers_per_gather/ s/#max_parallel_workers_per_gather/max_parallel_workers_per_gather/' /var/lib/pgsql/12/data/postgresql.conf

sed -i "/#max_parallel_maintenance_workers/ s/0/$MAX_PARALLEL_CORES/" /var/lib/pgsql/12/data/postgresql.conf
sed -i '/#max_parallel_maintenance_workers/ s/#max_parallel_maintenance_workers/max_parallel_maintenance_workers/' /var/lib/pgsql/12/data/postgresql.conf

sed -i "/#random_page_cost/ s/4.0/$RANDOM_PAGE_COST/" /var/lib/pgsql/12/data/postgresql.conf
sed -i '/#random_page_cost/ s/#random_page_cost/random_page_cost/' /var/lib/pgsql/12/data/postgresql.conf
sed -i "/#effective_io_concurrency/ s/1/$EFFECTIVE_IO_CONCURRENCY/" /var/lib/pgsql/12/data/postgresql.conf
sed -i '/#effective_io_concurrency/ s/#effective_io_concurrency/effective_io_concurrency/' /var/lib/pgsql/12/data/postgresql.conf

sed -i '/#checkpoint_completion_target/ s/0.5/0.9/' /var/lib/pgsql/12/data/postgresql.conf
sed -i '/#checkpoint_completion_target/ s/#checkpoint_completion_target/checkpoint_completion_target/' /var/lib/pgsql/12/data/postgresql.conf

sed -i '/#wal_buffers/ s/-1/16MB/' /var/lib/pgsql/12/data/postgresql.conf
sed -i '/#wal_buffers/ s/#wal_buffers/wal_buffers/' /var/lib/pgsql/12/data/postgresql.conf

sed -i "/#effective_cache_size/ s/4/$EFFECTIVE_CACHE_SIZE/" /var/lib/pgsql/12/data/postgresql.conf
sed -i '/#effective_cache_size/ s/GB/MB/' /var/lib/pgsql/12/data/postgresql.conf
sed -i '/#effective_cache_size/ s/#effective_cache_size/effective_cache_size/' /var/lib/pgsql/12/data/postgresql.conf

sed -i "/#maintenance_work_mem/ s/64/$MAINTENANCE_WORK_MEM/" /var/lib/pgsql/12/data/postgresql.conf
sed -i '/#maintenance_work_mem/ s/#maintenance_work_mem/maintenance_work_mem/' /var/lib/pgsql/12/data/postgresql.conf

sed -i '/#default_statistics_target/ s/#default_statistics_target/default_statistics_target/' /var/lib/pgsql/12/data/postgresql.conf

sed -i '/min_wal_size/ s/80MB/1GB/' /var/lib/pgsql/12/data/postgresql.conf
sed -i '/max_wal_size/ s/1/4/' /var/lib/pgsql/12/data/postgresql.conf

sed -i '/#standard_conforming_strings/ s/on/off/' /var/lib/pgsql/12/data/postgresql.conf
sed -i '/#standard_conforming_strings/ s/#standard_conforming_strings/standard_conforming_strings/' /var/lib/pgsql/12/data/postgresql.conf

# Alterando parâmetro de confiabilidade e criando roles.

sed -i '/local/ s/md5/trust/' /var/lib/pgsql/12/data/pg_hba.conf
sed -i '/local/ s/peer/trust/' /var/lib/pgsql/12/data/pg_hba.conf

sed -i '/host/ s/md5/trust/' /var/lib/pgsql/12/data/pg_hba.conf
sed -i '/host/ s/peer/trust/' /var/lib/pgsql/12/data/pg_hba.conf

systemctl restart postgresql-12

chkconfig postgresql-12 on

echo -n "Alterando usuário POSTGRES: "
/usr/bin/psql -U postgres -p 8745 -c "ALTER USER postgres WITH ENCRYPTED PASSWORD 'VrPost@Server'"
echo -n "Criando usuário VRSOFTWARE: "
/usr/bin/psql -U postgres -p 8745 -c "CREATE USER vrsoftware WITH ENCRYPTED PASSWORD 'VrPost@Server';"
echo -n "Criando role PGSQL: "
/usr/bin/psql -U postgres -p 8745 -c "CREATE ROLE pgsql LOGIN SUPERUSER INHERIT CREATEDB CREATEROLE REPLICATION;"
echo -n "Alterando usuário PGSQL: "
/usr/bin/psql -U postgres -p 8745 -c "ALTER USER pgsql WITH ENCRYPTED PASSWORD 'VrPost@Server';"
echo -n "Criando role CONTROLLER360: "
/usr/bin/psql -U postgres -p 8745 -c "CREATE ROLE controller360 LOGIN  SUPERUSER  INHERIT  NOCREATEDB  NOCREATEROLE NOREPLICATION;"
echo -n "Criando usuário ARCOS: "
/usr/bin/psql -U postgres -p 8745 -c "CREATE USER arcos;"
echo -n "Criando usuário ARQUITETURA: "
/usr/bin/psql -U postgres -p 8745 -c "CREATE USER arquitetura;"
echo -n "Criando usuário DESENVOLVIMENTO: "
/usr/bin/psql -U postgres -p 8745 -c "CREATE USER desenvolvimento;"
echo -n "Criando usuário IMPLANTACAO: "
/usr/bin/psql -U postgres -p 8745 -c "CREATE USER implantacao;"
echo -n "Criando usuário MERCAFACIL: "
/usr/bin/psql -U postgres -p 8745 -c "CREATE USER mercafacil;"
echo -n "Criando usuário MIXFISCAL: "
/usr/bin/psql -U postgres -p 8745 -c "CREATE USER mixfiscal;"
echo -n "Criando usuário PAGPOUCO: "
/usr/bin/psql -U postgres -p 8745 -c "CREATE USER pagpouco;"
echo -n "Criando usuário SUPORTE: "
/usr/bin/psql -U postgres -p 8745 -c "CREATE USER suporte;"
echo -n "Criando usuário SIMIX: "
/usr/bin/psql -U postgres -p 8745 -c "CREATE USER simix;"
echo -n "Criando usuário MARKETSCIENCE: "
/usr/bin/psql -U postgres -p 8745 -c "CREATE USER marketscience;"
echo -n "Criando usuário TRIBUTOFACIL: "
/usr/bin/psql -U postgres -p 8745 -c "CREATE ROLE tributofacil;"
echo -n "Criando database VR: "
/usr/bin/psql -U postgres -p 8745 -c "CREATE DATABASE vr;"

# Voltando parâmetro para o valor default.

# sed -i '/local/ s/trust/peer/' /var/lib/pgsql/12/data/pg_hba.conf
# sed -i '/host/ s/trust/peer/' /var/lib/pgsql/12/data/pg_hba.conf

systemctl restart postgresql-12

# Configurando o compartilhamento público via samba.

mkdir -p /vr/backup
chmod -R 777 /vr
chmod -R 775 /vr/backup
chcon -t samba_share_t /vr
chcon -t samba_share_t /vr/backup

echo -e "[global]\n\tworkgroup = WORKGROUP\n\tserver string = %h server (Samba %v)\n\tsecurity = user\n\tpassdb backend = tdbsam\n\tprinting = cups\n\tprintcap name = cups\n\tcups options = raw\n\tmap to guest = bad user\n\tguest ok = yes\n[vr]\n\tpath = /vr\n\tcomment = Compartilhamento VR\n\tpublic = yes\n\twritable = yes" > /etc/samba/smb.conf

# Adicionando regras de firewall.

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
systemctl restart smb nmb firewalld postgresql-12

# para desativar o firewall
# systemctl disable firewalld
# systemctl stop firewalld

echo -e "\nConfigurações finalizadas, reinicie o servidor!"