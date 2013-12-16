pr = Please::Run::SYSVInit.new("ubuntu-12.04")
pr.name = "test fancy"
pr.command = "sleep"
#pr.args = [ "-t", "sometag", "hello world" ]
pr.args = [ "3600" ]

puts pr.build
#* identity (user, group)
#* limits (ulimit, etc)
#* environment variables
#* working directory
#* containers (chroot, etc)
#* log/output locations
