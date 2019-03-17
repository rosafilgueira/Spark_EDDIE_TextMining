#!/bin/sh
# Grid Engine options (lines prefixed with #$)
#$ -N Spark_DEFOE              
#$ -cwd                  
#$ -l h_rt=00:50:00 
#$ -l h_vmem=8G
# Initialise the environment modules
. /etc/profile.d/modules.sh

# Load Python
module load python/2.7.10 
module load java
export _JAVA_OPTIONS='-Xmx128M -Xmx1G'

hostmaster=$(cat "bash_scripts/master.log")
echo "Master Node" $hostmaster
export SPARK_HOME=/home/rfilguei/spark-2.4.0-bin-hadoop2.7


NUM=$(wc -l bash_scripts/worker.log)
NUMWORKERS=$(echo $NUM| cut -d' ' -f1)
NUMCORES=$( expr 16 '*' "$NUMWORKERS")

$SPARK_HOME/bin/spark-submit --class org.apache.spark.examples.SparkPi  --master spark://$hostmaster:7077 --executor-memory 20G   --total-executor-cores $NUMCORES $SPARK_HOME/examples/jars/spark-examples_2.11-2.4.0.jar 1000 > output.txt


