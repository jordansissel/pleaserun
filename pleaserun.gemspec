Gem::Specification.new do |spec|
  files = File.read(__FILE__)[/^__END__$.*/m].split("\n")[1..-1]

  spec.name = "pleaserun"
  spec.version = "0.0.22"
  spec.summary = "pleaserun"
  spec.description = "pleaserun"
  spec.license = "Apache 2.0"

  spec.add_dependency "cabin", ">0" # for logging. apache 2 license
  spec.add_dependency "clamp"
  spec.add_dependency "stud"
  spec.add_dependency "mustache", "0.99.8"
  spec.add_dependency "insist"
  #spec.add_dependency "ohai", "~> 6.20" # used for host detection

  spec.files = files
  spec.require_paths << "lib"
  spec.bindir = "bin"
  spec.executables = [ "pleaserun", "please-manage-user" ]

  spec.authors = ["Jordan Sissel"]
  spec.email = ["jls@semicomplete.com"]
  spec.homepage = "https://github.com/jordansissel/pleaserun"
end

# Files list, populate it with this: :.,$!git ls-files | grep -v gitignore
__END__
.rubocop.yml
CHANGELOG.asciidoc
Gemfile
Gemfile.lock
Guardfile
LICENSE
Makefile
README.md
bin/please-manage-user
bin/pleaserun
examples/runit.rb
lib/pleaserun/cli.rb
lib/pleaserun/configurable.rb
lib/pleaserun/detector.rb
lib/pleaserun/errors.rb
lib/pleaserun/installer.rb
lib/pleaserun/mustache_methods.rb
lib/pleaserun/namespace.rb
lib/pleaserun/platform/base.rb
lib/pleaserun/platform/launchd.rb
lib/pleaserun/platform/runit.rb
lib/pleaserun/platform/systemd.rb
lib/pleaserun/platform/sysv.rb
lib/pleaserun/platform/upstart.rb
lib/pleaserun/user/base.rb
pleaserun.gemspec
spec/pleaserun/cli_spec.rb
spec/pleaserun/configurable_spec.rb
spec/pleaserun/mustache_methods_spec.rb
spec/pleaserun/platform/base_spec.rb
spec/pleaserun/platform/launchd_spec.rb
spec/pleaserun/platform/systemd_spec.rb
spec/pleaserun/platform/sysv_spec.rb
spec/pleaserun/platform/upstart_spec.rb
spec/pleaserun/user/base_spec.rb
spec/shared_examples.rb
spec/testenv.rb
templates/launchd/10.9
templates/launchd/default/program.plist
templates/runit/log
templates/runit/run
templates/systemd/default/prestart.sh
templates/systemd/default/program.service
templates/sysv/default
templates/sysv/lsb-3.1/default
templates/sysv/lsb-3.1/init.sh
templates/upstart/0.6.5/init.conf
templates/upstart/0.6.5/init.d.sh
templates/upstart/1.10
templates/upstart/1.5/init.conf
templates/upstart/1.5/init.d.sh
templates/upstart/default
templates/user/linux/default/installer.sh
templates/user/linux/default/remover.sh
