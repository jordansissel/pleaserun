# Please Run.

Generate startup scripts for the wasteland of sorrow that is process launchers.

Ideally, you should be able to specify a configuration of how to run a given
service command (like apache, lumberjack, whatever), and this tool should
be able to spit out a script or config file for your target platform.

## Execution Abstractions

* the command to run
* identity (user, group)
* limits (ulimit, etc)
* environment variables
* working directory
* containers (chroot, etc)
* log/output locations

Anything else?

## Platforms

* ☑ runit (multiple files/directories)
* daemontools (same as runit)
* supervisord (one single config file)
* ☑ upstart (one file)
* systemd (???)
* smf/solaris (one file?)
* ☑ launchd (osx)
* windows services

### "init" systems

* freebsd
* rhel
* debian
* ☑ ubuntu
* others?

### "activation" commands

* chkconfig (rhel)
* update-rc.d/family (debian)
* launchctl load (osx)

### "Config" files

* /etc/default (debian)
* /etc/sysconfig (rhel)

