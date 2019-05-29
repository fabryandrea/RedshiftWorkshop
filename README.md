
# Redshift Workskop 

In this workshop you will learn how to launch a Redshift cluster, create tables using the appropriate distribution styles, load data from S3, prepare the Redshift cluster to query data on S3 using Redshift Spectrum and build queries that will access data in Redshift and also Data Lake using Redshift Spectrum. 


## Table of Contents 

1. Lauching a Redshift Cluster 
2. Installing client tool to connect to Redshift Cluster
3. Connecting to your Redshift Cluster
4. Creating Tables on Redshift 
5. Loading Data into Redshift Cluster 
6. Creating Tables using the right distribution style 
7. Querying local tableson Redshift 



### 1- Lauching a Redshift Cluster 

In this exercise, we will launch a Redshift Cluster in your account. Log into your AWS account using your credentials. After logging in; On AWS console main page, go to Services and select Amazon Redshift. Alternatively, type Redshift in the search field and choose Amazon Redshift when you see in the results returned. 

Alternatively, you can use a CloudFormation teample and skip this step in case you are already familiar with lauching a Redshift Cluster. In your AWS Console, go to CloudFormation. In the CloudFormation, choose Create Stack. In the Select Template choose to specify an Amazon S3 template URL and use the following S3 URL to launch a Redshift Cluster. 
[https://s3.amazonaws.com/bigdatalabshass/code/redshiftTemplate.json](https://s3.amazonaws.com/bigdatalabshass/code/redshiftTemplate.json)

On Specify Details, provide the Stack Name and Parameters required to launch the Redshift Cluster. After providing the Parameters, choose next. 


In the Options, Click Next 

In the Review, check to acknowledge the creation of IAM resources and click create. Wait a few minutes for the cluster to become available.  
### 2- Installing client tool to connect to Redshift Cluster 


You will need to install a client tool to connect on the Redshift Cluster. The following are some tools suggested. Please feel free to use any tool you prefer.

* [DB Beaver](https://dbeaver.io/download/)
* [WorkbenchJ](https://www.sql-workbench.eu/downloads.html) 
* [Aginity - Windows Only](https://www.aginity.com/main/workbench-for-amazon-redshift/)


### 3- Connecting to your Redshift Cluster

On AWS console main page, go to Services and select Amazon Redshift. Alternatively, type Redshift in the search field and choose Amazon Redshift when you see in the results returned.
In the Redshift dashboard, choose Clusters and you should see your cluster listed and the current status. Choose your cluster to access Redshift cluster details and connections information. 

--TODO.. Add a picture of the AWs Console 

Copy the endpoint details and save it to connect on the cluster and run queries. `redshiftlab.c3jaizpfphoi.us-east-1.redshift.amazonaws.com:5439`

You may need the JDBC URL depending on the tool you are using to connect to the Redshift Cluster. Scroll down on the same page and look for JDBC URL.  

JDBC URL will look similar to the JDBC URK bellow; 
`jdbc:redshift://redshiftlab.c3jaizpfphoi.us-east-1.redshift.amazonaws.com:5439/redshiftlab`

Use the connection information you just captured to access your cluster. 

Credentials to log into the Redshift cluster. 
**Username:** rsuser 
**Password:**  yourpassword (password was defined in the CloudFormation step.)


### 4- Creating Tables on Redshift 

This exercise you will create the tables in Redshift using the proper distribution keys for fact tables and large dimensions. These table are based on TCP-H star schema commonly used for database/data warehouse benchmarking. In the next exercise, we will use COPY command to load approximately 10GB worth of data from a S3. At the end of this exercise, you should see the following tables created in your Redshift cluster.

The tables **lineitem** and **orders** contains the largest number of rows. 

•	customer 
•	lineitem;
•	nation; 
•	orders; 
•	part; 
•	partsupp;
•	supplier;


Please refer to the following link provided below to download the script that will be used to create the table definition for this exercise. 
Access the tables.sql file using the following s3 link. 
[Table Definition - tables.sql](https://s3.amazonaws.com/reinvent-hass/code/tables.sql)

Open the file `tables.sql` using your query editor of preference. The majority of client tools provide query editor and the ability to submit the query/script to Redshift. After opening the file, examine the `CREATE TABLE` commands. You should see distribution style key for tables lineitem and orders. For all the remaining tables, the distribution style will be set to ALL as they are small dimmensions tables. 



