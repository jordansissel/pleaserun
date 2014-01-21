require "pleaserun/base"
require "pleaserun/namespace"

class PleaseRun::SYSV < PleaseRun::Base
  def files
    return Enumerator::Generator.new do |out|
      out.yield [ safe_filename("/etc/init.d/{{ name }}"), render_template("init.d"), 0755 ]
      out.yield [ safe_filename("/etc/default/{{ name }}"), render_template("default") ]
    end
  end
end

