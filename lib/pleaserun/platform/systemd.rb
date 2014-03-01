require 'pleaserun/namespace'
require "pleaserun/platform/base"

class PleaseRun::Platform::Systemd < PleaseRun::Platform::Base

  def files
    begin
      insist { program } =~ /^\//
    rescue Insist::Failure
      raise PleaseRun::Configurable::ValidationError, "In systemd, the program must be a full path. You gave '#{program}'"
    end

    return Enumerator::Generator.new do |enum|
      enum.yield [ safe_filename("/lib/systemd/system/{{{ name }}}.service"), render_template("program.service") ]
      if prestart
        enum.yield [ safe_filename("/lib/systemd/system/{{{ name }}}-prestart.sh"), prestart, 0755 ]
      end
    end
  end # def files
end # class PleaseRun::Platform::Systemd
