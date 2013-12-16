require "mustache"
require "insist"
require "shellwords"

module Please; 
  module Run; end
  module Help; end
end

module Please::Help::Shell
  def quote(*args)
    return Shellwords.shelljoin(args)
  end
end

class Please::Run::Base
  attr_accessor :name
  attr_accessor :command, :args
  attr_reader :target_version

  def initialize(target_version)
    insist { target_version }.is_a?(String)
    @target_version = target_version
  end

  def command=(command)
    insist { command }.is_a?(String)
    @command = command
  end

  def args=(args)
    insist { args }.is_a?(Array)
    args.each { |a| insist { a }.is_a?(String) }
    @args = args
  end
end

class Please::Run::SYSVInit < Please::Run::Base
  def initialize(*args)
    super
    insist { File.readable?(template) }
  end

  def template
    return "templates/init.d/#{target_version}"
  end

  def build
    puts Mustache.render(File.read(template), self)
  end

  def escaped_args
    return Shellwords.shellescape(Shellwords.shelljoin(@args))
  end

  def escaped(str)
    return Shellwords.shellescape(Mustache.render(str, self))
  end

  def safe_filename(str)
    return Mustache.render(str, self).gsub(" ","_")
  end
end

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
