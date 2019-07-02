
# Redshift Workskop 

In this workshop you will learn how to launch a Redshift cluster, create tables using the appropriate distribution styles, load data from S3, prepare the Redshift cluster to query data on S3 using Redshift Spectrum and build queries that will access data in Redshift and also Data Lake using Redshift Spectrum. 


## Table of Contents 

1. Lauching a Redshift Cluster 
2. Installing client tool to connect to Redshift Cluster
3. Connecting to your Redshift Cluster
4. Creating Tables on Redshift 
5. Loading Data into Redshift Cluster 
6. Querying local tables on Redshift 
7. Querying S3 Data Lake using Redshift Spectrum 
8. Redshift IAM Role



### 1- Lauching a Redshift Cluster 

In this exercise, we will launch a Redshift Cluster in your account. Log into your AWS account using your credentials. After logging in; On AWS console main page, go to Services and select Amazon Redshift. Alternatively, type Redshift in the search field and choose Amazon Redshift when you see in the results returned. 

Alternatively, you can use a CloudFormation teample and skip this step in case you are already familiar with lauching a Redshift.
For better performance and avoid high cost transfer between Amazon Redshift cluster  and S3, make sure you are in the US-EAST-1 region.
Cluster. In your AWS Console, go to CloudFormation. In the CloudFormation, choose Create Stack. In the Select Template choose to specify an Amazon S3 template URL and use the following S3 URL to launch a Redshift Cluster. 
[https://s3.amazonaws.com/reinvent-hass/code/redshiftTemplate.json](https://s3.amazonaws.com/reinvent-hass/code/redshiftTemplate.json)

On Specify Details, provide the Stack Name and Parameters required to launch the Redshift Cluster. After providing the Parameters, choose next. 


In the Options, Click Next 

In the Review, check to acknowledge the creation of IAM resources and click create. Wait a few minutes for the cluster to become available.  
### 2- Installing client tool to connect to Redshift Cluster 


You will need to install a client tool to be able to connect on the Redshift Cluster. The following client tools are suggested for this Lab. Please feel free to use any tool you prefer. If you are familiar with Postgres command line client tool (psql), you can also use as your client. 

* [DB Beaver](https://dbeaver.io/download/)
* [WorkbenchJ](https://www.sql-workbench.eu/downloads.html) 
* [Aginity - Windows Only](https://www.aginity.com/main/workbench-for-amazon-redshift/)


### 3- Connecting to your Redshift Cluster

On AWS console main page, go to Services and select Amazon Redshift. Alternatively, type Redshift in the search field and choose Amazon Redshift when you see in the results returned.
In the Redshift dashboard, choose Clusters and you should see your cluster recently created listed and the current status. Choose your cluster to access Redshift cluster details and connections information. 

![alt text](https://github.com/andrehass/RedshiftWorkshop/blob/master/Images/Redshift_WS_Console.jpg "Logo Title Text 1")

Copy the endpoint details and save it to connect on the cluster and run queries. The endpoint will look similar to this one `redshiftday.xxxxxxxxxx.us-east-1.redshift.amazonaws.com:5439`

You may need the JDBC URL depending on the tool you are using to connect to the Redshift Cluster. Scroll down on the same page and look for JDBC URL.  

JDBC URL will look similar to the JDBC URK bellow; 
`jdbc:redshift://redshiftday.xxxxxxxxxx.us-east-1.redshift.amazonaws.com:5439/dev`

Use the connection information you just captured to access your cluster. 

Credentials to log into the Redshift cluster. 
**Username:** `user name` (user name you defined in the CloudFormation step.)
**Password:**  `password` (password you defined in the CloudFormation step.)


### 4- Creating Tables on Redshift 

In this Lab you will create the tables in the Amazon Redshift Cluster using the proper distribution keys for fact and large dimensions tables. These tables are based on TCP-H star schema, commonly used for database/data warehouse benchmarking. In the next Lab, we will use COPY command to load approximately 10GB worth of data from a S3 bucket. At the end of this Lab, you should see the following tables created in your Redshift cluster.

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

Open the file `tables.sql` using your query editor of preference. The majority of client tools provide query editor and the ability to submit the query/script to Redshift. After opening the file, examine the `CREATE TABLE` commands. You should see distribution style key for tables lineitem and orders. For all the remaining tables, the distribution style will be set to ALL as they are small dimmensions tables. 

### 4- Loading Data into Redshift Cluster 

You are now ready to load data into Redshift cluster. We will load approxemately 10GB worth of data from a S3 location. The bucket is in US-EAST-1 region. For better performance and avoid high cost transfer, make sure your Redshift cluster is in the same region as the S3 bucket.

Please refer to the following link provided below to download the script that will be used to load data into Redshift using the COPY command. 
Access the copy.sql file using the following s3 link. 
[COPY Command - copy.sql](https://s3.amazonaws.com/reinvent-hass/code/copy.sql)

After downloading the `copy.sql` file, open the file using the client tool of your choice and execute the copy statements against your Redshift cluster. 
**`Important step`**, replace 'iam_role' with the IAM role assigned to your Redshift cluster in all the COPY commands in your script. (see COPY command example bellow) 

```sql
COPY nation FROM 's3://reinvent-hass/redshiftdata//nation/nation_'
iam_role 'arn:aws:iam::xxxxxxxxxxxx:role/MyRedshiftRole'
gzip delimiter '|'
IGNOREHEADER 1;
```
If you need instructions on how to retrieve the iam_role assigned to your redshift cluster, please refer to `Redshift IAM Roles` section. 

**Load times and # of rows**
•	customer ==>  aprox 1 minute – 15M rows  
•	lineitem ==>  aprox  25 Minutes, 600M rows  
•	nation;  ==>  N/A  
•	orders;  ==>  aprox 5 minutes, 150M rows   
•	part;    ==>  aprox 1 minute, 20M rows  
•	partsupp; ==> aprox 3 minutes, 80M rows  
•	supplier; ==> aprox 30 seconds, 1 rows  
•	region;       5 records  

Execute each COPY command individually. Tables `lineitem` and `orders` will take longer. 
You can monitor the load status by either using AWS Console or running a query on **`STV_LOAD_STATE`** table. 

Connect to the Redshift Cluster using a different session while you COPY command executes to check the COPY state. 

```sql
/* Check load state */
select query, slice ,bytes_loaded, bytes_to_load, lines, num_files,  pct_complete from stv_load_state;
```

| slice | bytes_loaded | bytes_to_load | pct_complete 
|-------|--------------|---------------|--------------
|     2 |            0 |             0 |            0
|     3 |     12840898 |      39104640 |           32
(2 rows)

When you finish executing the `CREATE TABLE` script, execute the following command to check the tables created in Redshift. Look for the columns `diststyle` for the distribution style defined for your table. 

```sql
select "table", encoded, diststyle, sortkey1, skew_sortkey1, skew_rows
from svv_table_info
order by 1;
```





### 5- Querying local tables on Redshift 

First, you will execute some queries to get table definition details such as table information and distribution style define on the tables. Redshift is a Massive Parallel processing Data Warehouse System and uses multiple nodes to process the queries depending on the distribution style selected. 

Run the following query to get details on the number of nodes and slices in your Redshift cluster. The Query will return details on number of nodes and slices in your Redshift Cluster. In this Lab, you should expect a total of 4 slices. Your Amazon Redshift cluster type is dc2.xlarge with 2 compute nodes. 

```sql
SELECT * FROM STV_SLICES;
```

Run the query bellow to retrieve table definition details such as distribution style, sort key, compression enconding algorithms, and number of rows. 

```sql
SELECT "schema", "table", diststyle, sortkey1, encoded, tbl_rows FROM SVV_TABLE_INFO
WHERE "schema" = 'public';
```
**Redshift distribution Styles** 

**Even**  
The leader node distributes the rows across the slices in a round-robin fashion, regardless of the values in any particular column. EVEN distribution is appropriate when a table does not participate in joins or when there is not a clear choice between KEY distribution and ALL distribution.  


**Key**  
The rows are distributed according to the values in one column. The leader node places matching values on the same node slice. If you distribute a pair of tables on the joining keys, the leader node collocates the rows on the slices according to the values in the joining columns so that matching values from the common columns are physically stored together.  

**ALL**  
A copy of the entire table is distributed to every node. Where EVEN distribution or KEY distribution place only a portion of a table's rows on each node, ALL distribution ensures that every row is collocated for every join that the table participates in.
Query below shows the number of rows distributed across the Redshift cluster nodes and slices. For tables with distribution style key, the number of rows is distributed based on hash of the values of the column selected as key for the distribution style.  

The query below shows the number of rows distributed across the Redshift cluster nodes and slices. For tables with distribution style key, the number of rows is distributed based on hash of the values of the column selected as key for the distribution style.  


```sql
select trim(name) as table, stv_blocklist.slice, stv_tbl_perm.rows
from stv_blocklist,stv_tbl_perm
where stv_blocklist.tbl=stv_tbl_perm.id
and stv_tbl_perm.slice=stv_blocklist.slice
and stv_blocklist.id > 10000 and name not like '%#m%'
and name not like 'systable%'
group by name, stv_blocklist.slice, stv_tbl_perm.rows
order by 3 desc;
```
Please note that the tables `orders`, `lineitem`, `partsupp` were defined as distribution style key therefore, the rows are split equally across the slices on the Redshift clusters. Whereas tables `region`, `nation`, `supplier`, and `customer` were defined with distribution style all. It means there is a copy of the table on every node in the cluster. Distribution style ALL is used for small or medium dimensions that join large fact tables that are using key distribution style. 


Now we will submit some queries on Redshift and use some of the System tables and views to track queries that are currently executing as well as query history. 

The following query access data on multiple nodes/slice based on the distribution key and join
the small dimensions that are local on every node. The Leader compiles the query and send to nodes for parallel processing. Each node process the query based on the portion of data stored on local node and join with the dimensions.

```sql
select s_acctbal, s_name, n_name, p_partkey, p_mfgr, s_address, s_phone, s_comment
from
part, supplier, partsupp, nation, region
where
    p_partkey = ps_partkey
    and s_suppkey = ps_suppkey
    and p_size = 5
    and p_type like '%TIN'
    and s_nationkey = n_nationkey
    and n_regionkey = r_regionkey
    and r_name = 'AFRICA'
    and ps_supplycost = (
        select
            min(ps_supplycost)
                from partsupp, supplier, nation, region
                where
                    p_partkey = ps_partkey
                    and s_suppkey = ps_suppkey
                    and s_nationkey = n_nationkey
                    and n_regionkey = r_regionkey
                    and r_name = 'AFRICA')
order by
s_acctbal desc,
n_name,
s_name,
p_partkey
limit 100;
```

The following query access the table lineitem and process some aggregations. The table lineitem is using `key` distribution style, and has approximately 250M of rows. Since there is no join with additional tables, the aggregation is processed on each individual slice and the results are returned to the leader node. 

```sql
SELECT   l_returnflag, 
         l_linestatus, 
         Sum(l_quantity)                                                                     AS sum_qty,
         Sum(l_extendedprice)                                                                AS sum_base_price,
         Sum(l_extendedprice                * (1 - l_discount))::decimal(38,2)               AS sum_disc_price,
         sum(l_extendedprice::decimal(38,2) * (1 - l_discount) * (1 + l_tax))::decimal(38,2) AS sum_charge,
         avg(l_quantity)                                                                     AS avg_qty,
         avg(l_extendedprice)                                                                AS avg_price,
         avg(l_discount)                                                                     AS avg_disc,
         count(*)                                                                            AS count_order
FROM     lineitem 
WHERE    l_shipdate <= cast ( date '1998-12-01' - interval '66 days' AS date ) 
GROUP BY l_returnflag, 
         l_linestatus 
ORDER BY l_returnflag, 
         l_linestatus;
```

The following Query join tables `orders`, `lineitem` (both using distribution style key), and customers distribution style ALL. 


```sql
SELECT   l_orderkey, 
         SUM(l_extendedprice * (1 - l_discount)) AS revenue, 
         o_orderdate, 
         o_shippriority 
FROM     customer, 
         orders, 
         lineitem 
WHERE    c_mktsegment = 'HOUSEHOLD' 
AND      c_custkey = o_custkey 
AND      l_orderkey = o_orderkey 
AND      o_orderdate < DATE '1995-03-02' 
AND      l_shipdate >  DATE '1995-03-02' 
GROUP BY l_orderkey, 
         o_orderdate, 
         o_shippriority 
ORDER BY revenue DESC, 
         o_orderdate limit 10;
```

Now we are going to track query execution using Amazon Redshift System tables and views; 
There are two types of system tables: STL and STV tables.
STL tables are generated from logs that have been persisted to disk to provide a history of the system. STV tables are virtual tables that contain snapshots of the current system data.

There are two types of views SVL and SVV. System views contains a subset of data found in several of the STL and STV system tables. 

Run the query bellow to identify the top 5 queries you recently ran on your Redshift Cluster. 

```sql
select query, trim(querytxt) as sqlquery
from stl_query
order by query desc limit 5;
```

If you want to check on query execution metrics information, you can query the system table log **`STL_QUERY_METRICS`** which contains infomration such as,  number of rows processed, CPU usage, input/output, and disk use, for queries that have completed

```SQL
SELECT userid, 
       service_class, 
       query, 
       segment, 
       step_type, 
       starttime, 
       slices, 
       rows, 
       cpu_time, 
       blocks_read, 
       run_time, 
       blocks_to_disk, 
       query_scan_size 
FROM   STL_QUERY_METRICS 
```

```sql
/* Find Top Queries by Duration, Number of reads, Memory to Disk */
SELECT querytxt, MAX(CPU_TIME) AS cpu_time_micro, MAX(ROWS) AS ROWS, MAX(BLOCKS_READ)AS blocks_read, 
MAX(blocks_to_disk)as MB_to_Disk, SUM(run_time/1000000)as time_sec, SUM((run_time/1000000)/60)as time_minutes  FROM STL_QUERY AS Q 
JOIN STL_QUERY_METRICS AS M
ON Q.query = M.query 
GROUP BY querytxt
ORDER BY time_sec desc 
```

To view metrics for active queries that are currently running, see the **`STV_QUERY_METRICS`** system view instead.


You can use the SVL_QUERY_REPORT system view for advanced query troubleshooting, such as identifying memory usage, data skew, disk spills as well as check for execution details on each step. 

Run the a query on **`STL_QUERY`** to identify the most recent queries you have ran and copy the query_ID for the query you want more details. You are going to use in the **`svl_query_report`** next. 

```sql
select query, trim(querytxt) as sqlquery
from stl_query
order by query desc limit 5;
```

|query |    sqlquery
|------|--------------------------------------------------
|129 | select query, trim(querytxt) from stl_query order by query;
|128 | select node from stv_disk_read_speeds;
|127 | select system_status from stv_gui_status
|126 | select * from systable_topology order by slice
|125 | load global dict registry
(5 rows)


```sql
select query, segment, step, max(rows), min(rows),
case when sum(rows) > 0
then ((cast(max(rows) -min(rows) as float)*count(rows))/sum(rows))
else 0 end
from svl_query_report
where query = 279
group by query, segment, step
order by segment, step;
```

### 7- Querying S3 Data Lake using Redshift Spectrum 

Now let's setup the Redshift Cluster to query historical Data on S3 Data Lake with Redshift Spectrum. 

In this exercise, we will leverage external tables to query data that is stored in Amazon S3. The external tables are created in the AWS Glue. You also have an option to store external tables using Apache Hive Metastore. 

We will perform the following activities; 


1 - Create external database and schema  
2 - Create a clawler Job that will be used to identify tables automactically on S3. 

#### Create external database and schema 

Log in to the AWS Console. On AWS console main page, go to Services and select AWS Glue or type Glue in the search field. Choose AWS Glue when you see in the results. 

1 - On AWS Glue console choose Databases on the left-hand side and choose Add Database option. 
2 - Please specify a Database Name and choose `Create`

![alt text](https://github.com/andrehass/RedshiftWorkshop/blob/master/Images/gluedatabase.jpg "Database Name")


Alternatively, you can execute the following command using the client you are using to execute queries on Redshift. 


#### Create a clawler Job that will be used to identify tables automactically on S3.  

In the AWS Glue console, choose Crawlers on the left-hand side and then **`Add crawler`**


![alt text](https://github.com/andrehass/RedshiftWorkshop/blob/master/Images/addcrawlerJob.jpg "Add Crawler")

Specify the **`Crawler Name`**

![alt text](https://github.com/andrehass/RedshiftWorkshop/blob/master/Images/crawlername.jpg "Crawler Name")

On Specify crawler source type, choose Data Stores

![alt text](https://github.com/andrehass/RedshiftWorkshop/blob/master/Images/crawlersource.jpg "Crawler Source")

On **`Add a data store`** 

![alt text](https://github.com/andrehass/RedshiftWorkshop/blob/master/Images/crawlerdatastore.jpg "Crawler Data Store")

In the **`Add another data store`** left the option **`No`** selected and choose next: 

In the **`Choose an IAM role`** choose the option **`Create an IAM role`**. Specicy the role name in the text field.

![alt text](https://github.com/andrehass/RedshiftWorkshop/blob/master/Images/glueIAMRole.jpg "Create IAM role")

On **`Create a schedule for this crawler`** choose the option **`Run on demand`** and choose **`Next`**

In **`Configure the crawler's output`**, choose the Database created in the previous step and leave the other options default. Choose **`Next`** 

![alt text](https://github.com/andrehass/RedshiftWorkshop/blob/master/Images/crawlerOutput.jpg "See IAM roles option")

In the Review all the steps, choose **`Finish`**






#### Run the crawler Job. 

Select the Job name using the check box and choose Run Crawler. 

![alt text](https://github.com/andrehass/RedshiftWorkshop/blob/master/Images/runcrawler.jpg "Run crawler Job")

Wait a few minutes for the crawler to read the files and build the external tables that will be used later in Redshift. 

Notice that two tables have been added by the crawler in the database 

![alt text](https://github.com/andrehass/RedshiftWorkshop/blob/master/Images/addedtables.jpg "Added Tables")

Choose Tables on the left-hand side and review the tables added. Hit the refresh button in case they don’t show-up. 

![alt text](https://github.com/andrehass/RedshiftWorkshop/blob/master/Images/checktables.jpg "Check added Tables")

Choose one of the tables to see the schema definition and properties. 

On the same screen on right top corner, choose `View Partitions` to view the partitions detected by the crawler. Notice the year and month matches with the S3 partitioning using the field 0_yearmonth and the values year and month. This is hive style partitioning and it will help reduce the number of files Redshift Spectrum has to scan when querying the data lake. 


![alt text](https://github.com/andrehass/RedshiftWorkshop/blob/master/Images/partitions.jpg "Review Partitions")



#### Querying Data on S3 using Redshift Spectrum

Access the script in this session in following location to help with COPY and PASTE. 
[Spectrum Queries](https://s3.amazonaws.com/reinvent-hass/code/SpectrumQueries.sql)


Query below will return the external schemas and objects. We haven't created the external schema yet. The result expected should be 0 rows.

```SQL
/* Query will return external tables */ 
SELECT s.schemaname, databasename, tablename, location, input_format FROM SVV_EXTERNAL_SCHEMAS AS S
JOIN SVV_EXTERNAL_TABLES AS T ON S.schemaname = T.schemaname;
```

To create the external tables, first you will need to create an external schema that will reference the tables discovered by the crawlers in AWS Glue. Execute the following command to create the external schema that will reference the external tables. 

*** iam_role *** You will need the role arn with permission to access the files on S3. Use the steps bellow to retrieve the role arn assigned for the Redshift Cluster. 


```SQL
/* Create External Schema and reference Glue Database */
create external schema spectrum
from data catalog
database 'reinvent2018'
iam_role 'arn:aws:iam::219366808401:role/MyRedshiftRole'
``` 

Please refer to **Redshift IAM Role** for information on how to find the IAM role assigned to your cluster. 

Now you have schema that references the tables discovered by the AWS Glue crawler in the previous steps. Execute the following query again to see the tables and schema. 

```SQL
/* Query will return external tables */
SELECT s.schemaname, databasename, tablename, location, input_format FROM SVV_EXTERNAL_SCHEMAS AS S
JOIN SVV_EXTERNAL_TABLES AS T ON S.schemaname = T.schemaname;
```

The files for orders and lineitem are stored using Hive style partitioning on a year/month date field. Run the following query to see the partition detected by the crawler. Notice the fields location and values match 

```SQL 
/* Query partitions for the external tables */ 
SELECT schemaname, tablename, values, location FROM 
SVV_EXTERNAL_PARTITIONS;
``` 

Now you will Query data using Redshift Spectrum to join local tables stored local in Redshift. 

The use case is an archiving strategy where cold data is stored in s3 and queried using external table through Redshift Spectrum. The data stored local in Redshift only contain frequently accessed used for daily reports. Redshift Cluster stores data between 1996-01 and 1998-08 year/month.
The data stored on S3 uses parquet file format and use hive like partitioning by month and year on the field o_yearmonth, l_yearmonth orders and lineitem tables respectively. S3 stores historical data from 1992-01 through 1995-12. 


Run the query bellow to confirm that are no data on field year month that are less than 1996-01 for tables orders and lineitem in Redshift. It should return zero rows.

```SQL
/* Table orders */ 
select count(*), o_yearmonth from orders
GROUP BY o_yearmonth 
HAVING o_yearmonth < '1996-01'
ORDER BY o_yearmonth;

/* Table lineitem */ 
select count(*), l_yearmonth from lineitem
GROUP BY l_yearmonth 
HAVING l_yearmonth < '1996-01'
ORDER BY l_yearmonth;

```
Now execute the same query using Redshift Spectrum Tables. Please notice that the schema is spectrum. It is expected to return values as the historical date is in S3. Redshift Spectrum is being used to query data on Data lake.

```SQL
/* Spectrum orders table */
select count(*), o_yearmonth from spectrum.orders
GROUP BY o_yearmonth 
HAVING o_yearmonth < '1996-01'
ORDER BY o_yearmonth; 

/* Spectrum lineitem table */
select count(*), l_yearmonth from spectrum.lineitem
GROUP BY l_yearmonth 
HAVING l_yearmonth < '1996-01'
ORDER BY l_yearmonth;
```

Now you will run a Query on the external table lineitem to get historical data on S3. That means any data with data and month bellow 1996-01 is on S3 and will be returned using external tables. Query to compute the revenue based on discount applied. 

```SQL 
SELECT (l_extendedprice * l_discount) as revenue
FROM spectrum.lineitem
   WHERE l_yearmonth <= '1993-01'
AND l_discount between 0.04 - 0.01 and 0.04 + 0.01
   AND l_quantity < 24;	
```

Now for the next Query, you will retrieve results using Redshift Spectrum and join with local tables stored in Redshift(dimensions). The tables stored in Redshift Cluster are; **nation**, **customer** and **supplier**. Tables **orders** and **lineitem** have most current data on Redshift Cluster using distribution style key so that they data is spread evenly across the nodes. Also there are external tables on schema spectrum **orders** and **lineitem** stored on S3.  

We will create a view with UNION between local tables in Redshift and external tables in Redshift Spectrum to be able to access orders and lineitem data from both tables in Redshift and S3 with Redshift Spectrum at the same time. 

```SQL
/* Create view to access data stored in orders table in Redshift and Redshift Spectrum */
CREATE VIEW vw_orders as 
select o_orderkey, o_custkey, o_orderstatus, o_totalprice, o_orderdate, o_orderpriority, 
o_shippriority, o_yearmonth FROM public.orders
UNION ALL
select o_orderkey, o_custkey, o_orderstatus, o_totalprice, CAST(o_orderdate AS date) as o_orderdate, o_orderpriority,
o_shippriority, o_yearmonth from spectrum.orders 
with no schema binding;

/* Create view to access data stored in lineitem table in Redshift and Redshift Spectrum */
CREATE VIEW vw_lineitem as 
select  l_orderkey, l_partkey, l_suppkey,l_linenumber, l_quantity, l_discount, l_tax, l_returnflag, l_extendedprice, l_linestatus, l_shipdate, l_yearmonth, l_commitdate, l_receiptdate
FROM public.lineitem 
UNION ALL
select  l_orderkey, l_partkey, l_suppkey,l_linenumber, l_quantity , l_discount, l_tax,  l_returnflag, l_extendedprice, l_linestatus, CAST(l_shipdate AS date) as l_shipdate,  l_yearmonth, CAST(l_commitdate AS date) as l_commitdate, CAST(l_receiptdate AS date) as l_receiptdate 
FROM spectrum.lineitem 
with no schema binding;
```

Now Run the Following Query to query data on S3 with Redshift Spectrum and join with local tables on Redshift seamlessly using the views you just created. Please have some patience, the query execution should take approximately 3 minutes to execute. Notice that query is using the views vw_lineitem and vw_orders instead of the tables. Both views query data using tables in Redshift and also external tables using Redshift Spectrum. Depending on the date parameters passed in the query, it will access S3 or Redshift. 

```SQL
select
	supp_nation,
	cust_nation,
	l_year,
	sum(volume) as revenue
from
	(
		select
			n1.n_name as supp_nation,
			n2.n_name as cust_nation,
			extract(year from l_shipdate) as l_year,
			l_extendedprice * (1 - l_discount) as volume
		from
			supplier,
			vw_lineitem,
			vw_orders,
			customer,
			nation n1,
			nation n2
		where
			s_suppkey = l_suppkey
			and o_orderkey = l_orderkey
			and c_custkey = o_custkey
			and s_nationkey = n1.n_nationkey
			and c_nationkey = n2.n_nationkey
			and (
				(n1.n_name = 'INDIA' and n2.n_name = 'INDONESIA')
				or (n1.n_name = 'INDONESIA' and n2.n_name = 'INDIA')
			)
			and l_shipdate between date '1995-01-01' and date '1996-12-31'
	) as shipping
group by
	supp_nation,
	cust_nation,
	l_year
order by
	supp_nation,
	cust_nation,
	l_year;
```

The following query will access tables **orders** and **lineitem** using Redshift Spectrum to access the data lake on S3 and will join with a customer table local on Redshift. You can use either the view or directedly access the external table. Just make sure to reference the table with the schema spectrum. Notice the shema spectrum is qualified before the table names. 

```SQL
/* 12 */
select
	l_orderkey,
	sum(l_extendedprice * (1 - l_discount)) as revenue,
	o_orderdate,
	o_shippriority
from
	customer,
	spectrum.orders,
	spectrum.lineitem
where
	c_mktsegment = 'HOUSEHOLD'
	and c_custkey = o_custkey
	and l_orderkey = o_orderkey
	and o_orderdate < date '1995-03-02'
	and l_shipdate > date '1995-03-02'
group by
	l_orderkey,
	o_orderdate,
	o_shippriority
order by
	revenue desc,
	o_orderdate
limit 10;
```

Lastly, you will run the query on line item and use the partitioned filed and retrieve the execution plan to see that Redshift Spectrum is using the partitioning the limit the number of files scanned in S3. 


```SQL
select
	l_returnflag,
	l_linestatus,
	sum(l_quantity) as sum_qty,
	sum(l_extendedprice) as sum_base_price,
	sum(l_extendedprice * (1 - l_discount))::decimal(38,2) as sum_disc_price,
	sum(l_extendedprice::decimal(38,2) * (1 - l_discount) * (1 + l_tax))::decimal(38,2) as sum_charge,
	avg(l_quantity) as avg_qty,
	avg(l_extendedprice) as avg_price,
	avg(l_discount) as avg_disc,
	count(*) as count_order
from
	lineitem
where
	l_yearmonth < ‘1994-06’
group by
	l_returnflag,
	l_linestatus
order by
	l_returnflag,
	l_linestatus;
```

Run the **EXPLAIN** command to retrieve the execution plan for the query. Notice that there is a filter by the partition defined in the predicate. 

```SQL
EXPLAIN (select
	l_returnflag,
	l_linestatus,
	sum(l_quantity) as sum_qty,
	sum(l_extendedprice) as sum_base_price,
	sum(l_extendedprice * (1 - l_discount))::decimal(38,2) as sum_disc_price,
	sum(l_extendedprice::decimal(38,2) * (1 - l_discount) * (1 + l_tax))::decimal(38,2) as sum_charge,
	avg(l_quantity) as avg_qty,
	avg(l_extendedprice) as avg_price,
	avg(l_discount) as avg_disc,
	count(*) as count_order
from
	lineitem
where
	l_yearmonth < ‘1994-06’
group by
	l_returnflag,
	l_linestatus
order by
	l_returnflag,
	l_linestatus);
```


### 8- Redshift IAM Role

In the Redshift Dashboard, go to Cluster on the left upper side and choose the Redshift cluster you created previosly to see more options. 

![alt text](https://github.com/andrehass/RedshiftWorkshop/blob/master/Images/IAMrole2.jpg "See IAM roles option")

![alt text](https://github.com/andrehass/RedshiftWorkshop/blob/master/Images/IAMrole.jpg "See IAM roles option")
