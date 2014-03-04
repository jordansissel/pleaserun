# Please, Run!

Pleaserun is a tool to generate startup scripts for the wasteland of sorrow
that is process launchers.

Ideally, you should be able to specify a configuration of how to run a given
service command (like apache, syslog-ng, whatever), and this tool should
be able to spit out a script or config file for your target platform.

## Installation

```
gem install pleaserun
```

## Your First Process

First, we need a program to run!

### Example: redis

For no particular reason, this example will choose redis to run. The idea is to
simulate the same workflow you would normally go through in production: acquire
software, deploy it, run it. Pleaserun helps you with the 'run it' part, but
first let's get redis and build it.

```
wget http://download.redis.io/releases/redis-2.8.6.tar.gz
tar -zxf redis-2.8.6.tar.gz
cd redis-2.8.6
make -j4
make install PREFIX=/tmp/redis
```

Assuming the above succeeds (it did for me!), we now have redis installed to `/tmp/redis`:

```
% ls /tmp/redis/bin
redis-benchmark  redis-check-aof  redis-check-dump  redis-cli  redis-server
```

You might be thinking - why /tmp? This is just a demo! That's why! :)

### Generate a runner

What platform are you on? Do you know the best way to run a server process? I
can never remember.

Luckily, pleaserun remembers.

```
# Run as root so pleaserun has permissions to write to
# any files required to install this as a service!
% sudo pleaserun --install /tmp/redis/bin/redis-server
No platform selected. Autodetecting... {:platform=>"upstart", :version=>"1.5", :level=>:warn}
No name given, setting reasonable default {:name=>"redis-server", :level=>:warn}
Writing file {:destination=>"/etc/init/redis-server.conf"}
Writing file {:destination=>"/etc/init.d/redis-server"}
```

Note: The `--install` flag above tells pleaserun to install it on this current system. The
default behavior without this flag is to install it in a temp directory so you can copy
it elsewhere if desired.

Now what? You can see above it automatically detected that "Upstart 1.5" was
the right process runner to target. Let's try using it!

```
% status redis-server
redis-server stop/waiting

% sudo start redis-server
redis-server start/running, process 395

% status redis-server
redis-server start/running, process 395

% ps -fwwp 395
UID        PID  PPID  C STIME TTY          TIME CMD
root       395     1  0 06:27 ?        00:00:00 /tmp/redis/bin/redis-server *:6379

# Is it running? Let's check with redis-cli
% redis-cli
127.0.0.1:6379> ping
PONG

% sudo stop redis-server
redis-server stop/waiting
```

Bam. Pretty easy, right? Let's recap!

### Recap

* You ran `pleaserun --install /tmp/redis/bin/redis-server`
* Pleaserun detected the platform as Upstart 1.5
* You didn't have to write an init script.
* You didn't have to know how to write an Upstart config.
