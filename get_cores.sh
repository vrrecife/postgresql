CPU_CORES=`cat /proc/cpuinfo | grep cores | wc -l`
MAX_PARALLEL_CORES=(($CPU_CORES/2)| bc -l | xargs printf "%.0f")
echo $MAX_PARALLEL_CORES