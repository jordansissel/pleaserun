require 'pleaserun/namespace'
require "pleaserun/platform/base"

class PleaseRun::Platform::Systemd < PleaseRun::Platform::Base
  def files
    begin
      # TODO(sissel): Make it easy for subclasses to extend validation on attributes.
      insist { program } =~ /^\//
    rescue Insist::Failure
      raise PleaseRun::Configurable::ValidationError, "In systemd, the program must be a full path. You gave '#{program}'"
    end

    return Enumerator::Generator.new do |enum|
      enum.yield [ safe_filename("/lib/systemd/system/{{{ name }}}.service"), render_template("program.service") ]
      if prestart
        enum.yield [ safe_filename("/lib/systemd/system/{{{ name }}}-prestart.sh"), render_template("prestart.sh"), 0755 ]
      end
    end
  end # def files

  def install_actions
    return [ "systemctl --system daemon-reload" ]
  end
end # class PleaseRun::Platform::Systemd
