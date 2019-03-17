#!/bin/bash 
#This script if for using after the Spark-Cluster is running. It submits the Spark Pi application to such cluster.

hostmaster=$1
echo "Master Node" $hostmaster
export SPARK_HOME=/home/rfilguei/spark-2.4.0-bin-hadoop2.7


NUM=$(wc -l bash_scripts/worker.log)
NUMWORKERS=$(echo $NUM| cut -d' ' -f1)
NUMCORES=$( expr 16 '*' "$NUMWORKERS")

$SPARK_HOME/bin/spark-submit --class org.apache.spark.examples.SparkPi  --master spark://$hostmaster:7077 --executor-memory 20G   --total-executor-cores $NUMCORES $SPARK_HOME/examples/jars/spark-examples_2.11-2.4.0.jar 1000 > output.txt
