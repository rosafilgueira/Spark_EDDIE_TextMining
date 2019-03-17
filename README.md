# Spark_on_HPC_cluster
This repository describes all the steps necesaries to create a **multinode Spark standalone cluster (2.4.0)** within a PBS-job (we are going to give you two options). We have tested those scripts using EDDIE HPC cluster, hosted at Universtiy of Edinburgh.

# Download Spark
 	wget http://apache.mirrors.nublue.co.uk/spark/spark-2.4.0/spark-2.4.0-bin-hadoop2.7.tgz
	tar xvf spark-2.4.0-bin-hadoop2.7

# Copy the contain of this repository in your $HOME directory.

In your $HOME directory you need to have the following:
* spark-2.4.0-bin-hadoop2.7 directory
* bash_scripts
* spark_conf
* PBS-scripts for configuring the sparkcluster: sparkcluster_and_driver.job, sparkcluster.job
* PBS-scripts for submmitng spark applications/queries: spark-driver-Pi.job, spark-driver-textming.job
* scripts for running spark applications: spark-interactive-textming.sh, spark-interactive-Pi.sh, spark-Pi.sh, spark-textming.sh
* script for stopping spark cluster (no needed): spark_stop.sh

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

* **Option 1**: This PBS-job starts the master, workers, and the driver. The driver submits a Spark Application/query to the Spark cluster once is running.

  		qsub sparkcluster_and_driver.job

Note: In this option we have already configured the driver to submit a Spark text-mining query to the Spark Cluster using  the **spark-textming.sh** script. If you want to change the query or submit another application ( e.g. spark-Pi.sh), you just need to modify/replace this script. 

* **Option 2**:This PBS-job starts the master and workers. For submitting Spark Applications/Queries to the Spark Cluster we need to do it via: a) another PBS-job (e.g. spark-driver-textming.job) ; b) interactive session ( e.g. spark-interactive-textming.sh) 

                qsub sparkcluster.job

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
		
			


