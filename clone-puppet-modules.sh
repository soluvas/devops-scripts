#!/bin/sh
if [ "x${USER}" != "xroot" ]; then
  echo Please run this script as root or sudo.
  exit 1
fi

cd /etc/puppet/modules
sudo -u puppet git clone git://github.com/soluvas/puppet-tomcat.git tomcat
sudo -u puppet git clone git://github.com/soluvas/puppet-jbossas.git jbossas
sudo -u puppet git clone git://github.com/soluvas/puppet-nexus.git nexus
sudo -u puppet git clone git://github.com/soluvas/puppet-neo4j.git neo4j
sudo -u puppet git clone git://github.com/soluvas/puppet-apache.git apache
sudo -u puppet git clone git://github.com/soluvas/puppet-virtualbox.git virtualbox
sudo -u puppet git clone git://github.com/puppetlabs/puppet-apt.git apt
