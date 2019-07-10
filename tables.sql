CREATE TABLE customer (
  c_custkey int8 NOT NULL                                      ,
  c_name varchar(25) NOT NULL                                  ,
  c_address varchar(40) NOT NULL                               ,
  c_nationkey int4 NOT NULL                                    ,
  c_phone char(15) NOT NULL                                    ,
  c_acctbal numeric(12,2) NOT NULL                             ,
  c_mktsegment char(10) NOT NULL                               ,
  c_comment varchar(117) NOT NULL)
  DISTSTYLE ALL;


CREATE TABLE lineitem (
  l_orderkey int8 NOT NULL DISTKEY                               ,
  l_partkey int8 NOT NULL                                        ,
  l_suppkey int4 NOT NULL                                        ,
  l_linenumber int4 NOT NULL                                     ,
  l_quantity numeric(12,2) NOT NULL                              ,
  l_extendedprice numeric(12,2) NOT NULL                         ,
  l_discount numeric(12,2) NOT NULL                              ,
  l_tax numeric(12,2) NOT NULL                                   ,
  l_returnflag char(1) NOT NULL                                  ,
  l_linestatus char(1) NOT NULL                                  ,
  l_shipdate date NOT NULL SORTKEY                               ,
  l_yearmonth char(7) NOT NULL                                   ,
  l_commitdate date NOT NULL                                     ,
  l_receiptdate date NOT NULL                                    ,
  l_shipinstruct char(25) NOT NULL                               ,
  l_shipmode char(10) NOT NULL                                   ,
  l_comment varchar(44) NOT NULL);


CREATE TABLE nation (
  n_nationkey int4 NOT NULL                                      ,
  n_name char(25) NOT NULL                                       ,
  n_regionkey int4 NOT NULL                                      ,
  n_comment varchar(152) NOT NULL)
  DISTSTYLE ALL;

CREATE TABLE orders (
  o_orderkey int8 NOT NULL DISTKEY                               ,
  o_custkey int8 NOT NULL                                        ,
  o_orderstatus char(1) NOT NULL                                 ,
  o_totalprice numeric(12,2) NOT NULL                            ,
  o_orderdate date NOT NULL SORTKEY                              ,
  o_orderpriority char(15) NOT NULL                              ,
  o_clerk char(15) NOT NULL                                      ,
  o_shippriority int4 NOT NULL                                   ,
  o_comment varchar(79) NOT NULL                                 ,
  o_yearmonth char(8) NOT NULL );


CREATE TABLE part (
  p_partkey int8 NOT NULL DISTKEY                                ,
  p_name varchar(55) NOT NULL                                    ,
  p_mfgr char(25) NOT NULL                                       ,
  p_brand char(10) NOT NULL                                      ,
  p_type varchar(25) NOT NULL                                    ,
  p_size int4 NOT NULL                                           ,
  p_container char(10) NOT NULL                                  ,
  p_retailprice numeric(12,2) NOT NULL                           ,
  p_comment varchar(23) NOT NULL);


CREATE TABLE partsupp (
  ps_partkey int8 NOT NULL DISTKEY                               ,
  ps_suppkey int4 NOT NULL                                       ,
  ps_availqty int4 NOT NULL                                      ,
  ps_supplycost numeric(12,2) NOT NULL                           ,
  ps_comment varchar(199) NOT NULL);


CREATE TABLE region (
  r_regionkey int4 NOT NULL                                      ,
  r_name char(25) NOT NULL                                       ,
  r_comment varchar(152) NOT NULL)
 DISTSTYLE ALL;

CREATE TABLE supplier (
  s_suppkey int4 NOT NULL                                        ,
  s_name char(25) NOT NULL                                       ,
  s_address varchar(40) NOT NULL                                 ,
  s_nationkey int4 NOT NULL                                      ,
  s_phone char(15) NOT NULL                                      ,
  s_acctbal numeric(12,2) NOT NULL                               ,
  s_comment varchar(101) NOT NULL
)
 DISTSTYLE ALL; 
