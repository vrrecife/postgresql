CPU_CORES=`cat /proc/cpuinfo | grep cores | wc -l`
CPU_CORES_2=CPU_CORES/2
MAX_PARALLEL_CORES=$CPU_CORES_2 | bc -l | xargs printf "%.0f"
echo $MAX_PARALLEL_CORES
