# Spark_on_HPC_cluster
This repository describes all the steps necesaries to create a **multinode Spark standalone cluster** (version 2.4.0) within a PBS-job. We have tested those scripts using the [EDDIE HPC cluster](https://www.ed.ac.uk/information-services/research-support/research-computing/ecdf/high-performance-computing), hosted at Universtiy of Edinburgh.

# Installation Steps

### Download Spark

 	wget http://apache.mirrors.nublue.co.uk/spark/spark-2.4.0/spark-2.4.0-bin-hadoop2.7.tgz
	tar xvf spark-2.4.0-bin-hadoop2.7

### Copy the scripts and folders of this repository in your $HOME directory

In your $HOME directory you need to have the following:
* spark-2.4.0-bin-hadoop2.7 directory
* bash_scripts
* spark_conf
* PBS-jobs for configuring the Spark Cluster: sparkcluster_and_driver.job, sparkcluster.job
* PBS-jobs for submmitng Spark applications/queries: spark-driver-Pi.job, spark-driver-textming.job
* Scripts for running Spark applications: spark-interactive-textmining.sh, spark-interactive-Pi.sh, spark-Pi.sh, spark-textmining.sh
* Script for stopping spark cluster (usually no needed): spark_stop.sh

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
We have two PBS jobs to provision on-demand for a specific period of time (e.g. 1 hour) the following Spark Standalone Cluster ![SparkCluster Architecture](https://github.com/rosafilgueira/Spark_EDDIE_TextMining/blob/master/Figures/SparkCluster_Architecture.png). 

The first PBS job (**Option 1**) sets up the Spark Cluster (Master and Workers) and the driver to submit a specific Spark application/Query and then it continues running for one hour, so more Spark applications can be submitted later. While the second PBS job (**Option 2**), just sets up the Spark Cluster (Master and Workers) and it doesnt submit any queries - we dont have a driver in this case. 

## Spark Cluster and Driver (Option 1) 

The following PBS job starts a Spark master, Spark workers, and a driver. The driver submits automatically a Spark Application/query to the Spark cluster once is running.

  		qsub sparkcluster_and_driver.job

Note: In this PBS job we have already configured a node to runs as the driver, which launches ( *spark-Pi.sh* script) a simple Spark Application (calculation of Pi). The *Spark Pi* application comes within the Spark source code . If you want to change the PBS to launch an Spark Text Mining query (e.g. *spark-textmining.sh*) or another Spark application, you just need to modify/replace this script. 

## Spark Cluster only (Option 2)

The following PBS job starts a Spark master and workers. 

                qsub sparkcluster.job
		
Once this PBS been accepted and you have the resoureces available, you can launch Spark Applications/Queries to the Spark Cluster. And you can do this either with  another PBS-job (e.g. *spark-driver-textmining.job*, *spark-driver-Pi.job*) ; or with an interactive session ( e.g. *spark-interactive-textmining.sh*, *spark-interactive-Pi.sh*) 		


## Generic comments for both options

You can modify both PBS-jobs as you wish for running more time (now they are configured to 1 hour) and for reserving more or less nodes for your spark cluster. In the current scipts, we have used 3 nodes. One node for running the master, and:

- in the case of the *sparkcluster_and_driver* job, 1 node for running the worker and 1 node for running the driver (, which submits inmidiately the Spark PI application to the Spark Master).

- in the case of the *sparkcluster* job, 2 nodes for running the workers.  


## Spark Master, Workers and Driver nodes

Once you have running your Spark Cluster (your PBS job has been accepted and you have the resoureces available), you can check which nodes have been asigned as Master, Worker(s) and Driver using the *master.log*, *worker.log*, and *driver.log* stored under the *bash_scripts* directory. 

Remember that if you used *sparkcluster.job* for setting up your cluster, you wont have a driver, therefore the *driver.log* wont exit. 

Furthermore, you can also check the Master and Worker(s) log files created (by default) inside $HOME/spark-2.4.0-bin-hadoop2.7/logs to see if everything have been started correctly. 

	ls spark-2.4.0-bin-hadoop2.7/logs/
		spark-rfilguei-org.apache.spark.deploy.master.Master-1-node1b31.ecdf.ed.ac.uk.out
		spark-rfilguei-org.apache.spark.deploy.worker.Worker-1-node1b26.ecdf.ed.ac.uk.out


# Launching Spark applications to the Spark cluster


We can be launch Spark applications using the *bin/spark-submit* script. This script takes care of setting up the classpath with Spark and its dependencies, and can support different cluster managers and deploy modes that Spark supports:

	./bin/spark-submit \
 	 --class <main-class> \
  	--master <master-url> \
  	--deploy-mode <deploy-mode> \
  	--conf <key>=<value> \
  	--total-executor-cores <total number of cores avaiable among all the worker>
  	... # other options
  	<application-jar> \
  	[application-arguments]


We have configured all of our PBS jobs and spark scripts to detect automatically the *master-url* (using the *master.log* file) and the total number of cores available (using *worker.log*), you dont have to type them yourself in the *bin/spark-submit*.  

### Submitting Spark-Pi to Spark-Cluster from the login node: 

Via a PBS-job, which acts as the driver:

	qsub spark-driver-Pi.job

Via an interactive session - Important ( you need to request a session with at least 8GB of memory):
	
	qlogin -l h_vmem=8G
	./spark-interactive-Pi.sh
		 

Note: Addtional information can be found at this [link](https://spark.apache.org/docs/latest/submitting-applications.html)

### Submitting a TextMining query to the Spark-Cluster. This will requiere the following steps:

The [defoe](https://github.com/alan-turing-institute/defoe) GitHub repository contains code to analyse historical books and newspapers datasets using Apache Spark. Thefore, the first step is to clone it into your $HOME

	git clone https://github.com/alan-turing-institute/defoe.git

Once cloned, the second step is to get the necesary data ( e.g. /sg/datastore/lib/groups/lac-store/blpaper/xmls) in your scratch directory ( e.g. /exports/eddie/scratch/< UUN >/blpaper) inside EDDIE. 

Before submitting a query you will need to Zip up the defoe source code (Spark needs this to run the query). More information at this [link](https://github.com/alan-turing-institute/defoe/blob/master/docs/run-queries.md).

		zip -r defoe.zip defoe

And later, you will to indicate which data (newspapers) which you want to run a query over. For doing so, you need to create a plain-text file (e.g. data.txt) with a list of the paths to the data files to query. More information at this [link](https://github.com/alan-turing-institute/defoe/blob/master/docs/specify-data-to-query.md).

	 	find /exports/eddie/scratch/< UUN >/blpaper -name "*.xml" > data.txt
	 
After these two steps, you are now ready to submit a text-minining query to the Spark Cluster. For example, you could run [keyword_by_year](https://github.com/alan-turing-institute/defoe/blob/master/docs/papers/keyword_by_year.md)  or [total_words](https://github.com/alan-turing-institute/defoe/blob/master/docs/papers/total_words.md) queries. We have prepared two scripts for doing that:

  - Via a PBS-job, which acts as the dirver. This PBS job lanunches the **keyword_by_year** Spark query to the Spark Cluster, using the specified xmls newspapers inside the *data.txt*:
		
		qsub spark-driver-textmining.job 
		
   - Via an interactive session - Important ( you need to request a session with at least 8GB of memory). The *spark-interactive-textmining.sh*, launches the **total_words** to the Spark Cluster using the specified xmls newspapers inside *data.txt*
		
			qlogin -l h_vmem=8G
			./spark-interactive-textmining.sh
		
		
All the required information for submitting different Text Mining queries can be found at this [link](https://github.com/alan-turing-institute/defoe/tree/master/docs). 			

# Monitoring the Spark Cluster and Applications/queries via UIs

Spark offers different UIs to monitor the Spark Master, Workers and Driver (running an Spark Application/query). The only thing is needed is to create the proper bridges in your cluster. For doing that, you will need to check the URLS of the master ( e.g. opening *master.log* ), workers (e.g. opening *worker.log*), and driver (e.g. opening *driver.log* or checking in which node is running your spark-driver-textmining.job). 

Once you have these 3 nodes, you just need to:

- Spark Cluster UI – port 8080 – bridge: 

	ssh UUN@eddie3.ecdf.ed.ac.uk -L8080:MASTER-URL:8080
	
	![Spark Master UI]*https://github.com/rosafilgueira/Spark_EDDIE_TextMining/blob/master/Figures/SparkClusterUI.png)
	
- Spark Worker UI – port 8081 – bridge: 

	ssh UUN@eddie3.ecdf.ed.ac.uk -L8081:WORKER-URL:8081
	
	![Spark Worker UI](https://github.com/rosafilgueira/Spark_EDDIE_TextMining/blob/master/Figures/SparkWorkerUI.png)

- Application (Driver) UI – port 4040 – bridge:

	ssh UUN@eddie3.ecdf.ed.ac.uk -L4040:DRIVER-URL:4040
	
	![Spark Driver UI](https://github.com/rosafilgueira/Spark_EDDIE_TextMining/blob/master/Figures/ApplicationUI-1.png)

