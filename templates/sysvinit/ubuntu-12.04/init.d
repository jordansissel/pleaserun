#! /bin/sh
### BEGIN INIT INFO
# Provides:          {{{ name }}}
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: {{{ one_line_description }}}
# Description:       {{{ description }}}
#                    
### END INIT INFO

# Author: {{{ author }}} 

# PATH should only include /usr/* if it runs after the mountnfs.sh script
PATH=/sbin:/usr/sbin:/bin:/usr/bin
DESC={{#escaped}}{{{ description }}}{{/escaped}}
NAME={{#escaped}}{{#safe_filename}}{{{ name }}}{{/safe_filename}}{{/escaped}}
COMMAND={{#escaped}}{{{ command }}}{{/escaped}}
ARGS={{{ escaped_args }}}
PIDFILE=/var/run/$NAME.pid
SCRIPTNAME=/etc/init.d/$NAME

# Read configuration variable file if it is present
[ -r /etc/default/$NAME ] && . /etc/default/$NAME

# Load the VERBOSE setting and other rcS variables
. /lib/init/vars.sh

# Define LSB log_* functions.
# Depend on lsb-base (>= 3.2-14) to ensure that this file is present
# and status_of_proc is working.
. /lib/lsb/init-functions

#
# Function that starts the daemon/service
#
do_start()
{
  [ "$VERBOSE" != no ] && log_daemon_msg "Starting $DESC" "$NAME"

  # Skip if it's already running
  start-stop-daemon --start --quiet --pidfile $PIDFILE --exec /bin/sh --test > /dev/null || return 1

  # Actually start it now.
  start-stop-daemon --start --quiet --background \
    --chuid {{user}}:{{group}} \
    --make-pidfile --pidfile $PIDFILE \
    --exec /bin/sh -- -c "exec $COMMAND $ARGS" - \
  || return 2
  return $?
}

#
# Function that stops the daemon/service
#
do_stop()
{
  start-stop-daemon --stop --quiet --retry=TERM/30/KILL/5 --pidfile $PIDFILE
  code="$?"
  [ "$code" = 2 ] && return 2

  # Wait for children to finish too if this is a daemon that forks
  # and if the daemon is only ever run from this initscript.
  # If the above conditions are not satisfied then add some other code
  # that waits for the process to drop all resources that could be
  # needed by services started subsequently.  A last resort is to
  # sleep for some time.
  start-stop-daemon --stop --quiet --oknodo --retry=0/30/KILL/5 --pidfile $PIDFILE
  RETVAL=$?
  [ "$RETVAL" = 2 ] && return 2
  # Many daemons don't delete their pidfiles when they exit.
  rm -f $PIDFILE
  return "$RETVAL"
}

do_reload() {
  start-stop-daemon --stop --signal 1 --quiet --pidfile $PIDFILE --name $NAME
  return 0
}

case "$1" in
  start) 
    [ "$VERBOSE" != no ] && log_daemon_msg "Stopping $DESC" "$NAME"
    do_start 
    case "$?" in
      0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
      2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
    esac
    ;;
  stop)
    [ "$VERBOSE" != no ] && log_daemon_msg "Stopping $DESC" "$NAME"
    do_stop
    case "$?" in
      0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
      2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
    esac
    ;;
  status)
     status_of_proc -p "$PIDFILE" "$COMMAND" "$NAME" && exit 0 || exit $?
     ;;
  restart)
    do_stop
    case "$?" in
      0|1)
        do_start
        case "$?" in
          0) log_end_msg 0 ;;
          1) log_end_msg 1 ;; # Old process is still running
          *) log_end_msg 1 ;; # Failed to start
        esac
        ;;
      *) # Failed to stop
        log_end_msg 1
        ;;
    esac
    ;;
  *)
    echo "Usage: $SCRIPTNAME {start|stop|status|restart}" >&2
    exit 3
  ;;
esac

:
