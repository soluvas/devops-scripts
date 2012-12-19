#!/bin/sh
if [ "x${USER}" != "xroot" ]; then
  echo Please run this script as root or sudo.
  exit 1
fi
DEVELOPER="$1"
if [ -z "$DEVELOPER" ]; then
  echo Please input developer username.
  exit 1
fi

# Use apt-get since aptitude is not available in Ubuntu minimal VM
apt-get update
apt-get install -y ruby1.9.1-dev augeas-lenses libaugeas-dev build-essential pkg-config git
update-alternatives --set gem /usr/bin/gem1.9.1
REALLY_GEM_UPDATE_SYSTEM=1 gem update -V --system
gem install -V puppet facter ruby-augeas

mkdir -vp /etc/puppet/modules /etc/puppet/manifests
adduser --system --group --home /etc/puppet --no-create-home --disabled-password puppet
chown -Rc puppet:puppet /etc/puppet
chmod -Rc g+sw /etc/puppet

# Add developer to puppet Linux group
adduser "$DEVELOPER" puppet

# Clone or pull puppet-developer
if [ ! -e "/home/${DEVELOPER}/git/puppet-developer" ]; then
  sudo -u "$DEVELOPER" git clone git@bitbucket.org:bippo/puppet-developer.git \
    "/home/${DEVELOPER}/git/puppet-developer"
else
  cd "/home/${DEVELOPER}/git/puppet-developer"
  sudo -u "$DEVELOPER" git pull
fi
# Update submodules
cd "/home/${DEVELOPER}/git/puppet-developer"
sudo -u "$DEVELOPER" git submodule init
sudo -u "$DEVELOPER" git submodule update

# Create boilerplate site.pp
if [ ! -e /etc/puppet/manifests/site.pp ]; then
  echo 'import "nodes/*.pp"' > /etc/puppet/manifests/site.pp
fi
chown -c "${DEVELOPER}:${DEVELOPER}" /etc/puppet/manifests/site.pp

# Symlink manifests/nodes and modules
if [ -d /etc/puppet/modules ]; then
  rmdir -v /etc/puppet/modules
fi
if [ ! -h /etc/puppet/modules ]; then
  ln -sv "/home/${DEVELOPER}/git/puppet-developer/modules" /etc/puppet/modules
fi
if [ ! -h /etc/puppet/manifests/nodes ]; then
  ln -sv "/home/${DEVELOPER}/git/puppet-developer/manifests/nodes" /etc/puppet/manifests/nodes
fi
