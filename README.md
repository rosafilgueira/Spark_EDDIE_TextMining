# Spark on EDDIE
This repository describes all the steps necesaries to create a **multinode Spark standalone cluster** (version 2.4.0) within a SGE-job. It has been tested using the [EDDIE HPC cluster](https://www.ed.ac.uk/information-services/research-support/research-computing/ecdf/high-performance-computing), hosted at Universtiy of Edinburgh. This repository also presents several Spark applications to be launched using the Spark cluster.

# Installation Steps

### Download Spark 2.4.0

 	wget http://apache.mirrors.nublue.co.uk/spark/spark-2.4.0/spark-2.4.0-bin-hadoop2.7.tgz
	tar xvf spark-2.4.0-bin-hadoop2.7

### Copy all this repository in your $HOME directory

In your $HOME you need to have the following:
* spark-2.4.0-bin-hadoop2.7 
* bash_scripts
* spark_conf
* SGE-jobs for provisioning the Spark cluster: sparkcluster_and_driver.job, sparkcluster.job
* SGE-jobs for launching Spark applications/queries: spark-driver-Pi.job, spark-driver-textmining.job
* Scripts for launching Spark applications: spark-interactive-textmining.sh, spark-interactive-Pi.sh, spark-Pi.sh, spark-textmining.sh
* Script for stopping Spark cluster (usually no needed): spark_stop.sh

IDEA:
	
	cp -r spark_conf in your $HOME directory
	cp -r bash_scripts in your $HOME directory
	cp *.sh in your $HOME directory
	cp *.job in your $HOME directory


### Change the Spark configurable files
	
	cp spark_conf/* spark-2.4.0-bin-hadoop2.7/conf/.
	
**Important**: A couple of changes are needed in the *spark-default.conf* file (which is stored inside *spark_conf* directory) in order to have Spark successfully installed into your EDDIE account:
-  Create first a tmp directory ( e.g. /exports/eddie/scratch/< UUN >/tmp) to store temporal spark files. Modify later the *spark.local.dir* variable to point out this path.
-  Create first events directory (.e.g /home/eddie/scratch/< UUN >/events) to store the Spark events. Modify later the *spark.eventLog.dir* variable to point this path. 

 You might also want to configure another parameters inside *spark-defaults.conf* file (e.g. driver memory size, or the location of the log directory).  
  
# Start a Spark cluster within a PBS job

This repository has two options (via two different SGE jobs) to provision on-demand and for a specific period of time (e.g. 1 hour) the following Spark Standalone Cluster ![SparkCluster Architecture](https://github.com/rosafilgueira/Spark_EDDIE_TextMining/blob/master/Figures/SparkCluster_Architecture.png).

Spark applications/queries are run as independent sets of processes, coordinated by a SparkContext in a driver program. The Spark applications/queries have been set up to be run in *cluster mode*. This means, that the application code is sent from the *driver* to the *executors*, and the executors specifiy the *context* and the various *tasks* to be run.

The first SGE job (**Option 1**) sets up the Spark cluster (master and workers) and the driver to submit a specific Spark application/query. Then it continues running for one hour, so more Spark applications can be submitted later. While the second SGE job (**Option 2**), just sets up the Spark cluster (master and workers) and it doesnt submit any queries - we dont have a driver in this case. 

For more information about Spark, you could check the following [Prace course](https://github.com/EPCCed/prace-spark-for-data-scientists/tree/master/presentations).

## Spark Cluster and Driver (Option 1) 

The following SGE job starts a Spark master, Spark workers, and a driver. The driver submits automatically a Spark application/query to the Spark cluster once is running.

  		qsub sparkcluster_and_driver.job

Note: This SGE job configures a node to run as the driver, which launches ( *spark-Pi.sh* script) a simple Spark application (calculation of Pi). The *Spark Pi* application comes within the Spark source code . If you want to change the PBS job to launch an Spark text mining query (e.g. *spark-textmining.sh*) or another Spark application, you just need to modify/replace this script. 

## Spark Cluster only (Option 2)

The following SGE job starts a Spark master and workers. 

                qsub sparkcluster.job
		
Once this SGE has been accepted and you have the resoureces available, you can launch Spark applications/queries to the Spark cluster. And you can do this either with  another SGE-job (e.g. *spark-driver-textmining.job*, *spark-driver-Pi.job*) ; or with an interactive session ( e.g. *spark-interactive-textmining.sh*, *spark-interactive-Pi.sh*) 		


## Generic comments for both options

You can modify both SGE-jobs as you wish for running the cluster for more time (now they are configured to 1 hour) and for reserving more or less nodes for your spark cluster. In the current scripts, we have used 3 nodes. One node for running the master, and:

- in the case of the *sparkcluster_and_driver* job: one node for running the worker and one node for running the driver (, which submits inmidiately the Spark PI application to the Spark Master).

- in the case of the *sparkcluster* job: two nodes for running the workers.  


## Spark Master, Workers and Driver nodes

Once you have running your Spark cluster (your SGE job has been accepted and you have the resoureces available), you can check which nodes have been asigned as master, worker(s) and driver using the information stored in *master.log*, *worker.log*, and *driver.log* files (under *bash_scripts* directory). 

Remember that if you used *sparkcluster.job*, you wont have a driver, therefore the *driver.log* wont exit. 

Furthermore, you can also check the master and worker(s) log files created (by default) inside *$HOME/spark-2.4.0-bin-hadoop2.7/logs* directory to see if everything have been started correctly. 

	ls spark-2.4.0-bin-hadoop2.7/logs/
		spark-rfilguei-org.apache.spark.deploy.master.Master-1-node1b31.ecdf.ed.ac.uk.out
		spark-rfilguei-org.apache.spark.deploy.worker.Worker-1-node1b26.ecdf.ed.ac.uk.out


# Launching Spark Applications

We can launch Spark applications using the *bin/spark-submit* script. This script takes care of setting up the classpath with Spark and its dependencies, and can support different cluster managers and deploy modes that Spark supports:

	./bin/spark-submit \
 	 --class <main-class> \
  	--master <master-url> \
  	--deploy-mode <deploy-mode> \
  	--conf <key>=<value> \
  	--total-executor-cores <total number of cores avaiable among all the worker>
  	... # other options
  	<application-jar> \
  	[application-arguments]

We have configured all of our PBS jobs and Spark scripts to detect automatically the *master-url* (using the *master.log* file) and the total number of cores available (using *worker.log*), you dont have to type them yourself in the *bin/spark-submit*.   

### Launching the *Spark-Pi* Application

Via a SGE-job, which acts as the driver:

	qsub spark-driver-Pi.job

Via an interactive session - Important ( you need to request a session with at least 8GB of memory):
	
	qlogin -l h_vmem=8G
	./spark-interactive-Pi.sh
	
Both, *spark-driver-Pi.job* and *spark-interactive-Pi.sh*, scripts upload the necessaries modules and JAVA configuration automatically:

	export _JAVA_OPTIONS='-Xmx128M -Xmx4G'
	module load java
	module load python/2.7.10 
		 
The result of the Spark-Pi application is store in the redirected *output.txt file* ![file](https://github.com/rosafilgueira/Spark_EDDIE_TextMining/blob/master/Figures/OutputPi.png)


Note: Addtional information can be found at this [link](https://spark.apache.org/docs/latest/submitting-applications.html)

### Launching a Spark Text Mining Query

[Defoe](https://github.com/alan-turing-institute/defoe) repository contains code to analyse historical books and newspapers datasets using Apache Spark. Thefore, the first step is to clone it into your $HOME

	git clone https://github.com/alan-turing-institute/defoe.git

Once cloned, the second step is to get the necesary data ( e.g. /sg/datastore/lib/groups/lac-store/blpaper/xmls) in EDDIE. For testing, I created a  directory, called *blpaper*, inside my personal scratch space (/exports/eddie/scratch/< UUN >/blpaper). Note that, if you do not have access to the *sg* datastore, you could download this [xml file](https://github.com/alan-turing-institute/i_newspaper_rods/blob/epcc-master/newsrods/test/fixtures/2000_04_24.xml) into your personal scratch directory and use it for testing.

Before submitting a text mining query you will need to zip up the **defoe** source code (Spark needs this to run the query). More information at this [link](https://github.com/alan-turing-institute/defoe/blob/master/docs/run-queries.md).

		zip -r defoe.zip defoe

And later, you will to indicate which data (newspapers) you want to use for running a query over. For doing so, you need to create a plain-text file (e.g. data.txt) with a list of the paths to the data files to query. This file will be stored at the same level than *defoe.zip*. More information at this [link](https://github.com/alan-turing-institute/defoe/blob/master/docs/specify-data-to-query.md).

	 	find /exports/eddie/scratch/< UUN >/blpaper -name "*.xml" > data.txt
		
Thefore, your defoe code in EDDIE, before submitting/running any query should look like 

![this](https://github.com/rosafilgueira/Spark_EDDIE_TextMining/blob/master/Figures/defoe_code_2.png)

After these two steps, you are now ready to launch a text-minining query to the Spark cluster. We have many text mining queries inside defoe, but here we have used [keyword_by_year](https://github.com/alan-turing-institute/defoe/blob/master/docs/papers/keyword_by_year.md) and [total_words](https://github.com/alan-turing-institute/defoe/blob/master/docs/papers/total_words.md). We have prepared two scripts for doing that, and it will be very easy to modify these scripts to run another query. 

As we explained before, you can run a Spark query using two options:
  - Via a SGE-job, which acts as the dirver. This SGE job lanunches the **keyword_by_year**  query, using the specified  newspapers inside the *data.txt*:
		
		qsub spark-driver-textmining.job 
		
   - Via an interactive session - Important ( you need to request a session with at least 8GB of memory). The *spark-interactive-textmining.sh*, launches the **total_words** using the specified newspapers inside *data.txt*
		
			qlogin -l h_vmem=8G
			./spark-interactive-textmining.sh
			
Note: Both, *spark-driver-textmining.job* and *spark-interactive-textmining* scripts, upload the necessaries modules and JAVA configuration automatically:

	export _JAVA_OPTIONS='-Xmx128M -Xmx4G'
	module load java
	module load python/2.7.10 
		
The results of any of these queries are stored in the *results.yml* 

![file](https://github.com/rosafilgueira/Spark_EDDIE_TextMining/blob/master/Figures/defoe_code_results.png)

And you can follow the execution of an Spark query by checking the redirected file *query_job.txt*, where the outputs of the Spark query are stored in runtime. 

If you want to run a different text mining query, you just need to modify any of the previous scripts, indicating the path of the query to use, and the argurments (if they are needed). 

All the required information for submitting *Defoe text mining queries* can be found at this [link](https://github.com/alan-turing-institute/defoe/tree/master/docs). 			

# Monitoring the Spark Cluster and Applications/queries via UIs

Spark offers different UIs to monitor the Spark master, workers and driver (running an Spark application/query). The only thing is needed is to create the proper ssh bridges. For doing that, you will need to check the URLS of the master ( e.g. opening *master.log* ), workers (e.g. opening *worker.log*), and driver (e.g. opening *driver.log* or checking with *qstat* in which node is running your spark-driver-textmining.job). 

Once you have these URLs of these three nodes, you just need to do the following
- Spark cluster UI 
	– New terminal console: ssh UUN@eddie3.ecdf.ed.ac.uk -L8080:MASTER-URL:8080 
	- Web browser window: localhost://8080
	
	![Spark Master UI](https://github.com/rosafilgueira/Spark_EDDIE_TextMining/blob/master/Figures/SparkClusterUI.png)
	
- Spark worker UI
	– New terminal console: ssh UUN@eddie3.ecdf.ed.ac.uk -L8081:WORKER-URL:8081
	- Web browser window: localhost://8081
	
	![Spark Worker UI](https://github.com/rosafilgueira/Spark_EDDIE_TextMining/blob/master/Figures/SparkWorkerUI.png)

- Application (Driver) UI 
	- New terminal console: ssh UUN@eddie3.ecdf.ed.ac.uk -L4040:DRIVER-URL:4040  (This one only works while the application is running in the Spark cluster)
	- Web browser window: localhost://4040
	
	![Spark Driver UI](https://github.com/rosafilgueira/Spark_EDDIE_TextMining/blob/master/Figures/ApplicationUI-1.png)
	

