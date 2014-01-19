require "pleaserun/base"

class PleaseRun::Upstart < PleaseRun::Base
  def files
    return Enumerator::Generator.new do |out|
      out.yield [ safe_filename("/etc/init/{{ name }}.conf"), render_template("init.conf") ]
      out.yield [ safe_filename("/etc/init.d/{{ name }}"), render_template("init.d.sh") ]
      # also needs to create a link from /etc/init.d/{{name}} to /lib/init/upstart-job
      #out.yield ["/etc/default/#{name}", Mustache.render(File.read(template("default")), self)]
    end
  end
end

