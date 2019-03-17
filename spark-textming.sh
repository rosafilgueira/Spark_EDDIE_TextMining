#!/bin/bash 
#This script if for using after the Spark-Cluster is running. It submits a Spark text mining query to such cluster.

hostmaster=$1
echo "Master Node" $hostmaster
export SPARK_HOME=/home/rfilguei/spark-2.4.0-bin-hadoop2.7

NUM=$(wc -l bash_scripts/worker.log)
NUMWORKERS=$(echo $NUM| cut -d' ' -f1)
NUMCORES=$( expr 16 '*' "$NUMWORKERS")


cd $HOME/defoe
$SPARK_HOME/bin/spark-submit --master spark://$hostmaster:7077 --executor-memory 60g --py-files defoe.zip defoe/run_query.py data.txt papers defoe.papers.queries.total_words -n $NUMCORES > query_job_example.xt
