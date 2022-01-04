CPU_CORES=`cat /proc/cpuinfo | grep cores | wc -l`

if [ $CPU_CORES -eq 1 ]; then
	sed -i "/#max_parallel_workers_per_gather/ s/2/1/" /var/lib/pgsql/12/data/postgresql.conf
	sed -i "/#max_parallel_maintenance_workers/ s/0/1/" /var/lib/pgsql/12/data/postgresql.conf
else
	sed -i "/#max_parallel_workers_per_gather/ s/2/$MAX_PARALLEL_CORES/" /var/lib/pgsql/12/data/postgresql.conf
	sed -i "/#max_parallel_maintenance_workers/ s/0/$MAX_PARALLEL_CORES/" /var/lib/pgsql/12/data/postgresql.conf
fi
