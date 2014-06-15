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
apt-get install -y git

# I thought Ubuntu's puppet throws: Error: Function 'fail' does not return a value at /etc/puppet/modules/nginx/manifests/init.pp:66 on node sasuke3.bippo.co.id
# but it's false alarm: That's our bad for not supporting saucy/trusty/etc. yet in nginx module
aptitude install -y puppet facter ruby-dev ruby-augeas augeas-lenses build-essential pkg-config
# Workaround for: Error: Hiera terminus not supported without hiera library
#   at #/etc/puppet/manifests/nodes/sasuke3.bippo.co.id.pp:213 on node sasuke3.bippo.co.id
aptitude install -y ruby-hiera

REALLY_GEM_UPDATE_SYSTEM=1 gem update -V --system

# setup /etc/puppet
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
sudo -u "$DEVELOPER" git submodule sync
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
