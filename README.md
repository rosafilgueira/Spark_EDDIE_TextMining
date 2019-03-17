# Spark_on_HPC_cluster
This repository describes all the steps necesaries to create a **multinode Spark standalone cluster (2.4.0)** within a PBS-job (we are going to give you two options). We have tested those scripts using EDDIE HPC cluster, hosted at Universtiy of Edinburgh.

# Installation Steps

### Download Spark

 	wget http://apache.mirrors.nublue.co.uk/spark/spark-2.4.0/spark-2.4.0-bin-hadoop2.7.tgz
	tar xvf spark-2.4.0-bin-hadoop2.7

### Copy the contain of this repository in your $HOME directory

In your $HOME directory you need to have the following:
* spark-2.4.0-bin-hadoop2.7 directory
* bash_scripts
* spark_conf
* PBS-jobs for configuring the sparkcluster: sparkcluster_and_driver.job, sparkcluster.job
* PBS-jobs for submmitng spark applications/queries: spark-driver-Pi.job, spark-driver-textming.job
* scripts for running spark applications: spark-interactive-textmining.sh, spark-interactive-Pi.sh, spark-Pi.sh, spark-textmining.sh
* script for stopping spark cluster (no needed): spark_stop.sh

IDEA:
	
	cp -r spark_conf in your $HOME directory
	cp -r bash_scripts in your $HOME directory
	cp *.sh in your $HOME directory
	cp *.job in your $HOME directory


### Change the Spark configurable files
	
	cp spark_conf/* spark-2.4.0-bin-hadoop2.7/conf/.
	
A couple of changes will be needed inside the *spark-default.conf* script:
-  Create a tmp directory ( e.g. /exports/eddie/scratch/< UUN >/tmp) to store temporal spark files. Modify the *spark.local.dir* flag to point out this path.
-  Create a events directory (.e.g /home/eddie/scratch/< UUN >/events) to store the Spark events. Modify the *spark.eventLog.dir* flat to point tis path. 

 You might also want to configure more parameters inside *spark-defaults.conf* file (e.g. driver memory size of log directory).  
  
# Start a Spark cluster within a PBS job
We have two PBS jobs to provision a Spark Standalone Cluster (Figure 1) on-demand and for a specific period (e.g. 1 hour) of time. One PBS job (**Option 1**) sets up the Spark Cluster and the driver to submit a specific Spark application/Query and then it continues running for one hour, so more Spark application can be submitted later. And the other one (**Option 2**), just sets up the Spark Cluster (Master and Workers) and it doesnt submit any queries. 





## Spark Cluster and Driver (Option 1) 

The following PBS job starts a Spark master, Spark workers, and a driver. The driver submits a Spark Application/query to the Spark cluster once is running.

  		qsub sparkcluster_and_driver.job

Note: In this PBS job we have already configured a node to runs as the driver, which submits ( *spark-Pi.sh* script) a simple Spark Application (calculation of Pi). This Spark application comes within the Spark source code . If you want to change it to submit an Spark Text Mining query (e.g. *spark-textmining.sh*) or another application, you just need to modify/replace this script. 

## Spark Cluster only (Option 2)

The following PBS job starts a Spark master and workers. 

                qsub sparkcluster.job
		
For submitting later (once the Spark Cluster is running) Spark Applications/Queries to the Spark Cluster we need to do it via: a) another PBS-job (e.g. *spark-driver-textmining.job*, *spark-driver-Pi.job*) ; b) interactive session ( e.g. *spark-interactive-textmining.sh*, *spark-interactive-Pi.sh*) 		


## Generic comments for both options

You can modify both PBS-jobs as you wish for running more time (now it is configured to 1 hour) and for reserving more or less nodes for your spark cluster. In the current scipts, we have used 3 nodes: one node for running the master, and:

* in the case of the *sparkcluster_and_driver* job, 1 node for running the worker and 1 node for running the driver (, which submits inmidiately the Spark PI application to the Spark Master).

* in the case of the *sparkcluster* job, 2 nodes for running the workers.  


## Spark Master, Workers and Driver nodes

Once you have running your Spark Cluster, you can check which nodes have been asigned as Master, Worker(s) and Driver using the *master.log*, *worker.log*, and *driver.log* stored under the bash_scripts directory. 

Remember that if you used *sparkcluster.job* for setting up your cluster, you wont have a driver, therefore the driver.log wont exit. 

Furthermore, you can also check the Master and Worker(s) log files created (by default) inside $HOME/spark-2.4.0-bin-hadoop2.7/logs to see if everything has been started correctly. 

	ls spark-2.4.0-bin-hadoop2.7/logs/
		spark-rfilguei-org.apache.spark.deploy.master.Master-1-node1b31.ecdf.ed.ac.uk.out
		spark-rfilguei-org.apache.spark.deploy.worker.Worker-1-node1b26.ecdf.ed.ac.uk.out


# Submit spark applications to the Spark cluster

Once you have the spark cluster running ( your PBS job has been accepted and you have the resoureces available), you can submit spark applications to it.  We have configured our scripts in order to make use of *master.log*, so you dont have to type the master url yourself. And also, our scripts make use of the *worker.log* to calculate the number of cores available to run our Spark applications/queries. 

1) Submitting Spark-PI to Spark-Cluster from the login node: 
	1.1) Via a PBS-job which will act as the driver:
		qsub spark-driver-PI.job
	1.2 ) Via an interactive session - Important ( you need to request a session with at least 8GB of memory):
		 qlogin -l h_vmem=8G
		 ./spark-interactive-Pi.sh
		 
 	Note: Addtional information can be found at this [link](https://spark.apache.org/docs/latest/submitting-applications.html)

2) Submitting a TextMining query to the Spark-Cluster. This will requiere the following steps:
	2.1 ) Clone our TextMinging repository
	2.2) 
		
			


