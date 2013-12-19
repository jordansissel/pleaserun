require "mustache"  # gem 
require "insist" # gem
require "shellwords" # stdlib
require "pleaserun/base"

module Please; module Run; end; end
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
    # TODO(sissel): build should permit creating multiple files
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

