$: << "./lib"
require "pleaserun/sysv"
pr = PleaseRun::SysVInit.new("ubuntu-12.04")
pr.name = "test fancy"
pr.command = "sleep"
pr.user = "fancy"
#pr.args = [ "-t", "sometag", "hello world" ]
pr.args = [ "3600" ]

pr.files.each do |path, content|
  puts path => content.bytes.size
end
#* identity (user, group)
#* limits (ulimit, etc)
#* environment variables
#* working directory
#* containers (chroot, etc)
#* log/output locations
