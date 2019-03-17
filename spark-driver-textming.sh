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


cd $HOME/defoe

$SPARK_HOME/bin/spark-submit --master spark://$hostmaster:7077 --executor-memory 60g --py-files defoe.zip defoe/run_query.py data.txt papers defoe.papers.queries.keyword_by_year queries/diseases.txt -n $NUMCORES > query_job.txt

