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

* runit
* daemontools
* supervisord
* upstart
* systemd

### "init" systems

* freebsd
* rhel
* debian
* others?
