
# Redshift Workskop 

### In this workshop you will learn how to launch a Redshift cluster, create tables using the appropriate distribution styles, load data from S3, prepare the Redshift cluster to query data on S3 using Redshift Spectrum and build queries that will access data in Redshift and also Data Lake using Redshift Spectrum. 


## Table of Contents 

1. Lauching a Redshift Cluster 
2. Installing client tool to connect to Redshift Cluster 
3. Loading Data on Redshift Cluster 
4. Creating Tables using the right distribution style 
5. Querying local tableson Redshift 
6. 


### 1- Laucning a Redshift Cluster 

In this exercise, we will launch a Redshift Cluster in your account. Log into your AWS account using your credentials. After logging in; On AWS console main page, go to Services and select Amazon Redshift. Alternatively, type Redshift in the search field and choose Amazon Redshift when you see in the results returned. 

Alternatively, you can use a CloudFormation teample and skip this step in case you are already familiar with lauching a Redshift Cluster. In your AWS Console, go to CloudFormation. In the CloudFormation, choose Create Stack. In the Select Template choose to specify an Amazon S3 template URL and use the following S3 URL to launch a Redshift Cluster. 
[https://s3.amazonaws.com/bigdatalabshass/code/redshiftTemplate.json](https://s3.amazonaws.com/bigdatalabshass/code/redshiftTemplate.json)

On Specify Details, provide the Stack Name and Parameters required to launch the Redshift Cluster. After providing the Parameters, choose next. 


In the Options, Click Next 

In the Review, check to acknowledge the creation of IAM resources and click create. Wait a few minutes for the cluster to become available.  
