#!/bin/sh
set -e

user_check() {
  getent passwd "$1" > /dev/null 2>&1
}

user_remove() {
  userdel "$1"
}

case $1 in
    purge)
        if user_check "{{{ name }}}" ; then
          user_remove "{{{ name }}}"
        fi
        ;;
esac

exit 0
