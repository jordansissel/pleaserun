$: << "./lib"
require "pleaserun/sysv"
require "fpm"
require "fpm/package/dir"
require "pleaserun/runit"
pr = PleaseRun::SysVInit.new("ubuntu-12.04")
#pr = PleaseRun::Runit.new("")
pr.name = "test fancy"
pr.user = "root"
#pr.args = [ "-t", "sometag", "hello world" ]
#pr.command = "printf"
#pr.args = [ "1: %s\n2: %s\n3: %s\n", "3600", "hello world" ]
#
pr.program = "sleep"
pr.args = [ "3600" ]

pkg = FPM::Package::Dir.new
pkg.name = "example"
pr.files.each do |path, content|
  #next unless path == "/service/test_fancy/run"
  out = pkg.staging_path(path)
  outdir = File.dirname(out)
  FileUtils.mkdir_p(outdir)
  File.write(out, content)
end
pkg.output("./example")

#* identity (user, group)
#* limits (ulimit, etc)
#* environment variables
#* working directory
#* containers (chroot, etc)
#* log/output locations
