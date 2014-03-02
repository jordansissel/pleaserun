require "pleaserun/platform/base"

class PleaseRun::Platform::Upstart < PleaseRun::Platform::Base
  def files
    return Enumerator::Generator.new do |out|
      out.yield [ safe_filename("/etc/init/{{ name }}.conf"), render_template("init.conf") ]
      out.yield [ safe_filename("/etc/init.d/{{ name }}"), render_template("init.d.sh"), 0755 ]
    end
  end
end

