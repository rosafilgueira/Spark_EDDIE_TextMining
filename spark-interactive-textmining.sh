set -x 

#You need first to request for an interactive session, asking for a node with 8G of Memory, with the following command:
#qlogin -l h_vmem=8G


export _JAVA_OPTIONS='-Xmx128M -Xmx4G'
module load java
module load python/2.7.10 

hostmaster=$(cat "$HOME/bash_scripts/master.log")
echo "Master Node" $hostmaster

NUM=$(wc -l $HOME/bash_scripts/worker.log)
NUMWORKERS=$(echo $NUM| cut -d' ' -f1)
NUMCORES=$( expr 16 '*' "$NUMWORKERS")

export SPARK_HOME=${HOME}/spark-2.4.0-bin-hadoop2.7
cd $HOME/defoe

$SPARK_HOME/bin/spark-submit --master spark://$hostmaster:7077 --executor-memory 60g --py-files defoe.zip defoe/run_query.py data.txt papers defoe.papers.queries.total_words -n $NUMCORES > query_job.txt

