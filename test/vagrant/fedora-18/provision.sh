#!/bin/bash

# Make sure we install rvm as the vagrant user because I generally want
# to test things as non-root. I'll escalate with sudo if I need privileges.
[ `whoami` != "vagrant" ] && exec chroot --userspec=vagrant / bash -l "$0" "$@"

export USER=`whoami`
export HOME=/home/vagrant

case $USER in
  root)
    [ ! -f "/etc/profile.d/rvm.sh" ] && curl -sSL https://get.rvm.io | bash -s stable
    . ". /etc/profile.d/rvm.sh"
    ;;
  *)
    [ ! -f "$HOME/.rvm/scripts/rvm" ] && curl -sSL https://get.rvm.io | bash -s stable
    . "$HOME/.rvm/scripts/rvm"
    ;;
esac
rvm list | grep -q 'No rvm rubies' && rvm install 1.9.3
