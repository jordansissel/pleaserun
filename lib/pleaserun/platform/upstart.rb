require "pleaserun/platform/base"

# The Upstart platform implementation.
#
# If you use Ubuntu (8.10 to present) or CentOS 6 this is for you.
class PleaseRun::Platform::Upstart < PleaseRun::Platform::Base
  def files
    return Enumerator::Generator.new do |out|
      out.yield(safe_filename("/etc/init/{{ name }}.conf"), render_template("init.conf"))
      # Don't bother putting /etc/init.d/ shims anymore.
      # The best way to interact with upstart is through initctl, start, stop,
      # and restart commands
      #out.yield(safe_filename("/etc/init.d/{{ name }}"), render_template("init.d.sh"), 0755)
    end
  end
end
