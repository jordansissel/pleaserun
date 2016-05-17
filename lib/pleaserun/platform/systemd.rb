require 'pleaserun/namespace'
require "pleaserun/platform/base"

# The platform implementation for systemd.
#
# If you use Fedora 18+ or CentOS/RHEL 7+, this is for you.
class PleaseRun::Platform::Systemd < PleaseRun::Platform::Base
  def files
    begin
      # TODO(sissel): Make it easy for subclasses to extend validation on attributes.
      insist { program } =~ /^\//
    rescue Insist::Failure
      raise PleaseRun::Configurable::ValidationError, "In systemd, the program must be a full path. You gave '#{program}'."
    end

    return Enumerator::Generator.new do |enum|
      enum.yield(safe_filename("/etc/systemd/system/{{{ name }}}.service"), render_template("program.service"))
      enum.yield(safe_filename("/etc/systemd/system/{{{ name }}}-prestart.sh"), render_template("prestart.sh"), 0755) if prestart
    end
  end # def files

  def install_actions
    return ["systemctl --system daemon-reload"]
  end
end # class PleaseRun::Platform::Systemd
