set -x 

#You need first to request for an interactive session, asking for a node with 8G of Memory, with the following command:
#qlogin -l h_vmem=8G

export _JAVA_OPTIONS='-Xmx128M -Xmx1G'
module load java
export SPARK_HOME=/home/rfilguei/spark-2.4.0-bin-hadoop2.7

hostmaster=$(cat "bash_scripts/master.log")
echo "Master Node" $hostmaster

NUM=$(wc -l bash_scripts/worker.log)
NUMWORKERS=$(echo $NUM| cut -d' ' -f1)
NUMCORES=$( expr 16 '*' "$NUMWORKERS")

$SPARK_HOME/bin/spark-submit --class org.apache.spark.examples.SparkPi  --master spark://$hostmaster:7077 --executor-memory 20G   --total-executor-cores $NUMCORES  $SPARK_HOME/examples/jars/spark-examples_2.11-2.4.0.jar 1000 > output.txt
