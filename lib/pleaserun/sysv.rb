require "shellwords" # stdlib
require "pleaserun/base"
require "pleaserun/namespace"

class PleaseRun::SysVInit < PleaseRun::Base

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
      out.yield [ "/etc/init.d/#{name}", render_template("init.d") ]
      out.yield [ "/etc/default/#{name}", render_template("default") ]
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

