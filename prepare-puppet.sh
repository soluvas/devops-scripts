#!/bin/sh
if [ "x${USER}" != "xroot" ]; then
  echo Please run this script as root or sudo.
  exit 1
fi

# Use apt-get since aptitude is not available in Ubuntu minimal VM
apt-get update
apt-get install -y ruby1.9.1-dev augeas-lenses libaugeas-dev git
ln -sv gem1.9.1 /usr/bin/gem
REALLY_GEM_UPDATE_SYSTEM=1 gem update --system
gem install -V puppet facter ruby-augeas

mkdir -vp /etc/puppet/modules /etc/puppet/manifests
adduser --system --group --home /etc/puppet --no-create-home --disabled-password puppet
chown -Rc puppet:puppet /etc/puppet
chmod -Rc g+sw /etc/puppet
