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
      out.yield [ safe_filename("/etc/init.d/{{ name }}"), render_template("init.d") ]
      out.yield [ safe_filename("/etc/default/{{ name }}"), render_template("default") ]
    end
  end
end

