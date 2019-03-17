#!/bin/sh
# Grid Engine options (lines prefixed with #$)
#$ -N Spark_Cluster_And_Query
#$ -cwd                  
#$ -l h_rt=00:50:00 
#$ -l h_vmem=4G
#$ -pe mpi 48
#$ -R y
# Initialise the environment modules
. /etc/profile.d/modules.sh
 
# Load Python
module load python/2.7.10 
# Run the program
export SPARK_HOME=/home/rfilguei/spark-2.4.0-bin-hadoop2.7
cd $HOME/bash_scripts
rm -f machines.log
rm -f machines_uniq.log
rm -f master.log
rm -f driver.log
rm -f worker.log

NUM_NODES=$NSLOTS
NUM=1
while test $NUM -le $NSLOTS
do
  STRING1=`head -n $NUM $PE_HOSTFILE | tail -1 | awk '{print $1}'`
  echo "$STRING1" >> machines.log
  NUM=`expr $NUM + 1`
done

nodes=($( cat machines.log | sort | uniq ))
# start resource manager only once
echo "`hostname`" > master.log
./start_master.sh
mastername=$(cat "master.log")
echo "Started master on" $mastername

# getting the driver node - only one
for each in "${nodes[@]}"
do
  if [ $each != $mastername ] ; then
     echo $each > driver.log
  fi
done

drivername=$(cat "driver.log")

# start workers in all the nodes except the one where the master and driver were started
for i in "${nodes[@]}"

do
    echo $i
    ssh $i "cd $HOME/bash_scripts; ./start_worker.sh $mastername $drivername" &
done

######### submiting the query from the driver ##########

ssh $drivername "./spark-query.sh $mastername" 

sleep 1h