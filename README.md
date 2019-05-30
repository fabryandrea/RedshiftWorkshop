
# Redshift Workskop 

In this workshop you will learn how to launch a Redshift cluster, create tables using the appropriate distribution styles, load data from S3, prepare the Redshift cluster to query data on S3 using Redshift Spectrum and build queries that will access data in Redshift and also Data Lake using Redshift Spectrum. 


## Table of Contents 

1. Lauching a Redshift Cluster 
2. Installing client tool to connect to Redshift Cluster
3. Connecting to your Redshift Cluster
4. Creating Tables on Redshift 
5. Loading Data into Redshift Cluster 
6. Querying local tables on Redshift 



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
•	lineitem  
•	nation  
•	orders  
•	part  
•	partsupp  
•	supplier  


Please refer to the following link provided below to download the script that will be used to create the table definition for this exercise. 
Access the tables.sql file using the following s3 link. 
[Table Definition - tables.sql](https://s3.amazonaws.com/reinvent-hass/code/tables.sql)

Open the file `tables.sql` using your query editor of preference. The majority of client tools provide query editor and the ability to submit the query/script to Redshift. After opening the file, examine the `CREATE TABLE` commands. You should see distribution style key for tables lineitem and orders. For all the remaining tables, the distribution style will be set to ALL as they are small dimmensions tables. 

When you finish executing the `CREATE TABLE` script run, the following command to check the tables created in Redshift. Look for the columns `diststyle` for the distribution style defined for your table. 

```sql
select "table", encoded, diststyle, sortkey1, skew_sortkey1, skew_rows
from svv_table_info
order by 1;
```
### 4- Loading Data into Redshift Cluster 

You are now ready to load data into Redshift cluster. We will load approxemately 10GB worht of data from a S3 location. The bucket is in US-EAST-1 region. For better performance and avoid high cost transfer, make sure your Redshift cluster is in the same region as the S3 bucket.

Please refer to the following link provided below to download the script that will be used to load data into Redshift using the COPY command. 
Access the copy.sql file using the following s3 link. 
[COPY Command - copy.sql](https://s3.amazonaws.com/reinvent-hass/code/copy.sql)

After downloading the `copy.sql` file, open the file using the client tool of your choice and execute the copy statements against your Redshift cluster. 
**`Important step`**, replace 'iam_role' (COPY command example bellow) with the IAM role assigned to your Redshift cluster in all the COPY commands in your script. 

```sql
COPY nation FROM 's3://reinvent-hass/redshiftdata//nation/nation_'
iam_role 'arn:aws:iam::xxxxxxxxxxxx:role/MyRedshiftRole'
gzip delimiter '|'
IGNOREHEADER 1;
```

If you need instructions to see how to retrieve the iam_role assigned to your redshift cluster, please refer to `Redshift IAM Roles` section. 

**Load times and # of rows**
•	customer ==>  aprox 1 minute – 15M rows  
•	lineitem ==>  aprox  10 Minutes, 600M rows  
•	nation;  ==>  N/A  
•	orders;  ==>  aprox 4 minutes, 150M rows   
•	part;    ==>  aprox 1 minute, 20M rows  
•	partsupp; ==> aprox 3 minutes, 80M rows  
•	supplier; ==> aprox 30 seconds, 1 rows  
•	region;       5 records  

Execute each COPY command individually. Tables `lineitem` and `orders` will take longer. 
You can monitor the load status by either using AWS Console or running a query on **`STV_LOAD_STATE`** table. 

```sql
select slice , bytes_loaded, bytes_to_load , pct_complete from stv_load_state where query = pg_last_copy_id();
```

| slice | bytes_loaded | bytes_to_load | pct_complete 
|-------|--------------|---------------|--------------
|     2 |            0 |             0 |            0
|     3 |     12840898 |      39104640 |           32
(2 rows)


### 5- Querying local tables on Redshift 

First, you will execute some queries to get table definition details such as table information and distribution style define on the tables. Redshift is a Massive Parallel processing Data Warehouse System and uses multiple nodes to process the queries depending on the distribution style selected. 

Run the following query to get details on the number of nodes and slices in your Redshift cluster. The Query will return details on number of nodes and slices in your Redshift Cluster. 

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

Run the query bellow to identify the top 5 queries you recently ran on your Redshift Cluster. 

```sql
select query, trim(querytxt) as sqlquery
from stl_query
order by query desc limit 5;
```

