require "mustache"  # gem 
require "insist" # gem
require "shellwords" # stdlib
require "pleaserun/base"

module Please; module Run; end; end

class Please::Run::Upstart < Please::Run::Base
  def initialize(*args)
    super
    insist { File.readable?(template) }
  end

  def template(name)
    # return a default if not possible? Error if no existing?
    return "templates/init/#{name}/#{target_version}"
  end

  # Returns which an enumerable will yield [path, content] for any files
  # necessary to implement this runner.
  #
  # - path: a string path where the file should be put
  # - content: a text blob content for the file
  #
  # Example usage:
  #
  # run.files do |path, content|
  #   File.write(path, content)
  # end
  def files
    return Enumerator::Generator.new do |out|
      out.yield ["/etc/init/#{name}", Mustache.render(File.read(template("init")), self)]
      # also needs to create a link from /etc/init.d/{{name}} to /lib/init/upstart-job
      #out.yield ["/etc/default/#{name}", Mustache.render(File.read(template("default")), self)]
    end
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

