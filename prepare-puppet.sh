 #!/bin/sh
if [ "x${USER}" != "xroot" ]; then
  echo Please run this script as root or sudo.
  exit 1
fi

# Use apt-get since aptitude is not available in Ubuntu minimal VM
apt-get update
apt-get install -y ruby1.9.1 augeas-lenses git
REALLY_GEM_UPDATE_SYTEM gem update --system
gem install -V puppet
gem install -V facter

adduser --system --group --home /etc/puppet --no-create-home --disabled-password puppet
mkdir -vp /etc/puppet/modules /etc/puppet/manifests
chown -Rc puppet:puppet /etc/puppet
chmod -Rc g+sw /etc/puppet
