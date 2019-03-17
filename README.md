# Spark_on_HPC_cluster
This repository describes all the steps necesaries to create a **multinode Spark standalone cluster (2.4.0)** within a PBS-job (we are going to give you two options). We have tested those scripts using EDDIE HPC cluster, hosted at Universtiy of Edinburgh.

# Download Spark
        wget http://apache.mirrors.nublue.co.uk/spark/spark-2.4.0/spark-2.4.0-bin-hadoop2.7.tgz
	tar xvf spark-2.4.0-bin-hadoop2.7

# Copy the contain of this repository in your $HOME directory.

The idea is that in your $HOME directory, you have the following:
* spark-2.4.0-bin-hadoop2.7 directory
* bash_scripts
* spark_conf
* sparkcluster_and_driver.sh, sparkcluster.sh, spark-interactive-textming.sh, spark-interactive-Pi.sh,  spark-driver-Pi.sh, spark-driver-textming.sh spark_stop.sh, spark-Pi.sh, spark-textming.sh

IDEA:
	
	cp -r spark_conf in your $HOME directory
	cp spark_scripts/* in your $HOME directory
	cp -r bash_scripts in your $HOME directory
	cp *.sh in your $HOME directory


# Change the Spark configurable files
	
	cp spark_conf/* spark-2.4.0-bin-hadoop2.7/conf/.
	
Note: JAVA_HOME needs to be updated - in spark-env.sh. You might also want to configure more parameters inside spark-defaults.conf file (e.g. tmp directory or log directory). 
  
# Start a Spark cluster within a PBS job
We have two PBS-jobs to provision on-demand and for a specific period of time the desired spark cluster. 

* Option 1: PBS-job starts the master, workers and registering all workers against master, and the driver which submits a Spark Application/query to such Spark cluster once is running.

  		qsub sparkcluster_and_driver.sh

Note: In this option we have already configured the driver to submit a Spark text-mining query to the Spark Cluster ( ./spark-query.sh). If you want to change the query or submit another application ( e.g. spark-Pi.sh), you just need to modify/replace this spark-query.sh script. 

* Option 2:PBS-job starts the master, workers and registering all workers against master. For submitting Spark Applications/Queries to the Spark Cluster we need to do it via: a) another PBS-job ; b) interactive session.  

                qsub sparkcluster.sh


You can modify it as you wish for reserving more or less nodes for your spark cluster. In the current scipt, we have used 3 nodes: one node for running the master, and:
* sparkcluster_and_driver --> 1 node for running the worker and 1 node for running the driver.
* sparkcluster --> 2 nodes for running the workers.  


# Submit spark applications to the Spark cluster
Once you have the spark cluster running ( your PBS job has been accepted and you have the resoureces available), you can submit spark applications to it. 

1) Submitting Spark-PI to Spark-Cluster from the login node: 
	1.1) Via a PBS-job which will act as the driver:
		qsub spark-driver-PI.sh
	1.2 ) Via an interactive session - Important ( you need to request a session with at least 8GB of memory):
		 qlogin -l h_vmem=8G
		 ./spark-interactive-Pi.sh

2) Submitting a TextMining query to the Spark-Cluster. This will requiere the following steps:
	2.1 ) Clone our TextMinging repository
	2.2) 
		
			


