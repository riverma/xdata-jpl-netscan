# README
# author: riverma@apache.org
# date: June 20th, 2014

!!! NOTE: The Vagrant configruation doesn't work with Spark (VPN issues)


DESCRIPTION: 
===========
This project will allow to you build, execute, and analyze end-to-end analytics
for the XDATA NetScan dataset.

CONFIGURATION:
==============
1. Ensure Apache Spark is installed on your system, and spark-submit is accessible
from the command line. Please see: http://spark.apache.org/downloads.html

BUILD:
=====
1. Build OODT
   > cd oodt-netscan
   > mvn clean package -Pfm-solr-catalog

DEPLOY:
======
1. Deploy OODT
   > cd oodt-netscan
   > tar -zxf distribution/target/*.tar.gz -C /my/deployment/dir

RUN:
===

