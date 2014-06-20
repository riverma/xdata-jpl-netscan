#!/bin/bash

##################################################
#                                                #
#   OODT RADiX Vagrant Provision Script          #
#                                                # 
##################################################

# Load config file
source /vagrant/vagrant/env.sh

echo "Update Ubuntu’s package index"
sudo apt-get update

# --------- GENERAL INSTALL/CONFIG -------------------------------------------------------------------------------
sudo apt-get install -y vim 
sudo apt-get install -y subversion
sudo apt-get install -y git
sudo apt-get install -y tree
sudo apt-get install -y curl
sudo apt-get install -y maven2
sudo apt-get install -y default-jdk
sudo apt-get install -y ack

# --------- General config/install ----------
sudo cp /vagrant/vagrant/conf/terminal/bashrc /home/vagrant/.bashrc
source /home/vagrant/.bashrc
sudo mkdir ${OODT_DEPLOYMENT_HOME}
sudo chown -R vagrant:vagrant ${OODT_DEPLOYMENT_HOME}


# ---------- OODT Installation --------------
# NOTE: Checking out and installing OODT is only necessary for the SNAPSHOT versions of OODT
# TO DO: Set up some logic for differentiating between SNAPSHOT (trunk) and tagged releases
echo "Checking out latest (trunk) OODT from SVN"
cd /usr/local/src
sudo svn export ${OODT_SRC_REPO} oodt-trunk
sudo chown -R vagrant:vagrant oodt-trunk
echo "Build OODT and RADiX archetype"
cd oodt-trunk
mvn -Dmaven.test.skip=true clean install
cd mvn/archetypes/radix
sudo mvn install

# ---------- Setup new RADiX project --------
cd /usr/local/src
sudo mvn archetype:generate -DinteractiveMode=false -DarchetypeGroupId=org.apache.oodt -DarchetypeArtifactId=radix-archetype -DarchetypeVersion=${OODT_VERSION} -Doodt=${OODT_VERSION} -DgroupId=${PROJECT_GROUP_ID} -DartifactId=${PROJECT_ARTIFACT_ID} -Dversion=0.1-SNAPSHOT
cd ${PROJECT_ARTIFACT_ID}
sudo mvn package ${BUILD_FLAGS}
tar zxf distribution/target/${PROJECT_ARTIFACT_ID}-distribution-*-bin.tar.gz -C ${OODT_DEPLOYMENT_HOME}
sudo chown -R vagrant:vagrant ${OODT_DEPLOYMENT_HOME}

# ---------- Set up Spark client ----------
cd /tmp
wget http://d3kbcqa49mib13.cloudfront.net/spark-1.0.0-bin-cdh4.tgz
tar xvf spark-1.0.0-bin-cdh4.tgz
sudo mv spark-1.0.0-bin-cdh4 /usr/local/spark
cp conf/spark-env.sh.template conf/spark-env.sh
echo "export SPARK_HOME=/srv/software/spark" >> conf/spark-env.sh

# ---------- Start services ----------
cd ${OODT_DEPLOYMENT_HOME}/bin
./oodt start
echo ""
echo "OODT started, please navigate to: http://localhost:8080/opsui"
