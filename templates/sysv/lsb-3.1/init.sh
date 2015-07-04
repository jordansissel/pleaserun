#!/bin/sh
# Init script for {{{ name }}}
# Maintained by {{{ author }}}
# Generated by pleaserun.
# Implemented based on LSB Core 3.1:
#   * Sections: 20.2, 20.3
#
### BEGIN INIT INFO
# Provides:          {{{ name }}}
# Required-Start:    $remote_fs $syslog $network $named
# Required-Stop:     $remote_fs $syslog $network $named
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: {{{ one_line_description }}}
# Description:       {{{ description }}}
### END INIT INFO

PATH=/sbin:/usr/sbin:/bin:/usr/bin
export PATH

name={{#escaped}}{{#safe_filename}}{{{ name }}}{{/safe_filename}}{{/escaped}}
program={{#escaped}}{{{ program }}}{{/escaped}}
args={{{ escaped_args }}}
pidfile="/var/run/$name.pid"

[ -x "$program" ] || exit 0

[ -r /etc/default/$name ] && . /etc/default/$name
[ -r /etc/sysconfig/$name ] && . /etc/sysconfig/$name

trace() {
  logger -t "/etc/init.d/{{{name}}}" "$@"
}

emit() {
  trace "$@"
  echo "$@"
}

start() {
  {{! Return
       0 if daemon has been started
       1 if daemon was already running
       2 if daemon could not be started
  }}

  status && {
    emit "$name is already running"
    return 1
  }

  {{! I don't use 'su' here to run as a different user because the process 'su'
      stays as the parent, causing our pidfile to contain the pid of 'su' not the
      program we intended to run. Luckily, the 'chroot' program on OSX, FreeBSD, and Linux
      all support switching users and it invokes execve immediately after chrooting. }}

  {{#sysv_log_directory?}}
  # Ensure the log directory is setup correctly.
  [ ! -d "{{{sysv_log_path}}}" ] && mkdir "{{{sysv_log_path}}}"
  chown "$user":"$group" "{{{sysv_log_path}}}"
  chmod 755 "{{{sysv_log_path}}}"
  {{/sysv_log_directory?}}

  {{#prestart}}
  if [ "$PRESTART" != "no" ] ; then
    # If prestart fails, abort start.
    prestart || return 2
  fi
  {{/prestart}}

  # Setup any environmental stuff beforehand
  {{{ulimit_shell}}}

  # Run the program!
  {{#nice}}nice -n "$nice" \{{/nice}}
  chroot --userspec "$user":"$group" "$chroot" sh -c "
    {{{ulimit_shell}}}
    cd \"$chdir\"
    exec \"$program\" $args
  " >> {{{ sysv_log }}}.stdout 2>> {{{ sysv_log }}}.stderr &

  # Generate the pidfile from here. If we instead made the forked process
  # generate it there will be a race condition between the pidfile writing
  # and a process possibly asking for status.
  echo $! > $pidfile

  emit "$name started"
  return 0
}

stop() {
  {{! Return
       0 if daemon has been stopped
       1 if daemon was already stopped
       2 if daemon could not be stopped
  }}

  # Try a few times to kill TERM the program
  if status ; then
    pid=$(cat "$pidfile")
    trace "Killing $name (pid $pid) with SIGTERM"
    kill -TERM $pid
    # Wait for it to exit.
    for i in 1 2 3 4 5 ; do
      status || break
      trace "Waiting $name (pid $pid) to die..."
      sleep 1
    done
    if status ; then
      emit "$name stop failed; still running."
      return 2
    else
      emit "$name stopped."
      return 0
    fi
  else
    return 1
  fi
}

status() {
  if [ -f "$pidfile" ] ; then
    pid=$(cat "$pidfile")
    if ps -p $pid > /dev/null 2> /dev/null ; then
      # process by this pid is running.
      # It may not be our pid, but that's what you get with just pidfiles.
      # TODO(sissel): Check if this process seems to be the same as the one we
      # expect. It'd be nice to use flock here, but flock uses fork, not exec,
      # so it makes it quite awkward to use in this case.
      return 0
    else
      return 1 # program is dead but pid file exists
    fi
  else
    return 3 # program is not running
  fi
}

force_stop() {
  if status ; then
      stop
      ret=$?
      if [ $ret -eq 2 ]; then
          kill -KILL $(cat "$pidfile")
          return 0              # Assume this always succeed
      fi
      return $ret
  else
      return 1
  fi
}

{{#prestart}}
prestart() {
  {{{ prestart }}}

  status=$?

  if [ $status -gt 0 ] ; then
    emit "Prestart command failed with code $status. If you wish to skip the prestart command, set PRESTART=no in your environment."
  fi
  return $status
}
{{/prestart}}

case "$1" in
  force-start|start|stop|force-stop|restart)
    trace "Attempting '$1' on {{{name}}}"
    ;;
esac

case "$1" in
  force-start)
    PRESTART=no
    exec "$0" start
    ;;
  start) start ;;
  stop) stop ;;
  force-stop) force_stop ;;
  status) 
    status
    code=$?
    if [ $code -eq 0 ] ; then
      emit "$name is running"
    else
      emit "$name is not running"
    fi
    exit $code
    ;;
  restart) 
    {{#prestart}}if [ "$PRESTART" != "no" ] ; then
      prestart || exit 2
    fi{{/prestart}}
    stop
    case $? in
      0|1)
        start
        case $? in
          0) exit 0 ;;
          *) exit 1 ;;
        esac
        ;;
      *)
        # Failed to stop
        exit 1
        ;;
    esac
    ;;
  *)
    echo "Usage: $SCRIPTNAME {start|force-start|stop|force-start|force-stop|status|restart}" >&2
    exit 3
  ;;
esac

exit $?
