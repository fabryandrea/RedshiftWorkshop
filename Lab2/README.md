# LAB 2 - Creating Tables on Redshift
In this Lab you will create the tables in the Amazon Redshift Cluster using the proper distribution keys for fact and dimensions tables that will allow you to get the most of Massive Paralallel processing system in Amazon Redshift. 
These tables are based on TCP-H star schema, commonly used for database/data warehouse benchmarking. In the next Lab, we will use COPY command to load approximately 10GB worth of data from a S3 bucket. At the end of this Lab, you should see the following tables created in your Redshift cluster.

## Contents
  - [Accessing the Create table script](#accessing-the-create-table-script)


## Accessing the Create table script 

The tables **lineitem** and **orders** contains the largest number of rows. 

•	`customer`   
•	`lineitem`  
•	`nation`  
•	`orders`  
•	`part`  
•	`partsupp`  
•	`supplier`  


Please refer to the following link provided below to download the script that will be used to create the table definition for this exercise. 
Access the tables.sql file using the following s3 link. 
[Table Definition - tables.sql](https://s3.amazonaws.com/reinvent-hass/code/tables.sql)


Open the file `tables.sql` using your query editor of preference. The majority of client tools provide query editor and the ability to submit queries or scripts to Redshift. After opening the file, examine the `CREATE TABLE` commands; you should see distribution style key for tables `lineitem` and `orders`. For all the remaining tables, the distribution style will be set to ALL as they are small dimmensions tables. It means that tables `lineitem` and `orders` will have a specific collumn that will be the distribution key so the data can be hashed and distributed evenly across all nodes and slices. The distribution ALL means there will be a copy of the table in all the nodes. The reason for this is to avoid data movement between the nodes. When you join a fact and dimmention tables, the query processing will happen local at the node. 

Copy the CREATE TABLE commands and execute one at the time using your the client tool of your preference. You can also use the Query Editor available in the Amazon Redshift consome. 


