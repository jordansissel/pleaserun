#!/bin/bash

[ `whoami` != "vagrant" ] && chroot --userspec=vagrant / bash -l "$@"

export USER=`whoami`
export HOME=/home/vagrant

[ ! -f "$HOME/.rvm/scripts/rvm" ] && curl -sSL https://get.rvm.io | bash -s stable
. "$HOME/.rvm/scripts/rvm"
rvm list | grep -q 'No rvm rubies' && rvm install 1.9.3
