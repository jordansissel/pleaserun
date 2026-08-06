require 'pleaserun/namespace'
require "pleaserun/platform/base"

# The platform implementation for systemd.
#
# If you use Fedora 18+ or CentOS/RHEL 7+, this is for you.
class PleaseRun::Platform::Systemd < PleaseRun::Platform::Base
  attribute :unit_path, "The path to put systemd unit files",
            :default => "/etc/systemd/system" do
    validate do |path|
      insist { path }.is_a?(String)
    end
  end

  attribute :prestart_path, "The path to put systemd unit prestart files",
            :default =>
(:unit_path == "/lib/systemd/system" || :unit_path == "/usr/lib/systemd/system") ? "/usr/lib/pleaserun" :
(:unit_path == "/etc/systemd/system" ? "/usr/local/lib/pleaserun" : "{{{home}}}/lib/pleaserun") do
    validate do |path|
      insist { path }.is_a?(String)
    end
  end

  def files
    begin
      # TODO(sissel): Make it easy for subclasses to extend validation on attributes.
      insist { program } =~ /^\//
    rescue Insist::Failure
      raise PleaseRun::Configurable::ValidationError, "In systemd, the program must be a full path. You gave '#{program}'."
    end

    return Enumerator::Generator.new do |enum|
      enum.yield(safe_filename("/etc/default/{{ name }}"), render_template("default"))
      enum.yield(safe_filename("{{{ unit_path }}}/{{{ name }}}.service"), render_template("program.service"))

      # TODO(sissel): This is probably not the best place to put this. Ahh well :)
      enum.yield(safe_filename("{{{ prestart_path }}}/{{{ name }}}-prestart.sh"), render_template("prestart.sh"), 0755) if prestart
    end
  end # def files

  def install_actions
    return ["systemctl --system daemon-reload"]
  end
end # class PleaseRun::Platform::Systemd
