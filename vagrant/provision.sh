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
sudo mkdir ${OODT_HOME}
sudo chown -R vagrant:vagrant ${OODT_HOME}


# ---------- OODT Installation --------------
# NOTE: Checking out and installing OODT is only necessary for the SNAPSHOT versions of OODT
# TO DO: Set up some logic for differentiating between SNAPSHOT (trunk) and tagged releases
echo "Checking out latest (trunk) OODT from SVN"
cd /usr/local/src
sudo svn export https://svn.apache.org/repos/asf/oodt/trunk oodt-trunk
sudo chown -R vagrant:vagrant oodt-trunk
echo "Build OODT and RADiX archetype"
cd oodt-trunk
mvn -Dmaven.test.skip=true clean install
cd mvn/archetypes/radix
sudo mvn install

# ---------- Setup new RADiX project --------
cd /usr/local/src
sudo mvn archetype:generate -DinteractiveMode=false -DarchetypeGroupId=org.apache.oodt -DarchetypeArtifactId=radix-archetype -DarchetypeVersion=${OODT_VERSION} -Doodt=${OODT_VERSION} -DgroupId=${RADIX_GROUP_ID} -DartifactId=${RADIX_ARTIFACT_ID} -Dversion=0.1-SNAPSHOT
cd ${RADIX_ARTIFACT_ID}
sudo cp /vagrant/vagrant/conf/oodt/filemgr.properties filemgr/src/main/resources/etc/filemgr.properties
sudo mvn package
tar zxf distribution/target/${RADIX_ARTIFACT_ID}-distribution-0.1-SNAPSHOT-bin.tar.gz -C ${OODT_HOME}

# ---------- Start OODT ----------
cd ${OODT_HOME}/bin
./oodt start
