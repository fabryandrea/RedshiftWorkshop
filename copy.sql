COPY customer FROM 's3://reinvent-hass/redshiftdata/customer/customer_'
iam_role 'arn:aws:iam::xxxxxxxxxxxx:role/MyRedshiftRole'
gzip delimiter '|'
IGNOREHEADER 1 ;


COPY lineitem FROM 's3://reinvent-hass/redshiftdata/lab/lineitem/lineitem_'
iam_role 'arn:aws:iam::xxxxxxxxxxxx:role/MyRedshiftRole'
gzip delimiter '|'
IGNOREHEADER 1;


COPY nation FROM 's3://reinvent-hass/redshiftdata/nation/nation_'
iam_role 'arn:aws:iam::xxxxxxxxxxxx:role/MyRedshiftRole'
gzip delimiter '|'
IGNOREHEADER 1;

COPY orders FROM 's3://reinvent-hass/redshiftdata/lab/orders/orders_'
iam_role 'arn:aws:iam::xxxxxxxxxxxx:role/MyRedshiftRole'
gzip delimiter '|'
IGNOREHEADER 1;

COPY part FROM 's3://reinvent-hass/redshiftdata/part/part_'
iam_role 'arn:aws:iam::xxxxxxxxxxxx:role/MyRedshiftRole'
gzip delimiter '|'
IGNOREHEADER 1;


COPY partsupp FROM 's3://reinvent-hass/redshiftdata/partsupp/partsupp_'
iam_role 'arn:aws:iam::xxxxxxxxxxxx:role/MyRedshiftRole'
gzip delimiter '|'
IGNOREHEADER 1;


COPY region FROM 's3://reinvent-hass/redshiftdata/region/region_'
iam_role 'arn:aws:iam::xxxxxxxxxxxx:role/MyRedshiftRole'
gzip delimiter '|'
IGNOREHEADER 1;


COPY supplier FROM 's3://reinvent-hass/redshiftdata/supplier/supplier_'
iam_role 'arn:aws:iam::xxxxxxxxxxxx:role/MyRedshiftRole'
gzip delimiter '|'
IGNOREHEADER 1;