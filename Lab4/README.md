# LAB 4 - Querying S3 Data Lake using Redshift Spectrum 
Now you will learn how to setup your Amazon Redshift Cluster to query historical Data on S3 Data Lake with Redshift Spectrum.  

In this lab, you will leverage external tables to query data stored in Amazon S3 using parquet file format. The external tables definition are created and kept in AWS Glue catalog. In this Lab your learn how to create database catalog in Glue, create crawler jobs that will detect tables and paritions in S3 and Query data on S3 using Redshift local tables and external tables via Spectrum. 


## Contents
  - [Create external database and schema](#create-external-database-and-schema)
  - [Create clawler Job using AWS Glue](#create-clawler-job-using-aws-glue)
  - [Running the crawler Job](#running-the-crawler-Job)
  - [Querying Data on S3 using Redshift Spectrum](#querying-data-on-s3-using-redshift-spectrum)
  - [After you finish all the Labs](#after-you-finish-all-the-labs)

## Create external database and schema

You will now create the external database in AWS Glue and the external schema in Amazon Redshift to make the external tables visible for queries. 

Log in to the AWS Console. On AWS console main page, go to Services and select AWS Glue or type Glue in the search field. Choose AWS Glue when you see in the results. 

On AWS Glue console choose Databases on the left-hand side and choose Add Database option.  
Specify a Database Name and choose `Create`
**Important** Ensure you remember the database name you specified as it will be used in a later section. 

![alt text](https://github.com/andrehass/RedshiftWorkshop/blob/master/Images/gluedatabase.jpg "Database Name")


## Create clawler Job using AWS Glue

After creating the database in AWS Glue, you will now create a crawler job that will scan a S3 location where the parquet files are stored and then create external tables automatically for you with correct properties. Later you will use these tables in Amazon Redshift Spectrum. The integration with Data Lake on S3 will allow you to query data on tables stored either on Amazon Redshift or S3 using Amazon Redshift Spectrun through external tables. 

While still in the AWS Glue console, choose Crawlers on the left-hand side and then **`Add crawler`**


![alt text](https://github.com/andrehass/RedshiftWorkshop/blob/master/Images/addcrawlerJob.jpg "Add Crawler")

Specify the **`Crawler Name`**

![alt text](https://github.com/andrehass/RedshiftWorkshop/blob/master/Images/crawlername.jpg "Crawler Name")

On Specify crawler source type, choose Data Stores

![alt text](https://github.com/andrehass/RedshiftWorkshop/blob/master/Images/crawlersource.jpg "Crawler Source")

On **`Add a data store`**  select S3 as your data store, select the option `Specified path in another account`, and specify the following path in the `Include path` s3://reinvent-hass/historical-parquet. Choose next 

![alt text](https://github.com/andrehass/RedshiftWorkshop/blob/master/Images/crawlerdatastore.jpg "Crawler Data Store")

In the **`Add another data store`** left the option **`No`** selected and choose next: 

In the **`Choose an IAM role`** choose the option **`Create an IAM role`**. Specicy the role name in the text field.

![alt text](https://github.com/andrehass/RedshiftWorkshop/blob/master/Images/glueIAMRole.jpg "Create IAM role")

On **`Create a schedule for this crawler`** choose the option **`Run on demand`** and choose **`Next`**

In **`Configure the crawler's output`**, choose the Database created in the previous step and leave the other options default. Choose **`Next`** 

![alt text](https://github.com/andrehass/RedshiftWorkshop/blob/master/Images/crawlerOutput.jpg "See IAM roles option")

In the Review all the steps, choose **`Finish`**


## Running the crawler Job

Now it is time to run the crawler Job so that AWS Glue can scan the files on S3 and detect the tables automactically.

Select the Job name using the check box and choose `Run Crawler`. 

![alt text](https://github.com/andrehass/RedshiftWorkshop/blob/master/Images/runcrawler.jpg "Run crawler Job")

Wait a few minutes for the crawler to read the files and build the external tables that will be used later with Amazon Redshift Spectrum. 

Notice that two tables have been added by the crawler in the database 

![alt text](https://github.com/andrehass/RedshiftWorkshop/blob/master/Images/addedtables.jpg "Added Tables")

Choose Tables on the left-hand side and review the tables added. Hit the refresh button in case they don’t show-up. 

![alt text](https://github.com/andrehass/RedshiftWorkshop/blob/master/Images/checktables.jpg "Check added Tables")

Choose one of the tables to see the schema definition and properties. 

On the same screen on right top corner, choose `View Partitions` to view the partitions detected automatically by the crawler. Notice the year and month matches with the S3 partitioning using the field x_yearmonth and the values year and month. The partitioning on S3 will help reduce the number of files Redshift Spectrum has to scan when querying the data on S3. 

![alt text](https://github.com/andrehass/RedshiftWorkshop/blob/master/Images/partitions.jpg "Review Partitions")


## Querying Data on S3 using Redshift Spectrum

Now you will Query data using Redshift Spectrum and join with tables stored localy in Amazon Redshift. 

The use case usually with Redshift Spectrum is where customers have cold and warm data, where cold data is stored in s3 and can be queried using external table through Redshift Spectrum. Whereas the data stored local in Redshift only contain frequently accessed warm data, used frequently by users and for daily reports. 
In this Lab your Redshift Cluster stores data between 1996-01 and 1998-08 year/month. The cold data has been offloaded to S3 and contains historical data from 1992-01 through 1995-12. you will be able to query the historical data via Redshift Spectrum. 
The data stored on S3 uses parquet file format partitioned by month and year on the fields o_yearmonth, l_yearmonth for the tables orders and lineitem respectively. S3 stores historical data from 1992-01 through 1995-12. 


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
Now execute the same query using Redshift Spectrum Tables. Please notice that there is a schema called spectrum in front of the table name. This is the external schema name you created earlier.  It is expected to return values as the historical date is in S3. Redshift Spectrum is being used to query data on Data lake.

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

Now for the next Query, you will retrieve results using Redshift Spectrum and join with local tables stored in Redshift(dimensions). The tables stored in Redshift Cluster are; **nation**, **customer** and **supplier**. Tables **orders** and **lineitem** have most current data on Redshift Cluster using distribution style key so that they data is spread evenly across the nodes. Historical data with the date less than 1996-01 is stored on S3 as parquet format. Remember that you will be able to access through external tables in schema `spectrum` **orders** and **lineitem** stored on S3.  

You will create a view object with an UNION between local tables in Amazon Redshift and external tables in Redshift Spectrum. This approach allows the users submit a query to the view instead of writing the SQL statement to join both tables. With the View you will be able to access orders and lineitem data from both tables in Amazon Redshift and S3 Data Lake with Redshift Spectrum at the same time. 

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

Now execute the query provided to access data in S3 with Redshift Spectrum and join with local tables in Amazon Redshift seamlessly using the views you just created. Please have some patience, the query execution should take approximately 3 minutes to execute. Notice that query is using the views vw_lineitem and vw_orders instead of the tables. Both views query data using tables in Redshift and also external tables using Redshift Spectrum. Depending on the date parameters passed in the query, it will retrieve data from either S3 Data Lake or Amazon Redshift. 

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

Lastly, you will execute a query againt table `lineitem` using a parameter field that has the data paritioned on S3. Redshift Spectrum will make the use of parittioning on S3 to limit the number of files the query has to scan. 

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
	l_yearmonth < '1994-06'
group by
	l_returnflag,
	l_linestatus
order by
	l_returnflag,
	l_linestatus;
```

Now you will run the **EXPLAIN** command to retrieve the execution plan for the query. Notice that there is a filter by the partition defined in the predicate. 

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
	l_yearmonth < '1994-06'
group by
	l_returnflag,
	l_linestatus
order by
	l_returnflag,
	l_linestatus);
```