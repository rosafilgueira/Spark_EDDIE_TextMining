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
* PBS-jobs for configuring the sparkcluster: sparkcluster_and_driver.job, sparkcluster.job
* PBS-jobs for submmitng spark applications/queries: spark-driver-Pi.job, spark-driver-textming.job
* scripts for running spark applications: spark-interactive-textming.sh, spark-interactive-Pi.sh, spark-Pi.sh, spark-textming.sh
* script for stopping spark cluster (no needed): spark_stop.sh

IDEA:
	
	cp -r spark_conf in your $HOME directory
	cp -r bash_scripts in your $HOME directory
	cp *.sh in your $HOME directory
	cp *.job in your $HOME directory


# Change the Spark configurable files
	
	cp spark_conf/* spark-2.4.0-bin-hadoop2.7/conf/.
	
A couple of changes will be needed inside the spark-default.conf script:
-  Create a tmp directory ( e.g. /exports/eddie/scratch/< UUN >/tmp) to store temporal spark files. Modify the *spark.local.dir* flag to point out this path.
-  Create a events directory (.e.g /home/eddie/scratch/< UUN >/events) to store the Spark events. Modify the *spark.eventLog.dir* flat to point tis path. 

 You might also want to configure more parameters inside spark-defaults.conf file (e.g. driver memory size of log directory).  
  
# Start a Spark cluster within a PBS job
We have two PBS-jobs to provision on-demand and for a specific period (1 hour) of time the desired spark cluster. 

* **Option 1**: This PBS-job starts the master, workers, and the driver. The driver submits a Spark Application/query to the Spark cluster once is running.

  		qsub sparkcluster_and_driver.job

Note: In this option we have already configured the driver to submit a simple Spark Application (calculation of Pi) tha comes with the Spark source code using  the **spark-Pi.sh** script. If you want to change a Spark Text Mining query (e.g. spark-textminingh.sh) or submit another application, you just need to modify/replace this script. 

* **Option 2**:This PBS-job starts the master and workers. For submitting Spark Applications/Queries to the Spark Cluster we need to do it via: a) another PBS-job (e.g. spark-driver-textming.job) ; b) interactive session ( e.g. spark-interactive-textming.sh) 

                qsub sparkcluster.job

You can modify both PBS-job as you wish for running more time (now it is configured to 1 hour) and for reserving more or less nodes for your spark cluster. In the current scipts, we have used 3 nodes: one node for running the master, and:

* in the case of the *sparkcluster_and_driver* job, 1 node for running the worker and 1 node for running the driver.
* in the case of the *sparkcluster* job, 2 nodes for running the workers.  


## Master, Workers and Driver nodes. 

If you have started a Spark Cluster using *sparkcluster_and_driver.job*, once is running, you can check which nodes have been asigned as Master, Worker(s) and Driver using the master.log, worker.log, and driver.log stored under the bash_scripts directory. And if you have used the *sparkcluster.job* instead, you will be also be able to check the master and workers inside the same directory. Note that in this last case, you wont have a driver.log file, since this PBS-job doesnt start a driver. 

Furthermore, you can also check the Master and Woerker log files created (by default) inside $HOME/spark-2.4.0-bin-hadoop2.7/logs to see if everything has been started correctly. 

	ls spark-2.4.0-bin-hadoop2.7/logs/
		spark-rfilguei-org.apache.spark.deploy.master.Master-1-node1b31.ecdf.ed.ac.uk.out
		spark-rfilguei-org.apache.spark.deploy.worker.Worker-1-node1b26.ecdf.ed.ac.uk.out


# Submit spark applications to the Spark cluster

Once you have the spark cluster running ( your PBS job has been accepted and you have the resoureces available), you can submit spark applications to it. 

1) Submitting Spark-PI to Spark-Cluster from the login node: 
	1.1) Via a PBS-job which will act as the driver:
		qsub spark-driver-PI.job
	1.2 ) Via an interactive session - Important ( you need to request a session with at least 8GB of memory):
		 qlogin -l h_vmem=8G
		 ./spark-interactive-Pi.sh

2) Submitting a TextMining query to the Spark-Cluster. This will requiere the following steps:
	2.1 ) Clone our TextMinging repository
	2.2) 
		
			


